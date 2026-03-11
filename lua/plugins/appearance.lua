return {
  {
    'trigger_colorscheme',
    event = 'VimEnter',
    load = function()
      vim.schedule(function()
        vim.cmd.colorscheme(nixInfo('kanagawa-paper-ink', 'settings', 'colorscheme'))
        vim.schedule(function()
          vim.cmd [[hi LineNr guifg=#bb9af7]]
        end)
      end)
    end,
  },
  {
    'onedarkpro.nvim',
    auto_enable = true,
    colorscheme = { 'onedark', 'onedark_dark', 'onedark_vivid', 'onelight' },
  },
  {
    'vim-moonfly-colors',
    auto_enable = true,
    colorscheme = 'moonfly',
  },
  {
    'kanagawa-paper.nvim',
    auto_enable = true,
    colorscheme = 'kanagawa-paper-ink',
  },
}
