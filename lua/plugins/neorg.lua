return {
  {
    'nvim-neorg/neorg',
    lazy = false,
    version = '*',
    dependencies = {
      'benlubas/neorg-interim-ls',
      'nvim-neorg/lua-utils.nvim',
      'pysan3/pathlib.nvim',
      'nvim-neotest/nvim-nio',
    },
    config = function()
      require('neorg').setup {
        load = {
          ['core.defaults'] = {},
          ['core.keybinds'] = {
            config = {
              default_keybinds = true, -- turn off all defaults
            },
          },
          ['core.concealer'] = { config = { folds = true, icon_preset = 'diamond' } },
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
          ['core.export'] = {},
          ['core.export.markdown'] = {},
          ['core.completion'] = {
            config = { engine = { module_name = 'external.lsp-completion' } },
          },
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

      local wk = require 'which-key'
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'norg',
        callback = function()
          wk.add({
            { '<LocalLeader>n', name = 'Notes', mode = 'n' },
            { '<LocalLeader>no', ':Neorg toc<CR>', desc = 'Table of Contents', mode = 'n' },

            { '<LocalLeader>t', name = 'To-do', mode = 'n' },

            { '<LocalLeader>l', name = 'Lists', mode = 'n' },

            { '<LocalLeader>i', name = 'Insert', mode = { 'n', 'i' } },

            { '<LocalLeader>o', name = 'Code', mode = 'n' },

            { '<LocalLeader>c', ':Neorg toggle-concealer<CR>', desc = 'Toggle concealer', mode = 'n' },

            { '<LocalLeader>p', name = 'Promote/Demote', mode = { 'n', 'v', 'i' } },
            { '<LocalLeader>p.', '<Plug>(neorg.promo.promote)', desc = 'Promote', mode = 'n' },
            { '<LocalLeader>p,', '<Plug>(neorg.promo.demote)', desc = 'Demote', mode = 'n' },
            { '<LocalLeader>p>>', '<Plug>(neorg.promo.promote.nested)', desc = 'Promote nested', mode = 'n' },
            { '<LocalLeader>p<<', '<Plug>(neorg.promo.demote.nested)', desc = 'Demote nested', mode = 'n' },
            { '<LocalLeader>p>', '<Plug>(neorg.promo.promote.range)', desc = 'Promote range', mode = 'v' },
            { '<LocalLeader>p<', '<Plug>(neorg.promo.demote.range)', desc = 'Demote range', mode = 'v' },
            { '<LocalLeader>p<C-t>', '<Plug>(neorg.promo.promote)', desc = 'Promote (insert)', mode = 'i' },
            { '<LocalLeader>p<C-d>', '<Plug>(neorg.promo.demote)', desc = 'Demote (insert)', mode = 'i' },
          }, { buffer = true })
        end,
      })
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    dependencies = { 'nvim-neorg/neorg' },
    opts = function(_, opts)
      table.insert(opts.sources, { name = 'neorg' })
    end,
  },
}
