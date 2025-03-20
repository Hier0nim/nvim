return {
  'nvim-neorg/neorg',
  lazy = false,
  version = '*',
  config = function()
    require('neorg').setup {
      load = {
        ['core.defaults'] = {},
        ['core.concealer'] = { config = { folds = true, icon_preset = 'diamond' } }, -- Adds pretty icons to your documents
        ['core.dirman'] = {
          config = {
            workspaces = {
              notes = '~/SecondBrain',
            },
            default_workspace = 'notes',
          },
        },
      },
    }
  end,
}
