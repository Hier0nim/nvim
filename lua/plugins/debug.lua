return {
  {
    'nvim-nio',
    auto_enable = true,
    dep_of = { 'nvim-dap-ui' },
  },
  {
    'nvim-dap-ui',
    auto_enable = true,
    dep_of = { 'nvim-dap' },
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
    keys = {
      { '<F5>', desc = 'DAP continue / start' },
      { '<leader>db', desc = 'DAP toggle breakpoint' },
    },
    ---Configure DAP keymaps.
    after = function()
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

      vim.keymap.set('n', '<leader>du', function() require('dapui').toggle() end, { desc = 'DAP toggle UI' })
      vim.keymap.set({ 'n', 'x' }, '<leader>de', function() require('dapui').eval() end, { desc = 'DAP evaluate expression' })
    end,
  },
}
