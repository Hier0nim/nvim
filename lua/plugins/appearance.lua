return {
  {
    'auto-dark-mode.nvim',
    auto_enable = true,
    lazy = false,
    ---Configure auto-dark-mode.nvim.
    after = function()
      require('auto-dark-mode').setup {
        set_dark_mode = function()
          vim.o.background = 'dark'
          vim.cmd.colorscheme 'kanagawa-paper-ink'
        end,
        set_light_mode = function()
          vim.o.background = 'light'
          vim.cmd.colorscheme 'onelight'
        end,
        fallback = 'dark',
      }
    end,
  },
  {
    'onedarkpro.nvim',
    auto_enable = true,
    colorscheme = { 'onedark', 'onedark_dark', 'onedark_vivid', 'onelight' },
  },
  {
    'kanagawa-paper.nvim',
    auto_enable = true,
    colorscheme = 'kanagawa-paper-ink',
  },
}
