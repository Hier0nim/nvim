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
      vim.keymap.set('n', '<leader>rr', function() require('easy-dotnet').run_default() end, { desc = 'Run default project' })
      vim.keymap.set('n', '<leader>rd', function() require('easy-dotnet').run_default_debug() end, { desc = 'Debug default project' })
      vim.keymap.set('n', '<leader>rb', function() require('easy-dotnet').build_default() end, { desc = 'Build default project' })
      vim.keymap.set('n', '<leader>rw', function() require('easy-dotnet').watch_default() end, { desc = 'Watch default project' })
      vim.keymap.set('n', '<leader>rs', function() require('easy-dotnet').stop() end, { desc = 'Stop running job' })
      vim.keymap.set('n', '<leader>rm', '<cmd>Dotnet<CR>', { desc = 'Dotnet action menu' })

      -- Tests
      vim.keymap.set('n', '<leader>tt', function() require('easy-dotnet').test_runner() end, { desc = 'Toggle test runner' })
      vim.keymap.set('n', '<leader>tr', function() require('easy-dotnet').test_run_nearest() end, { desc = 'Run nearest test' })
      vim.keymap.set('n', '<leader>td', function() require('easy-dotnet').test_debug_nearest() end, { desc = 'Debug nearest test' })
    end,
  },
}
