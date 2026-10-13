local M = {}

---Set up helper functions for Snacks lazygit integration.
---@param nixInfo table
function M.setup(nixInfo)
  ---Hide the Snacks terminal shown in the current window without stopping its job.
  ---@return boolean hidden true when a Snacks terminal window was hidden
  local function hide_current_terminal()
    local buf = vim.api.nvim_get_current_buf()
    for _, term in ipairs(Snacks.terminal.list()) do
      if term.buf == buf and term:win_valid() then
        vim.cmd.stopinsert()
        term:hide()
        return true
      end
    end
    return false
  end

  ---Reopen a file requested by lazygit in the previous editing context.
  ---
  ---Hides the lazygit window (lazygit keeps running) and opens the file.
  ---Falls back to the current window if the previous buffer or window is not valid.
  ---@param path string
  ---@param line integer|nil
  function nixInfo.lazygit_fix(path, line)
    local prev = vim.fn.bufnr '#'
    local prev_win = vim.fn.bufwinid(prev)
    hide_current_terminal()
    -- TermClose no longer fires, so refresh buffers changed by lazygit here.
    vim.cmd.checktime()

    local has_prev_buf = prev ~= -1 and vim.api.nvim_buf_is_valid(prev)
    local has_prev_win = prev_win ~= -1 and vim.api.nvim_win_is_valid(prev_win)

    ---Move the cursor to the requested line in the current window, if provided.
    local function set_cursor_if_needed()
      if line then
        vim.api.nvim_win_set_cursor(0, { line, 0 })
      end
    end

    if not has_prev_buf then
      vim.cmd.edit(path)
      set_cursor_if_needed()
      return
    end

    ---Reopen the file within the previous buffer context.
    local function edit_in_prev_buf()
      vim.cmd.edit(path)
      local buf = vim.api.nvim_get_current_buf()

      ---Restore the original window when possible.
      local function restore_window()
        if has_prev_win and vim.api.nvim_win_is_valid(prev_win) and buf and vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_win_set_buf(prev_win, buf)
          if line then
            vim.api.nvim_win_set_cursor(prev_win, { line, 0 })
          end
        else
          set_cursor_if_needed()
        end
      end

      vim.schedule(restore_window)
    end

    vim.api.nvim_buf_call(prev, edit_in_prev_buf)
  end
end

return M
