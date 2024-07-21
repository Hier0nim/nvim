return {
  'stevearc/oil.nvim',
  opts = {},
  -- Optional dependencies
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  config = function()
    require('oil').setup {

      default_file_explorer = true,
      delete_to_thrash = true,
      view_options = {
        show_hidden = true,
        is_always_hidden = function(name, _)
          return name == '.git' or name == '..'
        end,
        natural_order = true,
      },
    }
  end,
}
