return {
  {
    'mini.nvim',
    auto_enable = true,
    lazy = false,
    after = function()
      local ok_icons, MiniIcons = pcall(require, 'mini.icons')
      if ok_icons then
        MiniIcons.setup {
          style = 'glyph',
        }

        -- Make plugins expecting nvim-web-devicons work through mini.icons.
        MiniIcons.mock_nvim_web_devicons()
      end

      local ok_files, MiniFiles = pcall(require, 'mini.files')
      if ok_files then
        MiniFiles.setup {
          options = {
            use_as_default_explorer = true,
          },
        }

        require('util.mini_files_git').setup(MiniFiles)

        vim.keymap.set('n', '-', function()
          MiniFiles.open(vim.api.nvim_buf_get_name(0), true)
        end, { noremap = true, desc = 'Open parent directory' })

        vim.keymap.set('n', '<leader>-', function()
          MiniFiles.open(vim.fn.getcwd(), true)
        end, { noremap = true, desc = 'Open current working directory' })
      end
    end,
  },
}
