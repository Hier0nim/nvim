return {
  {
    'snacks.nvim',
    auto_enable = true,
    lazy = false,
    priority = 1000,
    ---Configure Snacks and related keymaps.
    after = function()
      require('util.lazygit').setup(nixInfo)

      require('snacks').setup {
        bigfile = {},
        quickfile = {},
        words = {},
        gitbrowse = {},
        rename = {},
        dim = {},
        zen = {},
        picker = {},
        git = {},
        terminal = {},
        scope = {},
        toggle = {},
        input = {},
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
            patterns = { 'GitSign' },
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

      -- Find
      vim.keymap.set('n', '<leader>ff', Snacks.picker.smart, { desc = 'Find files' })
      vim.keymap.set('n', '<leader>fg', Snacks.picker.grep, { desc = 'Grep' })
      vim.keymap.set({ 'n', 'x' }, '<leader>fw', Snacks.picker.grep_word, { desc = 'Grep word/selection' })
      vim.keymap.set('n', '<leader>fr', Snacks.picker.recent, { desc = 'Recent files' })
      vim.keymap.set('n', '<leader>fb', Snacks.picker.buffers, { desc = 'Buffers' })
      vim.keymap.set('n', '<leader>fs', Snacks.picker.lsp_symbols, { desc = 'Document symbols' })
      vim.keymap.set('n', '<leader>fS', Snacks.picker.lsp_workspace_symbols, { desc = 'Workspace symbols' })
      vim.keymap.set('n', '<leader>fd', Snacks.picker.diagnostics, { desc = 'Diagnostics' })
      vim.keymap.set('n', '<leader>fD', Snacks.picker.diagnostics_buffer, { desc = 'Buffer diagnostics' })
      vim.keymap.set('n', '<leader>fj', Snacks.picker.jumps, { desc = 'Jumps' })
      vim.keymap.set('n', '<leader>fm', Snacks.picker.marks, { desc = 'Marks' })
      vim.keymap.set('n', '<leader>fk', Snacks.picker.keymaps, { desc = 'Keymaps' })
      vim.keymap.set('n', '<leader>fh', Snacks.picker.help, { desc = 'Help pages' })
      vim.keymap.set('n', '<leader>fu', Snacks.picker.undo, { desc = 'Undo history' })
      vim.keymap.set('n', '<leader>fR', Snacks.picker.resume, { desc = 'Resume picker' })
      vim.keymap.set('n', '<leader>fG', Snacks.picker.git_files, { desc = 'Git files' })
      vim.keymap.set('n', '<leader>fl', Snacks.picker.lines, { desc = 'Buffer lines' })
      vim.keymap.set('n', '<leader>fB', Snacks.picker.grep_buffers, { desc = 'Grep open buffers' })

      -- Git
      vim.keymap.set('n', '<leader>gg', Snacks.lazygit.open, { desc = 'LazyGit' })
      vim.keymap.set({ 'n', 'v' }, '<leader>gB', Snacks.gitbrowse.open, { desc = 'Git browse' })

      -- Terminal
      vim.keymap.set('n', '<C-\\>', Snacks.terminal.open, { desc = 'Terminal' })

      -- References
      vim.keymap.set('n', ']r', function() Snacks.words.jump(vim.v.count1) end, { desc = 'Next reference' })
      vim.keymap.set('n', '[r', function() Snacks.words.jump(-vim.v.count1) end, { desc = 'Prev reference' })

      -- Code
      vim.keymap.set('n', '<leader>cR', Snacks.rename.rename_file, { desc = 'Rename file' })

      -- Explorer
      vim.keymap.set('n', '<leader>e', function()
        require('mini.files').open(vim.fn.getcwd(), true)
      end, { desc = 'Open working directory' })

      -- UI toggles
      vim.keymap.set('n', '<leader>uz', function() Snacks.zen() end, { desc = 'Zen mode' })
      vim.keymap.set('n', '<leader>uZ', function() Snacks.zen.zoom() end, { desc = 'Zen zoom' })

      Snacks.toggle.option('spell', { name = 'Spelling' }):map '<leader>us'
      Snacks.toggle.option('wrap', { name = 'Wrap' }):map '<leader>uw'
      Snacks.toggle.option('relativenumber', { name = 'Relative number' }):map '<leader>uL'
      Snacks.toggle.diagnostics():map '<leader>ud'
      Snacks.toggle.line_number():map '<leader>ul'
      Snacks.toggle.treesitter():map '<leader>uT'
      Snacks.toggle.inlay_hints():map '<leader>uh'
      Snacks.toggle.dim():map '<leader>uD'
    end,
  },
}
