return {
  {
    'fff.nvim',
    for_cat = 'general.telescope',
    lazy = false,
    keys = { {
      'ff',
      function()
        require('fff').find_files()
      end,
      mode = { 'n' },
      desc = 'FFFind files',
    } },

    after = function(plugin)
      require('fff').setup {
        prompt = '> ',
        layout = {
          height = 0.8,
          width = 0.8,
          prompt_position = 'top', -- or 'top'
          preview_position = 'bottom', -- or 'left', 'right', 'top', 'bottom'
          preview_size = 0.5,
        },
      }
    end,
  },
}
