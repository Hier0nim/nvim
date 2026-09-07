return {
  {
    'nvim-hlslens',
    auto_enable = true,
    event = 'DeferredUIEnter',
    after = function()
      -- Experimental: native search mappings and counts remain untouched.
      require('hlslens').setup { enable_incsearch = true, nearest_only = true, calm_down = true }
    end,
  },
  {
    'quicker.nvim',
    auto_enable = true,
    ft = 'qf',
    after = function() require('quicker').setup {} end,
  },
  {
    'fidget.nvim',
    auto_enable = true,
    event = 'DeferredUIEnter',
    ---Configure fidget.nvim.
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
    ---Configure lualine.nvim.
    after = function()
      require('lualine').setup {
        options = {
          icons_enabled = false,
          theme = 'auto',
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_c = {
            { 'filename', path = 1, status = true },
            function()
              local dotnet = package.loaded['easy-dotnet']
              return dotnet and dotnet.lualine.jobs() or ''
            end,
            function()
              local dotnet = package.loaded['easy-dotnet']
              return dotnet and dotnet.lualine.active_project() or ''
            end,
          },
        },
        inactive_sections = {
          lualine_b = {
            { 'filename', path = 3, status = true },
          },
          lualine_x = { 'filetype' },
        },
      }
      vim.cmd.packadd('modicator.nvim')
      require('modicator').setup { integration = { lualine = { enabled = true } } }
    end,
  },
  {
    'which-key.nvim',
    auto_enable = true,
    event = 'DeferredUIEnter',
    ---Configure which-key.nvim and keymap groups.
    after = function()
      require('which-key').setup {
        preset = 'helix',
      }

      require('which-key').add {
        { '<leader><leader>', group = 'Buffers' },
        { '<leader>c', group = 'Code' },
        { '<leader>d', group = 'Debug' },
        { '<leader>f', group = 'Find' },
        { '<leader>g', group = 'Git' },
        { '<leader>m', group = 'Markdown' },
        { '<leader>r', group = 'Run' },
        { '<leader>t', group = 'Tests' },
        { '<leader>u', group = 'UI' },
      }
    end,
  },
}
