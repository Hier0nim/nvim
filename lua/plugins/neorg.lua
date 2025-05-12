return {
  'nvim-neorg/neorg',
  lazy = false,
  version = '*',
  config = function()
    require('neorg').setup {
      load = {
        ['core.defaults'] = {},
        ['core.keybinds'] = {
          config = {
            default_keybinds = false, -- turn off all defaults
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
        -- ['core.completion'] = {
        --   config = { engine = { module_name = 'external.lsp-completion' } },
        -- },
        -- ['external.interim-ls'] = {
        --   config = {
        --     completion_provider = {
        --       enable = true,
        --       documentation = true,
        --       categories = false,
        --     },
        --   },
        -- },
      },
    }

    local wk = require 'which-key'
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'norg',
      callback = function()
        wk.add({
          { '<LocalLeader>n', name = 'Notes', mode = 'n' },
          { '<LocalLeader>nn', '<Plug>(neorg.dirman.new-note)', desc = 'New note', mode = 'n' },
          { '<LocalLeader>no', ':Neorg toc<CR>', desc = 'Table of Contents', mode = 'n' },

          { '<LocalLeader>t', name = 'To-do', mode = 'n' },
          { '<LocalLeader>tu', '<Plug>(neorg.qol.todo-items.todo.task-undone)', desc = 'Mark undone' },
          { '<LocalLeader>tp', '<Plug>(neorg.qol.todo-items.todo.task-pending)', desc = 'Mark pending' },
          { '<LocalLeader>td', '<Plug>(neorg.qol.todo-items.todo.task-done)', desc = 'Mark done' },
          { '<LocalLeader>th', '<Plug>(neorg.qol.todo-items.todo.task-on-hold)', desc = 'Mark on hold' },
          { '<LocalLeader>tc', '<Plug>(neorg.qol.todo-items.todo.task-cancelled)', desc = 'Mark cancelled' },
          { '<LocalLeader>tr', '<Plug>(neorg.qol.todo-items.todo.task-recurring)', desc = 'Mark recurring' },
          { '<LocalLeader>ti', '<Plug>(neorg.qol.todo-items.todo.task-important)', desc = 'Mark important' },
          { '<LocalLeader>ta', '<Plug>(neorg.qol.todo-items.todo.task-ambiguous)', desc = 'Mark ambiguous' },
          { '<C-Space>', '<Plug>(neorg.qol.todo-items.todo.task-cycle)', desc = 'Cycle status' },

          { '<LocalLeader>p', name = 'Promote/Demote', mode = { 'n', 'v', 'i' } },
          { '<LocalLeader>p.', '<Plug>(neorg.promo.promote)', desc = 'Promote', mode = 'n' },
          { '<LocalLeader>p,', '<Plug>(neorg.promo.demote)', desc = 'Demote', mode = 'n' },
          { '<LocalLeader>p>>', '<Plug>(neorg.promo.promote.nested)', desc = 'Promote nested', mode = 'n' },
          { '<LocalLeader>p<<', '<Plug>(neorg.promo.demote.nested)', desc = 'Demote nested', mode = 'n' },
          { '<LocalLeader>p>', '<Plug>(neorg.promo.promote.range)', desc = 'Promote range', mode = 'v' },
          { '<LocalLeader>p<', '<Plug>(neorg.promo.demote.range)', desc = 'Demote range', mode = 'v' },
          { '<LocalLeader>p<C-t>', '<Plug>(neorg.promo.promote)', desc = 'Promote (insert)', mode = 'i' },
          { '<LocalLeader>p<C-d>', '<Plug>(neorg.promo.demote)', desc = 'Demote (insert)', mode = 'i' },

          { '<LocalLeader>l', name = 'Lists', mode = 'n' },
          { '<LocalLeader>lt', '<Plug>(neorg.pivot.list.toggle)', desc = 'Toggle un/ordered.', mode = 'n' },
          { '<LocalLeader>li', '<Plug>(neorg.pivot.list.invert)', desc = 'Invert list', mode = 'n' },

          { '<LocalLeader>d', name = 'Dates', mode = { 'n', 'i' } },
          { '<LocalLeader>dd', '<Plug>(neorg.tempus.insert-date)', desc = 'Insert date', mode = 'n' },
          { '<LocalLeader>dM-d', '<Plug>(neorg.tempus.insert-date.insert-mode)', desc = 'Insert date (ins)', mode = 'i' },

          { '<LocalLeader>o', name = 'Other', mode = 'n' },
          { '<LocalLeader>oc', '<Plug>(neorg.looking-glass.magnify-code-block)', desc = 'Magnify code', mode = 'n' },
          { '<LocalLeader>ol', '<Plug>(neorg.esupports.hop.hop-link)', desc = 'Follow link', mode = 'n' },
          { '<LocalLeader>ov', '<Plug>(neorg.esupports.hop.hop-link.vsplit)', desc = 'Link vsplit', mode = 'n' },
          { '<LocalLeader>ot', '<Plug>(neorg.esupports.hop.hop-link.tab-drop)', desc = 'Link tab', mode = 'n' },
          { '<LocalLeader>cc', ':Neorg toggle-concealer<CR>', desc = 'Toggle concealer', mode = 'n' },
        }, { buffer = true })
      end,
    })
  end,
}
