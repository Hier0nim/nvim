return {
  {
    'gitsigns.nvim',
    auto_enable = true,
    event = 'DeferredUIEnter',
    ---Configure gitsigns and its keymaps.
    after = function()
      ---Attach gitsigns keymaps to a buffer.
      ---@param bufnr integer
      local function on_attach(bufnr)
        local gs = package.loaded.gitsigns

        ---Create a buffer-local keymap.
        ---@param mode string|string[]
        ---@param lhs string
        ---@param rhs string|function
        ---@param opts table|nil
        local function map(mode, lhs, rhs, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, lhs, rhs, opts)
        end

        ---Jump to the next hunk, respecting diff mode.
        ---@return string
        local function next_hunk()
          if vim.wo.diff then
            return ']c'
          end
          vim.schedule(gs.next_hunk)
          return '<Ignore>'
        end

        ---Jump to the previous hunk, respecting diff mode.
        ---@return string
        local function prev_hunk()
          if vim.wo.diff then
            return '[c'
          end
          vim.schedule(gs.prev_hunk)
          return '<Ignore>'
        end

        ---Stage the hunk selected in visual mode.
        local function stage_visual_hunk()
          gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end

        ---Reset the hunk selected in visual mode.
        local function reset_visual_hunk()
          gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
        end

        ---Blame the current line.
        local function blame_line()
          gs.blame_line { full = false }
        end

        ---Diff against the last commit.
        local function diff_last_commit()
          gs.diffthis '~'
        end

        map({ 'n', 'v' }, ']c', next_hunk, { expr = true, desc = 'Jump to next hunk' })
        map({ 'n', 'v' }, '[c', prev_hunk, { expr = true, desc = 'Jump to previous hunk' })

        map('v', '<leader>hs', stage_visual_hunk, { desc = 'Stage git hunk' })
        map('v', '<leader>hr', reset_visual_hunk, { desc = 'Reset git hunk' })

        map('n', '<leader>gs', gs.stage_hunk, { desc = 'Git stage hunk' })
        map('n', '<leader>gr', gs.reset_hunk, { desc = 'Git reset hunk' })
        map('n', '<leader>gS', gs.stage_buffer, { desc = 'Git stage buffer' })
        map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
        map('n', '<leader>gR', gs.reset_buffer, { desc = 'Git reset buffer' })
        map('n', '<leader>gp', gs.preview_hunk, { desc = 'Preview git hunk' })
        map('n', '<leader>gb', blame_line, { desc = 'Git blame line' })
        map('n', '<leader>gd', gs.diffthis, { desc = 'Git diff against index' })
        map('n', '<leader>gD', diff_last_commit, { desc = 'Git diff against last commit' })

        map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'Toggle git blame line' })
        map('n', '<leader>gtd', gs.toggle_deleted, { desc = 'Toggle deleted lines' })

        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select git hunk' })
      end

      require('gitsigns').setup {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '^' },
          changedelete = { text = '~' },
        },
        on_attach = on_attach,
      }

      vim.cmd [[hi GitSignsAdd guifg=#04de21]]
      vim.cmd [[hi GitSignsChange guifg=#83fce6]]
      vim.cmd [[hi GitSignsDelete guifg=#fa2525]]
    end,
  },
}
