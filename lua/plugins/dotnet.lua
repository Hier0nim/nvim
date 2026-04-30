return {
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
      -- Register easy-dotnet as a blink.cmp source if blink is loaded.
      local ok, blink_config = pcall(require, 'blink.cmp.config')
      if ok then
        local provider_id = 'easy-dotnet'
        local provider_cfg = {
          name = 'easy-dotnet',
          module = 'easy-dotnet.completion.blink',
          score_offset = 10000,
          async = true,
        }
        blink_config.sources.providers[provider_id] = provider_cfg
        table.insert(blink_config.sources.default, provider_id)
        local sources_lib = require 'blink.cmp.sources.lib'
        sources_lib.providers[provider_id] = require('blink.cmp.sources.lib.provider').new(provider_id, provider_cfg)
      end

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
        },
        test_runner = {
          auto_start_testrunner = true,
          viewmode = 'float',
        },
        csproj_mappings = true,
        fsproj_mappings = true,
        auto_bootstrap_namespace = {
          type = 'block_scoped',
          enabled = true,
        },
        background_scanning = true,
      }

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
    end,
  },
}
