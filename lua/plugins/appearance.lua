return {
  {
    'auto-dark-mode.nvim',
    auto_enable = true,
    lazy = false,
    ---Configure auto-dark-mode.nvim.
    after = function()
      ---Apply custom highlights for line numbers.
      local function apply_line_number_highlight()
        vim.cmd [[hi LineNr guifg=#bb9af7]]
      end

      require('auto-dark-mode').setup {
        set_dark_mode = function()
          vim.cmd.colorscheme 'kanagawa-paper-ink'
          apply_line_number_highlight()
        end,
        set_light_mode = function()
          vim.cmd.colorscheme 'onelight'
          apply_line_number_highlight()
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
