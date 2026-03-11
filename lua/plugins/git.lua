return {
  {
    'gitsigns.nvim',
    auto_enable = true,
    event = 'DeferredUIEnter',
    after = function()
      require('gitsigns').setup {
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '^' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, lhs, rhs, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, lhs, rhs, opts)
          end

          map({ 'n', 'v' }, ']c', function()
            if vim.wo.diff then
              return ']c'
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to next hunk' })

          map({ 'n', 'v' }, '[c', function()
            if vim.wo.diff then
              return '[c'
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to previous hunk' })

          map('v', '<leader>hs', function()
            gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'Stage git hunk' })

          map('v', '<leader>hr', function()
            gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'Reset git hunk' })

          map('n', '<leader>gs', gs.stage_hunk, { desc = 'Git stage hunk' })
          map('n', '<leader>gr', gs.reset_hunk, { desc = 'Git reset hunk' })
          map('n', '<leader>gS', gs.stage_buffer, { desc = 'Git stage buffer' })
          map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
          map('n', '<leader>gR', gs.reset_buffer, { desc = 'Git reset buffer' })
          map('n', '<leader>gp', gs.preview_hunk, { desc = 'Preview git hunk' })
          map('n', '<leader>gb', function()
            gs.blame_line { full = false }
          end, { desc = 'Git blame line' })
          map('n', '<leader>gd', gs.diffthis, { desc = 'Git diff against index' })
          map('n', '<leader>gD', function()
            gs.diffthis '~'
          end, { desc = 'Git diff against last commit' })

          map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'Toggle git blame line' })
          map('n', '<leader>gtd', gs.toggle_deleted, { desc = 'Toggle deleted lines' })

          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select git hunk' })
        end,
      }

      vim.cmd [[hi GitSignsAdd guifg=#04de21]]
      vim.cmd [[hi GitSignsChange guifg=#83fce6]]
      vim.cmd [[hi GitSignsDelete guifg=#fa2525]]
    end,
  },
}
