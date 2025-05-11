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
            index = 'index.norg',
            workspaces = {
              personal = '~/SecondBrain/personal',
              work = '~/SecondBrain/work',
              uni = '~/SecondBrain/uni',
            },
            default_workspace = 'personal',
          },
        },
        ['core.completion'] = {
          config = { engine = { module_name = 'external.lsp-completion' } },
        },
        ['core.export'] = {},
        ['core.export.markdown'] = {},
        ['external.interim-ls'] = {
          config = {
            completion_provider = {
              enable = true,
              documentation = true,
              categories = false,
            },
          },
        },
      },
    }
  end,
}
