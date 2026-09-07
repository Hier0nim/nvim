return {
  {
    'conform.nvim',
    auto_enable = true,
    keys = {
      { '<leader>cf', desc = '[C]ode [F]ormat' },
    },
    ---Configure Conform and its formatting keymap.
    after = function()
      local conform = require 'conform'

      conform.setup {
        formatters_by_ft = {
          lua = { 'stylua' },
          typescript = { 'prettierd' },
          javascript = { 'prettierd' },
          typescriptreact = { 'prettierd' },
          javascriptreact = { 'prettierd' },
          json = { 'prettierd' },
          html = { 'prettierd' },
          css = { 'prettierd' },
          yaml = { 'prettierd' },
          python = { 'ruff_format' },
          sh = { 'shfmt' },
          bash = { 'shfmt' },
        },
      }

      ---Format the current buffer with Conform.
      local function format_with_conform()
        conform.format {
          lsp_format = 'fallback',
          async = false,
          timeout_ms = 3000,
        }
      end

      vim.keymap.set({ 'n', 'v' }, '<leader>cf', format_with_conform, { desc = '[C]ode [F]ormat' })
    end,
  },
  {
    'mini.nvim',
    auto_enable = true,
    lazy = false,
    ---Configure mini.nvim integrations.
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

        vim.api.nvim_create_autocmd('User', {
          pattern = 'MiniFilesBufferCreate',
          callback = function(args)
            local buf_id = args.data.buf_id
            vim.keymap.set('n', '<leader>a', function()
              local entry = MiniFiles.get_fs_entry()
              if entry == nil then
                return
              end
              local target_dir = entry.fs_type == 'file' and vim.fn.fnamemodify(entry.path, ':h') or entry.path
              MiniFiles.close()
              nixInfo.lze.trigger_load('easy-dotnet.nvim')
              require('easy-dotnet').create_new_item(target_dir)
            end, { buffer = buf_id, desc = 'Create .NET item' })
          end,
        })

        ---Open MiniFiles in the parent directory of the current buffer.
        local function open_parent_directory()
          MiniFiles.open(vim.api.nvim_buf_get_name(0), true)
        end

        vim.keymap.set('n', '-', open_parent_directory, { noremap = true, desc = 'Open parent directory' })
        vim.keymap.set('n', '<leader>e', function() MiniFiles.open(vim.fn.getcwd(), true) end, { desc = 'Files (cwd)' })
      end

      require('mini.ai').setup {
        mappings = { around_next = '', inside_next = '', around_last = '', inside_last = '', goto_left = '', goto_right = '' },
      }
      require('mini.pairs').setup()
      require('mini.splitjoin').setup { mappings = { toggle = 'gS', split = '', join = '' } }
      require('mini.surround').setup {
        mappings = { add = 'ys', delete = 'ds', replace = 'cs', find = '', find_left = '', highlight = '', suffix_last = '', suffix_next = '' },
      }
      require('mini.operators').setup {
        replace = { prefix = 'cr' },
        evaluate = { prefix = '' },
        exchange = { prefix = '' },
        multiply = { prefix = '' },
        sort = { prefix = '' },
      }
      require('mini.cmdline').setup {
        autocomplete = { enable = false },
        autocorrect = { enable = false },
        autopeek = { enable = true },
      }
      require('mini.hipatterns').setup {
        highlighters = {
          fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
          todo = { pattern = '%f[%w]()TODO()%f[%W]', group = 'MiniHipatternsTodo' },
          note = { pattern = '%f[%w]()NOTE()%f[%W]', group = 'MiniHipatternsNote' },
          hex_color = require('mini.hipatterns').gen_highlighter.hex_color(),
        },
      }
    end,
  },
}
