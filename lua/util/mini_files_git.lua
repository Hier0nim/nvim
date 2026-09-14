local M = {}
local did_setup = false

---Attach live filesystem refreshes and Git status overlays to mini.files.
---@param MiniFiles table
function M.setup(MiniFiles)
  if did_setup then
    return
  end
  did_setup = true

  local ns_mini_files_git = vim.api.nvim_create_namespace 'mini_files_git'
  local uv = vim.uv or vim.loop

  ---@type table<string, { time_ms: number, status_map: table<string, string> }>
  local git_status_cache = {}
  ---@type table<string, { running: boolean, pending: boolean }>
  local git_requests = {}
  ---@type table<integer, { dir: string, repo: string|nil }>
  local active_buffers = {}
  ---@type table<string, userdata>
  local directory_watchers = {}
  ---@type table<string, userdata[]>
  local repository_watchers = {}
  ---@type table<integer, userdata>
  local overlay_timers = {}
  ---@type table<string, userdata>
  local git_timers = {}
  local refresh_timer = nil
  ---@type table<string, number>
  local fallback_refresh_ms = {}

  local cache_timeout_ms = 30000
  local debounce_ms = 100
  local fallback_interval_ms = 30000

  ---@param name string
  ---@return integer
  local function augroup(name)
    return vim.api.nvim_create_augroup('MiniFiles_' .. name, { clear = true })
  end

  ---@param timer userdata|nil
  local function close_timer(timer)
    if not timer or timer:is_closing() then
      return
    end
    timer:stop()
    timer:close()
  end

  ---@param handle userdata|nil
  local function close_handle(handle)
    if not handle or handle:is_closing() then
      return
    end
    handle:stop()
    handle:close()
  end

  ---@param path string
  ---@return boolean
  local function is_symlink(path)
    local stat = uv.fs_lstat(path)
    return stat ~= nil and stat.type == 'link'
  end

  ---@return number
  local function now_ms()
    return uv.hrtime() / 1000000
  end

  ---@param path string|nil
  ---@return string|nil
  local function normalize(path)
    if not path or path == '' then
      return nil
    end
    return vim.fs.normalize(path)
  end

  ---@param path string|nil
  ---@return string|nil
  local function get_repo_root(path)
    path = normalize(path)
    if not path then
      return nil
    end

    local stat = uv.fs_stat(path)
    local search_from = stat and stat.type ~= 'directory' and vim.fs.dirname(path) or path
    return normalize(vim.fs.root(search_from, '.git'))
  end

  ---Resolve a linked worktree's .git file without starting another Git process.
  ---@param repo_root string
  ---@return string|nil
  local function get_git_dir(repo_root)
    local marker = repo_root .. '/.git'
    local stat = uv.fs_stat(marker)
    if not stat then
      return nil
    end
    if stat.type == 'directory' then
      return normalize(marker)
    end

    local ok, lines = pcall(vim.fn.readfile, marker, '', 1)
    local git_dir = ok and lines[1] and lines[1]:match '^gitdir:%s*(.+)%s*$' or nil
    if not git_dir then
      return nil
    end
    if not vim.startswith(git_dir, '/') then
      git_dir = repo_root .. '/' .. git_dir
    end
    return normalize(git_dir)
  end

  ---@param git_dir string
  ---@return string|nil
  local function get_common_git_dir(git_dir)
    local ok, lines = pcall(vim.fn.readfile, git_dir .. '/commondir', '', 1)
    local common_dir = ok and lines[1] or nil
    if not common_dir or common_dir == '' then
      return nil
    end
    if not vim.startswith(common_dir, '/') then
      common_dir = git_dir .. '/' .. common_dir
    end
    return normalize(common_dir)
  end

  ---@param buf_id integer
  ---@return string|nil
  local function get_mini_dir(buf_id)
    if not vim.api.nvim_buf_is_valid(buf_id) then
      return nil
    end

    local name = vim.api.nvim_buf_get_name(buf_id)
    if not name or name == '' then
      return nil
    end
    return normalize(name:gsub('^minifiles://%d+/', ''))
  end

  ---@param status string
  ---@param symlink boolean
  ---@return string sign_text
  ---@return string hl_group
  local function map_symbols(status, symlink)
    local exact = {
      [' M'] = { '~', 'MiniDiffSignChange' },
      ['M '] = { '≈', 'MiniDiffSignChange' },
      ['MM'] = { '≋', 'MiniDiffSignChange' },
      ['A '] = { '+', 'MiniDiffSignAdd' },
      ['AA'] = { '✚', 'MiniDiffSignAdd' },
      ['D '] = { '−', 'MiniDiffSignDelete' },
      ['AM'] = { '⊕', 'MiniDiffSignChange' },
      ['AD'] = { '⊖', 'MiniDiffSignChange' },
      ['R '] = { '➜', 'MiniDiffSignChange' },
      ['U '] = { '‼', 'MiniDiffSignChange' },
      ['UU'] = { '⇆', 'MiniDiffSignAdd' },
      ['UA'] = { '⊗', 'MiniDiffSignAdd' },
      ['??'] = { '?', 'MiniDiffSignDelete' },
    }
    local result = exact[status]
    if not result then
      local index, worktree = status:sub(1, 1), status:sub(2, 2)
      if index == 'U' or worktree == 'U' then
        result = { '‼', 'MiniDiffSignChange' }
      elseif index == 'R' or index == 'C' then
        result = { '➜', 'MiniDiffSignChange' }
      elseif index == 'D' or worktree == 'D' then
        result = { '−', 'MiniDiffSignDelete' }
      elseif index == 'A' then
        result = { '+', 'MiniDiffSignAdd' }
      else
        result = { '~', 'MiniDiffSignChange' }
      end
    end

    local symbol, hl_group = result[1], result[2]
    if symlink then
      symbol = '@' .. symbol
      hl_group = 'MiniDiffSignDelete'
    end
    return symbol, hl_group
  end

  ---Parse NUL-delimited porcelain v1, whose paths are unquoted and may contain newlines.
  ---For rename/copy records, Git emits the destination followed by the source path.
  ---@param content string
  ---@return table<string, string>
  local function parse_git_status(content)
    ---@type table<string, string>
    local status_map = {}
    local offset = 1

    while offset <= #content do
      local record_end = content:find('\0', offset, true)
      if not record_end then
        break
      end
      local record = content:sub(offset, record_end - 1)
      offset = record_end + 1

      local status = record:sub(1, 2)
      local file_path = record:sub(4)
      if status:find '[RC]' then
        local source_end = content:find('\0', offset, true)
        if not source_end then
          break
        end
        offset = source_end + 1
      end

      if #status == 2 and file_path ~= '' then
        local current = ''
        for part in file_path:gmatch '[^/]+' do
          current = current == '' and part or (current .. '/' .. part)
          if current == file_path or not status_map[current] then
            status_map[current] = status
          end
        end
      end
    end

    return status_map
  end

  ---@param buf_id integer
  local function clear_git_marks(buf_id)
    pcall(vim.api.nvim_buf_clear_namespace, buf_id, ns_mini_files_git, 0, -1)
  end

  ---@param buf_id integer
  ---@param repo_root string
  ---@param status_map table<string, string>
  local function update_mini_with_git(buf_id, repo_root, status_map)
    vim.schedule(function()
      local active = active_buffers[buf_id]
      if not active or active.repo ~= repo_root or not vim.api.nvim_buf_is_valid(buf_id) then
        return
      end

      clear_git_marks(buf_id)
      local line_count = vim.api.nvim_buf_line_count(buf_id)
      local lines = vim.api.nvim_buf_get_lines(buf_id, 0, line_count, false)
      local prefix = repo_root == '/' and '/' or (repo_root .. '/')

      for line_number = 1, line_count do
        local ok, entry = pcall(MiniFiles.get_fs_entry, buf_id, line_number)
        if not ok or not entry or not entry.path then
          break
        end

        local entry_path = normalize(entry.path)
        local relative_path = entry_path and vim.startswith(entry_path, prefix) and entry_path:sub(#prefix + 1) or nil
        local status = relative_path and status_map[relative_path] or nil
        if status then
          local sign_text, hl_group = map_symbols(status, is_symlink(entry.path))
          vim.api.nvim_buf_set_extmark(buf_id, ns_mini_files_git, line_number - 1, 0, {
            sign_text = sign_text,
            sign_hl_group = hl_group,
            priority = 2,
          })

          local line = lines[line_number]
          local name_start_col = line and line:find(entry.name, 1, true) or nil
          if name_start_col then
            vim.api.nvim_buf_set_extmark(buf_id, ns_mini_files_git, line_number - 1, name_start_col - 1, {
              end_col = name_start_col + #entry.name - 1,
              hl_group = hl_group,
            })
          end
        end
      end
    end)
  end

  local request_git_status

  ---Apply the latest status to every active view in this repository.
  ---@param repo_root string
  ---@param status_map table<string, string>
  local function update_repo_views(repo_root, status_map)
    for buf_id, active in pairs(active_buffers) do
      if active.repo == repo_root then
        update_mini_with_git(buf_id, repo_root, status_map)
      end
    end
  end

  ---Run at most one status process per repository; one trailing request absorbs changes during a run.
  ---@param repo_root string
  request_git_status = function(repo_root)
    if not repository_watchers[repo_root] then
      return
    end

    local request = git_requests[repo_root] or { running = false, pending = false }
    git_requests[repo_root] = request
    if request.running then
      request.pending = true
      return
    end
    request.running = true

    vim.system({
      'git',
      '--no-optional-locks',
      'status',
      '--porcelain=v1',
      '-z',
      '--untracked-files=all',
      '--ignore-submodules=none',
    }, { cwd = repo_root }, function(result)
      vim.schedule(function()
        -- Teardown removes the request object. Checking its identity also prevents
        -- an older process from publishing after the same repository is reopened.
        if git_requests[repo_root] ~= request or not repository_watchers[repo_root] then
          return
        end

        request.running = false
        if result.code == 0 and type(result.stdout) == 'string' then
          local status_map = parse_git_status(result.stdout)
          local refreshed_ms = now_ms()
          git_status_cache[repo_root] = { time_ms = refreshed_ms, status_map = status_map }
          fallback_refresh_ms[repo_root] = refreshed_ms
          update_repo_views(repo_root, status_map)
        end

        if request.pending then
          request.pending = false
          request_git_status(repo_root)
        end
      end)
    end)
  end

  ---@param repo_root string
  local function queue_git_refresh(repo_root)
    git_status_cache[repo_root] = nil
    close_timer(git_timers[repo_root])

    local timer = uv.new_timer()
    git_timers[repo_root] = timer
    timer:start(
      debounce_ms,
      0,
      vim.schedule_wrap(function()
        if git_timers[repo_root] ~= timer then
          return
        end
        close_timer(timer)
        git_timers[repo_root] = nil
        request_git_status(repo_root)
      end)
    )
  end

  ---@param buf_id integer
  local function update_git_status(buf_id)
    local active = active_buffers[buf_id]
    if not active or not active.repo then
      clear_git_marks(buf_id)
      return
    end

    local cached = git_status_cache[active.repo]
    if cached then
      update_mini_with_git(buf_id, active.repo, cached.status_map)
    end
    if not cached or (now_ms() - cached.time_ms) >= cache_timeout_ms then
      request_git_status(active.repo)
    end
  end

  local sync_active_views

  ---Refresh directory contents without interpreting or applying MiniFiles edits.
  ---All MiniFiles buffers are checked because explorer views can be hidden.
  local function refresh_explorers()
    for _, buf_id in ipairs(vim.api.nvim_list_bufs()) do
      if vim.api.nvim_buf_is_valid(buf_id) and vim.api.nvim_buf_get_name(buf_id):find '^minifiles://' and vim.bo[buf_id].modified then
        return
      end
    end

    for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
      local win_id = vim.api.nvim_tabpage_list_wins(tabpage)[1]
      if win_id then
        vim.api.nvim_win_call(win_id, function()
          if MiniFiles.get_explorer_state() then
            -- Supplying a content option makes refresh reread directory contents.
            -- Unlike synchronize(), refresh never applies filesystem actions.
            MiniFiles.refresh { content = { filter = MiniFiles.config.content.filter } }
          end
        end)
      end
    end
    vim.schedule(sync_active_views)
  end

  local function queue_filesystem_refresh()
    close_timer(refresh_timer)
    refresh_timer = uv.new_timer()
    local timer = refresh_timer
    timer:start(
      debounce_ms,
      0,
      vim.schedule_wrap(function()
        if refresh_timer ~= timer then
          return
        end
        close_timer(timer)
        refresh_timer = nil
        refresh_explorers()
      end)
    )
  end

  ---@param path string
  ---@param repo_root string|nil
  local function start_directory_watcher(path, repo_root)
    local handle = uv.new_fs_event()
    local ok = handle:start(
      path,
      {},
      vim.schedule_wrap(function(err)
        if err or not directory_watchers[path] then
          return
        end
        queue_filesystem_refresh()
        if repo_root and repository_watchers[repo_root] then
          queue_git_refresh(repo_root)
        end
      end)
    )
    if ok then
      directory_watchers[path] = handle
    else
      close_handle(handle)
    end
  end

  ---@param repo_root string
  local function start_repository_watchers(repo_root)
    local paths = {}
    local git_dir = get_git_dir(repo_root)
    if git_dir then
      paths[git_dir] = true
      local common_dir = get_common_git_dir(git_dir)
      if common_dir then
        paths[common_dir] = true
      end
    end

    local handles = {}
    for path in pairs(paths) do
      local handle = uv.new_fs_event()
      local ok = handle:start(
        path,
        {},
        vim.schedule_wrap(function(err)
          if not err and repository_watchers[repo_root] then
            queue_git_refresh(repo_root)
          end
        end)
      )
      if ok then
        table.insert(handles, handle)
      else
        close_handle(handle)
      end
    end
    repository_watchers[repo_root] = handles
  end

  ---Keep watchers exactly aligned with MiniFiles windows in every tab page.
  sync_active_views = function()
    ---@type table<integer, { dir: string, repo: string|nil }>
    local next_buffers = {}
    local wanted_dirs, wanted_repos = {}, {}

    for _, tabpage in ipairs(vim.api.nvim_list_tabpages()) do
      for _, win_id in ipairs(vim.api.nvim_tabpage_list_wins(tabpage)) do
        local buf_id = vim.api.nvim_win_get_buf(win_id)
        local name = vim.api.nvim_buf_get_name(buf_id)
        local dir = name:find '^minifiles://' and get_mini_dir(buf_id) or nil
        if dir and (uv.fs_stat(dir) or {}).type == 'directory' then
          local repo = get_repo_root(dir)
          next_buffers[buf_id] = { dir = dir, repo = repo }
          wanted_dirs[dir] = repo or false
          if repo then
            wanted_repos[repo] = true
          end
        end
      end
    end
    active_buffers = next_buffers

    for path, handle in pairs(directory_watchers) do
      if wanted_dirs[path] == nil then
        close_handle(handle)
        directory_watchers[path] = nil
      end
    end
    for path, repo in pairs(wanted_dirs) do
      if not directory_watchers[path] then
        start_directory_watcher(path, repo or nil)
      end
    end

    for repo_root, handles in pairs(repository_watchers) do
      if not wanted_repos[repo_root] then
        for _, handle in ipairs(handles) do
          close_handle(handle)
        end
        repository_watchers[repo_root] = nil
        close_timer(git_timers[repo_root])
        git_timers[repo_root] = nil
        git_status_cache[repo_root] = nil
        git_requests[repo_root] = nil
        fallback_refresh_ms[repo_root] = nil
      end
    end
    for repo_root in pairs(wanted_repos) do
      if not repository_watchers[repo_root] then
        start_repository_watchers(repo_root)
      end
    end

    for buf_id, timer in pairs(overlay_timers) do
      if not active_buffers[buf_id] then
        close_timer(timer)
        overlay_timers[buf_id] = nil
      end
    end
    for buf_id in pairs(active_buffers) do
      update_git_status(buf_id)
    end

    if next(active_buffers) == nil then
      close_timer(refresh_timer)
      refresh_timer = nil
    end
  end

  local function on_explorer_open()
    vim.schedule(sync_active_views)
  end

  local function on_explorer_close()
    -- The event fires just before closing, so defer re-scoping until its windows
    -- are gone. Other tab pages can still have an active explorer.
    vim.schedule(sync_active_views)
  end

  ---@param args table
  local function on_buffer_update(args)
    local buf_id = args.data and args.data.buf_id
    if not buf_id then
      return
    end
    vim.schedule(sync_active_views)

    close_timer(overlay_timers[buf_id])
    local timer = uv.new_timer()
    overlay_timers[buf_id] = timer
    timer:start(
      80,
      0,
      vim.schedule_wrap(function()
        if overlay_timers[buf_id] ~= timer then
          return
        end
        close_timer(timer)
        overlay_timers[buf_id] = nil
        update_git_status(buf_id)
      end)
    )
  end

  vim.api.nvim_create_autocmd('User', {
    group = augroup 'live_start',
    pattern = 'MiniFilesExplorerOpen',
    callback = on_explorer_open,
  })

  vim.api.nvim_create_autocmd('User', {
    group = augroup 'live_close',
    pattern = 'MiniFilesExplorerClose',
    callback = on_explorer_close,
  })

  vim.api.nvim_create_autocmd('User', {
    group = augroup 'live_update',
    pattern = 'MiniFilesBufferUpdate',
    callback = on_buffer_update,
  })

  vim.api.nvim_create_autocmd({ 'BufWritePost', 'FocusGained' }, {
    group = augroup 'live_git',
    callback = function()
      for repo_root in pairs(repository_watchers) do
        queue_git_refresh(repo_root)
      end
    end,
  })

  -- Filesystem watchers are directory-scoped and some platforms coalesce events.
  -- An idle, throttled refresh covers missed/deep worktree changes without polling.
  vim.api.nvim_create_autocmd('CursorHold', {
    group = augroup 'live_fallback',
    callback = function()
      local current_ms = now_ms()
      local refresh_files = false
      for repo_root in pairs(repository_watchers) do
        if current_ms - (fallback_refresh_ms[repo_root] or 0) >= fallback_interval_ms then
          fallback_refresh_ms[repo_root] = current_ms
          queue_git_refresh(repo_root)
          refresh_files = true
        end
      end
      if refresh_files then
        queue_filesystem_refresh()
      end
    end,
  })

  vim.api.nvim_create_autocmd('TabEnter', {
    group = augroup 'live_tab',
    callback = function()
      if MiniFiles.get_explorer_state() then
        queue_filesystem_refresh()
      else
        vim.schedule(sync_active_views)
      end
    end,
  })
end

return M
