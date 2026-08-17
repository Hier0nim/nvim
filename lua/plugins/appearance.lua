return {
  {
    'auto-dark-mode.nvim',
    auto_enable = true,
    lazy = false,
    ---Configure auto-dark-mode.nvim.
    after = function()
      ---Apply custom highlights that should persist across colorscheme changes.
      local function apply_custom_highlights()
        local bg = vim.o.background
        if bg == 'dark' then
          vim.cmd [[hi LineNr guifg=#bb9af7]]
          vim.cmd [[hi GitSignsAdd guifg=#04de21]]
          vim.cmd [[hi GitSignsChange guifg=#83fce6]]
          vim.cmd [[hi GitSignsDelete guifg=#fa2525]]
          vim.api.nvim_set_hl(0, 'MySnacksIndent', { fg = '#32a88f' })
        else
          vim.cmd [[hi LineNr guifg=#6c6c6c]]
          vim.cmd [[hi GitSignsAdd guifg=#2e7d32]]
          vim.cmd [[hi GitSignsChange guifg=#1565c0]]
          vim.cmd [[hi GitSignsDelete guifg=#c62828]]
          vim.api.nvim_set_hl(0, 'MySnacksIndent', { fg = '#1a8870' })
        end
      end

      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('CustomHighlights', { clear = true }),
        callback = apply_custom_highlights,
      })

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
