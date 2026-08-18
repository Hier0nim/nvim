return {
  {
    'nvim-dap-python',
    auto_enable = true,
    ft = 'python',
    ---Configure dap-python.
    after = function()
      vim.cmd.packadd('nvim-dap')
      require('dap-python').setup('python3')
    end,
  },
  {
    'neotest-python',
    auto_enable = true,
    dep_of = { 'neotest' },
  },
  {
    'neotest',
    auto_enable = true,
    ft = 'python',
    ---Configure neotest with Python adapter and buffer-local keymaps.
    after = function()
      local neotest = require 'neotest'

      neotest.setup {
        adapters = {
          require 'neotest-python' {
            dap = { justMyCode = false },
            runner = 'pytest',
          },
        },
      }

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('PythonKeymaps', { clear = true }),
        pattern = 'python',
        desc = 'Buffer-local Python keymaps',
        callback = function(args)
          local opts = { buffer = args.buf }

          vim.keymap.set('n', '<leader>tr', function() neotest.run.run() end,
            vim.tbl_extend('force', opts, { desc = 'Run nearest test' }))
          vim.keymap.set('n', '<leader>ta', function() neotest.run.run(vim.fn.expand '%') end,
            vim.tbl_extend('force', opts, { desc = 'Run file tests' }))
          vim.keymap.set('n', '<leader>td', function() neotest.run.run { strategy = 'dap' } end,
            vim.tbl_extend('force', opts, { desc = 'Debug nearest test' }))
          vim.keymap.set('n', '<leader>tt', function() neotest.summary.toggle() end,
            vim.tbl_extend('force', opts, { desc = 'Toggle test summary' }))
          vim.keymap.set('n', '<leader>to', function() neotest.output.open { enter = true } end,
            vim.tbl_extend('force', opts, { desc = 'Show test output' }))
          vim.keymap.set('n', '<leader>ts', function() neotest.run.stop() end,
            vim.tbl_extend('force', opts, { desc = 'Stop test' }))

          vim.keymap.set('n', '<leader>rr', '<cmd>!python3 %<CR>',
            vim.tbl_extend('force', opts, { desc = 'Run current file' }))
          vim.keymap.set('n', '<leader>rd', function() require('dap').continue() end,
            vim.tbl_extend('force', opts, { desc = 'Debug current file' }))
        end,
      })

      -- Trigger for current buffer if it's already a Python file
      if vim.bo.filetype == 'python' then
        vim.api.nvim_exec_autocmds('FileType', { pattern = 'python' })
      end
    end,
  },
}
