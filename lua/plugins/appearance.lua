return {
  {
    'trigger_colorscheme',
    event = 'VimEnter',
    ---Schedule colorscheme setup after startup.
    load = function()
      ---Apply the configured colorscheme.
      local function apply_colorscheme()
        vim.cmd.colorscheme(nixInfo('kanagawa-paper-ink', 'settings', 'colorscheme'))
      end

      ---Apply custom highlights for line numbers.
      local function apply_line_number_highlight()
        vim.cmd [[hi LineNr guifg=#bb9af7]]
      end

      ---Apply colorscheme and defer highlight after it loads.
      local function apply_colorscheme_with_highlight()
        apply_colorscheme()
        vim.schedule(apply_line_number_highlight)
      end

      vim.schedule(apply_colorscheme_with_highlight)
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
