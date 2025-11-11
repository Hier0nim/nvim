return {
  {
    'vimtex',
    lazy = false,
    for_cat = {
      cat = 'latex',
      default = false,
    },
    ft = { 'tex', 'bib' },
    before = function()
      vim.g.tex_flavor = 'latex'
      vim.g.vimtex_view_method = 'zathura'
      vim.g.quickfix_mode = 0
      vim.g.tex_conceal = 'abdmg'
    end,
    enabled = true,
  },
}
