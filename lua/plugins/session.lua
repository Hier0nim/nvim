return {
  {
    'continue.nvim',
    event = 'VimEnter',
    ---Configure continue.nvim.
    after = function()
      require('continue').setup {
        picker = 'snacks',
      }

      ---Override continue.nvim picker to prefer Snacks.
      local function apply_continue_snacks_workaround()
        local picker_mod = require 'continue.pickers.picker'
        local snacks_picker = require 'continue.pickers.snacks'

        ---Dispatch picker requests through the Snacks integration when available.
        ---@param opts table
        ---@param _ any
        local function pick_with_snacks(opts, _)
          if snacks_picker.enabled and type(snacks_picker.pick) == 'function' then
            return snacks_picker.pick(opts)
          end

          vim.notify('continue.nvim: snacks picker is not usable', vim.log.levels.ERROR)
        end

        picker_mod.pick = pick_with_snacks
      end

      apply_continue_snacks_workaround()
    end,
  },
}
