return {
  {
    'vim-startuptime',
    auto_enable = true,
    cmd = { 'StartupTime' },
    before = function()
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixInfo(vim.v.progpath, 'progpath')
    end,
  },
  {
    'fidget.nvim',
    auto_enable = true,
    event = 'DeferredUIEnter',
    after = function()
      require('fidget').setup {
        notification = {
          override_vim_notify = true,
          filter = vim.log.levels.INFO,
          window = {
            border = 'none',
            winblend = 0,
          },
        },
        progress = {
          display = {
            done_ttl = 3,
            progress_ttl = math.huge,
          },
        },
      }
    end,
  },
  {
    'lualine.nvim',
    auto_enable = true,
    event = 'DeferredUIEnter',
    after = function()
      require('lualine').setup {
        options = {
          icons_enabled = false,
          theme = nixInfo('kanagawa-paper-ink', 'settings', 'colorscheme'),
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_c = {
            { 'filename', path = 1, status = true },
          },
        },
        inactive_sections = {
          lualine_b = {
            { 'filename', path = 3, status = true },
          },
          lualine_x = { 'filetype' },
        },
      }
    end,
  },
  {
    'which-key.nvim',
    auto_enable = true,
    event = 'DeferredUIEnter',
    after = function()
      require('which-key').setup {
        preset = 'helix',
      }

      require('which-key').add {
        { '<leader><leader>', group = 'buffer commands' },
        { '<leader><leader>_', hidden = true },
        { '<leader>c', group = '[c]ode' },
        { '<leader>c_', hidden = true },
        { '<leader>d', group = '[d]ocument' },
        { '<leader>d_', hidden = true },
        { '<leader>f', group = '[f]ind' },
        { '<leader>f_', hidden = true },
        { '<leader>g', group = '[g]it' },
        { '<leader>g_', hidden = true },
        { '<leader>r', group = '[r]ename' },
        { '<leader>r_', hidden = true },
        { '<leader>s', group = '[s]earch' },
        { '<leader>s_', hidden = true },
        { '<leader>t', group = '[t]oggles' },
        { '<leader>t_', hidden = true },
        { '<leader>w', group = '[w]orkspace' },
        { '<leader>w_', hidden = true },
      }
    end,
  },
}
