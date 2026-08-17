return {
  {
    'auto-dark-mode.nvim',
    auto_enable = true,
    lazy = false,
    ---Configure auto-dark-mode.nvim.
    after = function()
      ---Apply custom highlights that should persist across colorscheme changes.
      local function apply_custom_highlights()
        vim.cmd [[hi LineNr guifg=#bb9af7]]
      end

      vim.api.nvim_create_autocmd('ColorScheme', {
        callback = apply_custom_highlights,
      })

      require('auto-dark-mode').setup {
        set_dark_mode = function()
          vim.cmd.colorscheme 'kanagawa-paper-ink'
        end,
        set_light_mode = function()
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
