return {
  {
    'snacks.nvim',
    auto_enable = true,
    lazy = false,
    priority = 1000,
    ---Configure Snacks and related keymaps.
    after = function()
      vim.api.nvim_set_hl(0, 'MySnacksIndent', { fg = '#32a88f' })

      require('util.lazygit').setup(nixInfo)

      require('snacks').setup {
        picker = {},
        git = {},
        terminal = {},
        scope = {},
        indent = {
          scope = {
            hl = 'MySnacksIndent',
          },
          chunk = {
            hl = 'MySnacksIndent',
          },
        },
        statuscolumn = {
          left = { 'mark', 'git' },
          right = { 'sign', 'fold' },
          folds = {
            open = false,
            git_hl = false,
          },
          git = {
            patterns = { 'GitSign', 'MiniDiffSign' },
          },
          refresh = 50,
        },
        lazygit = {
          config = {
            os = {
              editPreset = 'nvim-remote',
              edit = vim.v.progpath
                .. [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{filename}})<CR>']=],
              editAtLine = vim.v.progpath
                .. [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{filename}}, {{line}})<CR>']=],
              openDirInEditor = vim.v.progpath
                .. [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{dir}})<CR>']=],
              editAtLineAndWait = nixInfo(vim.v.progpath, 'progpath') .. ' +{{line}} {{filename}}',
            },
          },
        },
      }

      vim.keymap.set('n', '<leader>_', Snacks.lazygit.open, { desc = 'Snacks lazygit' })
      vim.keymap.set('n', '<C-\\>', Snacks.terminal.open, { desc = 'Snacks terminal' })

      vim.keymap.set('n', '<leader>sf', Snacks.picker.smart, { desc = 'Smart find files' })
      vim.keymap.set('n', '<leader><leader>s', Snacks.picker.buffers, { desc = 'Search buffers' })
      vim.keymap.set('n', 'ff', Snacks.picker.files, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fg', Snacks.picker.git_files, { desc = 'Find git files' })
      vim.keymap.set('n', '<leader>sb', Snacks.picker.lines, { desc = 'Buffer lines' })
      vim.keymap.set('n', '<leader>sB', Snacks.picker.grep_buffers, { desc = 'Grep open buffers' })
      vim.keymap.set('n', '<leader>sg', Snacks.picker.grep, { desc = 'Grep' })
      vim.keymap.set({ 'n', 'x' }, '<leader>sw', Snacks.picker.grep_word, { desc = 'Search current word' })
      vim.keymap.set('n', '<leader>sd', Snacks.picker.diagnostics, { desc = 'Diagnostics' })
      vim.keymap.set('n', '<leader>sD', Snacks.picker.diagnostics_buffer, { desc = 'Buffer diagnostics' })
      vim.keymap.set('n', '<leader>sh', Snacks.picker.help, { desc = 'Help pages' })
      vim.keymap.set('n', '<leader>sj', Snacks.picker.jumps, { desc = 'Jumps' })
      vim.keymap.set('n', '<leader>sk', Snacks.picker.keymaps, { desc = 'Keymaps' })
      vim.keymap.set('n', '<leader>sl', Snacks.picker.loclist, { desc = 'Location list' })
      vim.keymap.set('n', '<leader>sm', Snacks.picker.marks, { desc = 'Marks' })
      vim.keymap.set('n', '<leader>sM', Snacks.picker.man, { desc = 'Man pages' })
      vim.keymap.set('n', '<leader>sq', Snacks.picker.qflist, { desc = 'Quickfix list' })
      vim.keymap.set('n', '<leader>sR', Snacks.picker.resume, { desc = 'Resume picker' })
      vim.keymap.set('n', '<leader>su', Snacks.picker.undo, { desc = 'Undo history' })
    end,
  },
}
