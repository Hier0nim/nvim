return {
  {
    'continue.nvim',
    event = 'VimEnter',
    after = function(_)
      require('continue').setup {
        picker = 'snacks',
      }

      do
        local picker_mod = require 'continue.pickers.picker'
        local snacks_picker = require 'continue.pickers.snacks'

        picker_mod.pick = function(opts, _)
          if snacks_picker.enabled and type(snacks_picker.pick) == 'function' then
            return snacks_picker.pick(opts)
          end

          vim.notify('continue.nvim: snacks picker is not usable', vim.log.levels.ERROR)
        end
      end
    end,
  },
}
