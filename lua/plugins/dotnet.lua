return {
  {
    'nvim-nio',
    auto_enable = true,
    dep_of = { 'nvim-dap-ui' },
  },
  {
    'nvim-dap-ui',
    auto_enable = true,
    dep_of = { 'easy-dotnet.nvim' },
    after = function()
      vim.cmd.packadd('nvim-nio')
      local dapui = require 'dapui'
      dapui.setup()

      local dap = require 'dap'
      dap.listeners.after.event_initialized['dapui_config'] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated['dapui_config'] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited['dapui_config'] = function()
        dapui.close()
      end
    end,
  },
  {
    'nvim-dap',
    auto_enable = true,
    dep_of = { 'easy-dotnet.nvim' },
  },
  {
    'easy-dotnet.nvim',
    auto_enable = true,
    ft = { 'cs', 'csproj', 'fsproj', 'sln' },
    cmd = { 'Dotnet' },
    ---Configure easy-dotnet.nvim.
    after = function()
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

      -- DAP keymaps
      local dap = require 'dap'
      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'DAP continue / start' })
      vim.keymap.set('n', '<F10>', dap.step_over, { desc = 'DAP step over' })
      vim.keymap.set('n', '<F11>', dap.step_into, { desc = 'DAP step into' })
      vim.keymap.set('n', '<F12>', dap.step_out, { desc = 'DAP step out' })
      vim.keymap.set('n', '<leader>db', dap.toggle_breakpoint, { desc = 'DAP toggle breakpoint' })
      vim.keymap.set('n', '<leader>dB', function()
        dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
      end, { desc = 'DAP conditional breakpoint' })
      vim.keymap.set('n', '<leader>dr', dap.repl.open, { desc = 'DAP open REPL' })
      vim.keymap.set('n', '<leader>dl', dap.run_last, { desc = 'DAP run last' })
      vim.keymap.set('n', '<leader>dx', dap.terminate, { desc = 'DAP terminate' })
      vim.keymap.set('n', '<leader>dc', dap.run_to_cursor, { desc = 'DAP run to cursor' })

      -- DAP UI keymaps
      vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, { desc = 'DAP toggle UI' })
      vim.keymap.set({ 'n', 'x' }, '<leader>de', function() require('dapui').eval() end, { desc = 'DAP evaluate expression' })

      -- Run and build
      vim.keymap.set('n', '<leader>rr', '<cmd>Dotnet run<CR>', { desc = 'Run default project' })
      vim.keymap.set('n', '<leader>rd', '<cmd>Dotnet run debug<CR>', { desc = 'Debug default project' })
      vim.keymap.set('n', '<leader>rb', '<cmd>Dotnet build<CR>', { desc = 'Build default project' })
      vim.keymap.set('n', '<leader>rw', '<cmd>Dotnet watch<CR>', { desc = 'Watch default project' })
      vim.keymap.set('n', '<leader>rs', '<cmd>Dotnet stop<CR>', { desc = 'Stop running job' })
      vim.keymap.set('n', '<leader>rm', '<cmd>Dotnet<CR>', { desc = 'Dotnet action menu' })

      -- Tests
      vim.keymap.set('n', '<leader>tt', '<cmd>Dotnet testrunner<CR>', { desc = 'Toggle test runner' })
    end,
  },
}
