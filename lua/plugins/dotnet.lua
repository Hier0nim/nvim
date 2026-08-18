return {
  {
    'easy-dotnet.nvim',
    auto_enable = true,
    ft = { 'cs', 'csproj', 'fsproj', 'sln' },
    cmd = { 'Dotnet' },
    ---Configure easy-dotnet.nvim.
    after = function()
      vim.cmd.packadd('nvim-dap')

      require('easy-dotnet').setup {
        picker = 'snacks',
        lsp = {
          enabled = true,
          set_fold_expr = false,
          preload_roslyn = true,
          roslynator_enabled = true,
          easy_dotnet_analyzer_enabled = true,
          auto_refresh_codelens = true,
        },
        debugger = {
          auto_register_dap = true,
          console = 'integratedTerminal',
          apply_value_converters = true,
          bin_path = nil,
          engine = 'netcoredbg',
        },
        test_runner = {
          auto_start_testrunner = true,
          viewmode = 'float',
          mappings = {
            -- Buffer integration (source files)
            run_test_from_buffer = { lhs = '<leader>tr', desc = 'Run test from buffer' },
            run_all_tests_from_buffer = { lhs = '<leader>ta', desc = 'Run all tests in file' },
            get_build_errors = { lhs = '<leader>te', desc = 'Get build errors' },
            peek_stack_trace_from_buffer = { lhs = '<leader>tp', desc = 'Peek stack trace' },
            debug_test_from_buffer = { lhs = '<leader>td', desc = 'Debug test from buffer' },
            -- Test runner window
            debug_test = { lhs = 'd', desc = 'Debug test' },
            go_to_file = { lhs = 'g', desc = 'Go to file' },
            run_all = { lhs = 'R', desc = 'Run all tests' },
            run = { lhs = 'r', desc = 'Run test' },
            peek_stacktrace = { lhs = 'p', desc = 'Peek stacktrace' },
            expand = { lhs = 'o', desc = 'Expand' },
            expand_node = { lhs = 'E', desc = 'Expand node' },
            collapse_all = { lhs = 'W', desc = 'Collapse all' },
            close = { lhs = 'q', desc = 'Close test runner' },
            refresh_testrunner = { lhs = '<C-r>', desc = 'Refresh' },
            cancel = { lhs = '<C-c>', desc = 'Cancel' },
            next_failure = { lhs = ']f', desc = 'Next failing test' },
            prev_failure = { lhs = '[f', desc = 'Previous failing test' },
          },
        },
        projx_lsp = { enabled = true },
        csproj_mappings = true,
        fsproj_mappings = true,
        auto_bootstrap_namespace = {
          type = 'block_scoped',
          enabled = true,
        },
      }

      -- Buffer-local .NET run/test keymaps
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('DotnetKeymaps', { clear = true }),
        pattern = { 'cs', 'csproj', 'fsproj', 'sln' },
        desc = 'Buffer-local .NET keymaps',
        callback = function(args)
          local opts = { buffer = args.buf }

          vim.keymap.set('n', '<leader>rr', '<cmd>Dotnet run<CR>',
            vim.tbl_extend('force', opts, { desc = 'Run default project' }))
          vim.keymap.set('n', '<leader>rd', '<cmd>Dotnet run debug<CR>',
            vim.tbl_extend('force', opts, { desc = 'Debug default project' }))
          vim.keymap.set('n', '<leader>rb', '<cmd>Dotnet build<CR>',
            vim.tbl_extend('force', opts, { desc = 'Build default project' }))
          vim.keymap.set('n', '<leader>rw', '<cmd>Dotnet watch<CR>',
            vim.tbl_extend('force', opts, { desc = 'Watch default project' }))
          vim.keymap.set('n', '<leader>rs', '<cmd>Dotnet stop<CR>',
            vim.tbl_extend('force', opts, { desc = 'Stop running job' }))
          vim.keymap.set('n', '<leader>rm', '<cmd>Dotnet<CR>',
            vim.tbl_extend('force', opts, { desc = 'Dotnet action menu' }))
          vim.keymap.set('n', '<leader>tt', '<cmd>Dotnet testrunner<CR>',
            vim.tbl_extend('force', opts, { desc = 'Toggle test runner' }))
        end,
      })

      -- Trigger for current buffer if it matches
      local ft = vim.bo.filetype
      if ft == 'cs' or ft == 'csproj' or ft == 'fsproj' or ft == 'sln' then
        vim.api.nvim_exec_autocmds('FileType', { pattern = ft })
      end
    end,
  },
}
