local M = {}
local did_setup = false

---Attach Git status overlays to mini.files.
---@param MiniFiles table
function M.setup(MiniFiles)
  if did_setup then
    return
  end
  did_setup = true

  local ns_mini_files_git = vim.api.nvim_create_namespace 'mini_files_git'
  local uv = vim.uv or vim.loop

  ---Cache for Git status per repository root.
  ---@type table<string, { time_ms: number, status_map: table<string, string> }>
  local git_status_cache = {}

  ---Timeout for cached Git status in milliseconds.
  local cache_timeout_ms = 2000

  ---Create a MiniFiles-specific augroup.
  ---@param name string
  ---@return integer
  local function augroup(name)
    return vim.api.nvim_create_augroup('MiniFiles_' .. name, { clear = true })
  end

  ---Check whether a filesystem path is a symlink.
  ---@param path string
  ---@return boolean
  local function is_symlink(path)
    local stat = uv.fs_lstat(path)
    return stat ~= nil and stat.type == 'link'
  end

  ---Return current time in milliseconds.
  ---@return number
  local function now_ms()
    return uv.hrtime() / 1000000
  end

  ---Normalize a path safely.
  ---@param path string|nil
  ---@return string|nil
  local function normalize(path)
    if not path or path == '' then
      return nil
    end
    return vim.fs.normalize(path)
  end

  ---Resolve the repository root for a filesystem path.
  ---@param path string|nil
  ---@return string|nil
  local function get_repo_root(path)
    path = normalize(path)
    if not path then
      return nil
    end

    local stat = uv.fs_stat(path)
    local search_from = path

    if stat and stat.type ~= 'directory' then
      search_from = vim.fs.dirname(path)
    end

    return vim.fs.root(search_from, '.git')
  end

  ---Return the current directory shown by mini.files for a given buffer.
  ---Avoid MiniFiles.get_fs_entry() here because MiniFilesBufferUpdate can fire
  ---while the view is being rebuilt, and the current line may be temporarily invalid.
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

    name = name:gsub('^minifiles://%d+/', '')
    return normalize(name)
  end

  ---Map Git porcelain status to sign text and highlight group.
  ---@param status string
  ---@param symlink boolean
  ---@return string sign_text
  ---@return string hl_group
  local function map_symbols(status, symlink)
    ---@type table<string, { symbol: string, hl_group: string }>
    local status_map = {
      [' M'] = { symbol = '~', hl_group = 'MiniDiffSignChange' }, -- Modified in the working directory
      ['M '] = { symbol = '≈', hl_group = 'MiniDiffSignChange' }, -- modified in index
      ['MM'] = { symbol = '≋', hl_group = 'MiniDiffSignChange' }, -- modified in both working tree and index
      ['A '] = { symbol = '+', hl_group = 'MiniDiffSignAdd' }, -- Added to the staging area, new file
      ['AA'] = { symbol = '✚', hl_group = 'MiniDiffSignAdd' }, -- file is added in both working tree and index
      ['D '] = { symbol = '−', hl_group = 'MiniDiffSignDelete' }, -- Deleted from the staging area
      ['AM'] = { symbol = '⊕', hl_group = 'MiniDiffSignChange' }, -- added in working tree, modified in index
      ['AD'] = { symbol = '⊖', hl_group = 'MiniDiffSignChange' }, -- Added in the index and deleted in the working directory
      ['R '] = { symbol = '➜', hl_group = 'MiniDiffSignChange' }, -- Renamed in the index
      ['U '] = { symbol = '‼', hl_group = 'MiniDiffSignChange' }, -- Unmerged path
      ['UU'] = { symbol = '⇆', hl_group = 'MiniDiffSignAdd' }, -- file is unmerged
      ['UA'] = { symbol = '⊗', hl_group = 'MiniDiffSignAdd' }, -- file is unmerged and added in working tree
      ['??'] = { symbol = '?', hl_group = 'MiniDiffSignDelete' }, -- Untracked files
      ['!!'] = { symbol = '!', hl_group = 'MiniDiffSignChange' }, -- Ignored files
    }

    local result = status_map[status] or { symbol = '?', hl_group = 'NonText' }
    local symbol = result.symbol
    local hl_group = result.hl_group

    if symlink then
      symbol = '@' .. symbol
      hl_group = 'MiniDiffSignDelete'
    end

    return symbol, hl_group
  end

  ---Fetch Git status for a repository root.
  ---@param repo_root string
  ---@param callback fun(stdout: string)
  local function fetch_git_status(repo_root, callback)
    ---Handle Git status command output.
    ---@param result table
    local function handle_result(result)
      if result.code == 0 and type(result.stdout) == 'string' then
        callback(result.stdout)
      end
    end

    vim.system({ 'git', 'status', '--ignored', '--porcelain' }, { text = true, cwd = repo_root }, handle_result)
  end

  ---Parse Git porcelain output into a map of relative path -> status.
  ---Also propagate a status marker to parent directories.
  ---@param content string
  ---@return table<string, string>
  local function parse_git_status(content)
    ---@type table<string, string>
    local git_status_map = {}

    for line in content:gmatch '[^\r\n]+' do
      local status, file_path = string.match(line, '^(..)%s+(.*)')
      if status and file_path then
        local parts = {}
        for part in file_path:gmatch '[^/]+' do
          table.insert(parts, part)
        end

        local current_key = ''
        for i, part in ipairs(parts) do
          if i > 1 then
            current_key = current_key .. '/' .. part
          else
            current_key = part
          end

          if i == #parts then
            git_status_map[current_key] = status
          elseif not git_status_map[current_key] then
            git_status_map[current_key] = status
          end
        end
      end
    end

    return git_status_map
  end

  ---Clear all Git overlay extmarks from a MiniFiles buffer.
  ---@param buf_id integer
  local function clear_git_marks(buf_id)
    pcall(vim.api.nvim_buf_clear_namespace, buf_id, ns_mini_files_git, 0, -1)
  end

  ---Apply Git overlay signs and highlights to a MiniFiles buffer.
  ---@param buf_id integer
  ---@param repo_root string
  ---@param git_status_map table<string, string>
  local function update_mini_with_git(buf_id, repo_root, git_status_map)
    ---Render Git overlay signs in the MiniFiles buffer.
    local function apply_git_marks()
      if not vim.api.nvim_buf_is_valid(buf_id) then
        return
      end

      clear_git_marks(buf_id)

      local line_count = vim.api.nvim_buf_line_count(buf_id)
      local escaped_repo_root = vim.pesc(vim.fs.normalize(repo_root))

      for i = 1, line_count do
        local ok, entry = pcall(MiniFiles.get_fs_entry, buf_id, i)
        if not ok or not entry or not entry.path then
          break
        end

        local relative_path = vim.fs.normalize(entry.path):gsub('^' .. escaped_repo_root .. '/', '')
        local status = git_status_map[relative_path]

        if status then
          local sign_text, hl_group = map_symbols(status, is_symlink(entry.path))

          vim.api.nvim_buf_set_extmark(buf_id, ns_mini_files_git, i - 1, 0, {
            sign_text = sign_text,
            sign_hl_group = hl_group,
            priority = 2,
          })

          local line = vim.api.nvim_buf_get_lines(buf_id, i - 1, i, false)[1]
          if line then
            local name_start_col = line:find(vim.pesc(entry.name)) or 0
            if name_start_col > 0 then
              vim.api.nvim_buf_set_extmark(buf_id, ns_mini_files_git, i - 1, name_start_col - 1, {
                end_col = name_start_col + #entry.name - 1,
                hl_group = hl_group,
              })
            end
          end
        end
      end
    end

    vim.schedule(apply_git_marks)
  end

  ---Update Git overlay for a MiniFiles buffer, using cache when possible.
  ---@param buf_id integer
  local function update_git_status(buf_id)
    local mini_dir = get_mini_dir(buf_id)
    if not mini_dir then
      clear_git_marks(buf_id)
      return
    end

    local repo_root = get_repo_root(mini_dir)
    if not repo_root then
      clear_git_marks(buf_id)
      return
    end

    local now = now_ms()
    local cached = git_status_cache[repo_root]

    if cached and (now - cached.time_ms) < cache_timeout_ms then
      update_mini_with_git(buf_id, repo_root, cached.status_map)
      return
    end

    ---Handle Git status refresh and update overlays.
    ---@param content string
    local function on_git_status(content)
      local git_status_map = parse_git_status(content)
      git_status_cache[repo_root] = {
        time_ms = now_ms(),
        status_map = git_status_map,
      }
      update_mini_with_git(buf_id, repo_root, git_status_map)
    end

    fetch_git_status(repo_root, on_git_status)
  end

  ---Clear cached Git status.
  local function clear_cache()
    git_status_cache = {}
  end

  ---Handle MiniFilesExplorerOpen events.
  local function on_explorer_open()
    local buf_id = vim.api.nvim_get_current_buf()
    update_git_status(buf_id)
  end

  ---Handle MiniFilesExplorerClose events.
  local function on_explorer_close()
    clear_cache()
  end

  ---Handle MiniFilesBufferUpdate events.
  ---@param args table
  local function on_buffer_update(args)
    local buf_id = args.data.buf_id
    update_git_status(buf_id)
  end

  vim.api.nvim_create_autocmd('User', {
    group = augroup 'start',
    pattern = 'MiniFilesExplorerOpen',
    callback = on_explorer_open,
  })

  vim.api.nvim_create_autocmd('User', {
    group = augroup 'close',
    pattern = 'MiniFilesExplorerClose',
    callback = on_explorer_close,
  })

  vim.api.nvim_create_autocmd('User', {
    group = augroup 'update',
    pattern = 'MiniFilesBufferUpdate',
    callback = on_buffer_update,
  })
end

return M
