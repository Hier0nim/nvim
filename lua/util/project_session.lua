local M = {}

---Return names of all modified buffers which would be lost during a workspace switch.
---@return string[]
local function modified_buffers()
  local names = {}
  for _, buffer in ipairs(vim.fn.getbufinfo()) do
    if buffer.changed == 1 then
      names[#names + 1] = buffer.name == '' and ('[No Name] (%d)'):format(buffer.bufnr) or buffer.name
    end
  end
  return names
end

---@param path string
---@return string
local function absolute_path(path)
  return vim.fn.fnamemodify(path, ':p')
end

---@param dir string
---@param sessions table
---@param restore boolean
---@param session_file string
local function open_project(dir, sessions, restore, session_file)
  local modified = modified_buffers()
  if #modified > 0 then
    vim.notify(('Unsaved buffers: %s'):format(table.concat(modified, ', ')), vim.log.levels.ERROR)
    return
  end

  if restore and vim.fn.filereadable(session_file) == 0 then
    vim.notify(('No mini.sessions session at %s'):format(session_file), vim.log.levels.WARN)
    return
  end

  if vim.v.this_session ~= '' then
    local saved, save_err = pcall(sessions.write, nil, { force = true, verbose = false })
    if not saved then
      vim.notify(('Could not save the active session: %s'):format(save_err), vim.log.levels.ERROR)
      return
    end
  end

  -- Detach before changing cwd so a failed switch cannot overwrite the outgoing session.
  vim.v.this_session = ''
  local opened, open_err = pcall(function()
    vim.fn.chdir(dir)
    if restore then
      sessions.read(sessions.config.file, { force = false })
      if absolute_path(vim.v.this_session) ~= absolute_path(session_file) then
        error(('mini.sessions did not restore %s'):format(session_file))
      end
      return
    end

    vim.cmd 'silent! %bwipeout!'
    vim.cmd.enew()
    -- Let MiniSessions autowrite this clean repository-local workspace on exit.
    vim.v.this_session = session_file
  end)

  if not opened then
    vim.v.this_session = ''
    vim.notify(('Could not open project: %s'):format(open_err), vim.log.levels.ERROR)
  end
end

---Prompt before opening a recent repository so sessions are never restored implicitly.
---@param dir string
function M.select_project(dir)
  local sessions = require 'mini.sessions'
  local session_file = vim.fs.joinpath(dir, sessions.config.file)
  local choices = {
    { label = 'Open clean', restore = false },
    { label = 'Restore session', restore = true },
  }

  vim.ui.select(choices, {
    prompt = ('Open %s'):format(vim.fn.fnamemodify(dir, ':~')),
    format_item = function(choice)
      return choice.label
    end,
  }, function(choice)
    if choice then
      open_project(dir, sessions, choice.restore, session_file)
    end
  end)
end

return M
