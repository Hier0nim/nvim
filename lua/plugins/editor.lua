return {
  {
    'nvim-treesitter',
    auto_enable = true,
    lazy = false,
    ---Configure Treesitter integration.
    after = function()
      local ts = require 'nvim-treesitter'

      ---Attach Treesitter features to a buffer if the parser is available.
      ---@param buf integer
      ---@param language string
      ---@return boolean
      local function treesitter_try_attach(buf, language)
        if not vim.treesitter.language.add(language) then
          return false
        end

        vim.treesitter.start(buf, language)
        vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

        if vim.api.nvim_get_current_buf() == buf then
          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo.foldmethod = 'expr'
          vim.wo.foldlevel = 99
        end

        return true
      end

      ---Return installable parser names for both old and newer nvim-treesitter APIs.
      ---@return string[]
      local function get_installable_parsers()
        local ok_ts, ts_mod = pcall(require, 'nvim-treesitter')
        if ok_ts and type(ts_mod.get_available) == 'function' then
          return ts_mod.get_available()
        end

        local ok_parsers, parsers = pcall(require, 'nvim-treesitter.parsers')
        if ok_parsers and type(parsers.available_parsers) == 'function' then
          return parsers.available_parsers()
        end

        return {}
      end

      ---Install parser if possible, across different nvim-treesitter versions.
      ---@param language string
      ---@param on_done? fun()
      local function install_parser(language, on_done)
        ---Run any queued install completion callback.
        local function finish_install()
          if on_done then
            on_done()
          end
        end

        local ok_install, install_mod = pcall(require, 'nvim-treesitter.install')
        if ok_install and type(install_mod.commands) == 'table' then
          local install_fn = install_mod.commands.TSInstallSync or install_mod.commands.TSInstall
          if type(install_fn) == 'function' then
            pcall(install_fn, { language })
            vim.schedule(finish_install)
            return
          end
        end

        if type(ts.install) == 'function' then
          local ok_result, result = pcall(ts.install, language)
          if ok_result then
            if type(result) == 'table' and type(result.await) == 'function' then
              result:await(finish_install)
            else
              vim.schedule(finish_install)
            end
            return
          end
        end

        ---Notify the user when a parser could not be installed.
        local function notify_missing_parser()
          vim.notify(
            ("Treesitter parser '%s' is not installed. Run :TSInstallSync %s"):format(language, language),
            vim.log.levels.WARN
          )
        end

        vim.schedule(notify_missing_parser)
      end

      local installable_parsers = get_installable_parsers()

      if not nixInfo.isNix then
        local parsers_to_ensure = {
          'lua',
          'nix',
          'vim',
          'vimdoc',
          'query',
          'markdown',
          'markdown_inline',
        }

        for _, parser in ipairs(parsers_to_ensure) do
          if vim.tbl_contains(installable_parsers, parser) then
            install_parser(parser)
          end
        end
      end

      ---Handle Treesitter attachment and installation for FileType events.
      ---@param args table
      local function on_treesitter_filetype(args)
        local buf = args.buf
        local filetype = args.match
        local language = vim.treesitter.language.get_lang(filetype)

        if not language then
          return
        end

        if treesitter_try_attach(buf, language) then
          return
        end

        if vim.tbl_contains(installable_parsers, language) then
          ---Attach Treesitter once the parser is installed.
          local function attach_after_install()
            treesitter_try_attach(buf, language)
          end

          install_parser(language, attach_after_install)
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        callback = on_treesitter_filetype,
      })
    end,
  },
  {
    'nvim-treesitter-textobjects',
    auto_enable = true,
    lazy = false,
    ---Disable nvim-treesitter-textobjects default keymaps.
    before = function()
      vim.g.no_plugin_maps = true
    end,
    ---Configure treesitter textobjects and keymaps.
    after = function()
      require('nvim-treesitter-textobjects').setup {
        select = {
          lookahead = true,
          selection_modes = {
            ['@parameter.outer'] = 'v',
            ['@function.outer'] = 'V',
          },
          include_surrounding_whitespace = false,
        },
      }

      ---Select a treesitter textobject with the given query and group.
      ---@param query string
      ---@param group string
      local function select_textobject(query, group)
        require('nvim-treesitter-textobjects.select').select_textobject(query, group)
      end

      ---Select a function outer textobject.
      local function select_function_outer()
        select_textobject('@function.outer', 'textobjects')
      end

      ---Select a function inner textobject.
      local function select_function_inner()
        select_textobject('@function.inner', 'textobjects')
      end

      ---Select a class outer textobject.
      local function select_class_outer()
        select_textobject('@class.outer', 'textobjects')
      end

      ---Select a class inner textobject.
      local function select_class_inner()
        select_textobject('@class.inner', 'textobjects')
      end

      ---Select a local scope textobject.
      local function select_local_scope()
        select_textobject('@local.scope', 'locals')
      end

      vim.keymap.set({ 'x', 'o' }, 'am', select_function_outer)
      vim.keymap.set({ 'x', 'o' }, 'im', select_function_inner)
      vim.keymap.set({ 'x', 'o' }, 'ac', select_class_outer)
      vim.keymap.set({ 'x', 'o' }, 'ic', select_class_inner)
      vim.keymap.set({ 'x', 'o' }, 'as', select_local_scope)
    end,
  },
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
    'colorful-menu.nvim',
    auto_enable = true,
    on_plugin = { 'blink.cmp' },
  },
  {
    'blink.cmp',
    auto_enable = true,
    event = 'DeferredUIEnter',
    ---Configure blink.cmp.
    after = function()
      ---Return the active cmdline completion sources.
      ---@return string[]
      local function cmdline_sources()
        local cmdtype = vim.fn.getcmdtype()
        if cmdtype == '/' or cmdtype == '?' then
          return { 'buffer' }
        end
        if cmdtype == ':' or cmdtype == '@' then
          return { 'cmdline' }
        end
        return {}
      end

      ---Return the colorful-menu label text for blink.cmp.
      ---@param ctx table
      ---@return string
      local function menu_label(ctx)
        return require('colorful-menu').blink_components_text(ctx)
      end

      ---Return the colorful-menu highlight for blink.cmp.
      ---@param ctx table
      ---@return string
      local function menu_highlight(ctx)
        return require('colorful-menu').blink_components_highlight(ctx)
      end

      require('blink.cmp').setup {
        keymap = {
          preset = 'default',
        },
        cmdline = {
          enabled = true,
          completion = {
            menu = {
              auto_show = true,
            },
          },
          sources = cmdline_sources,
        },
        fuzzy = {
          sorts = {
            'exact',
            'score',
            'sort_text',
          },
        },
        signature = {
          enabled = true,
          window = {
            show_documentation = true,
          },
        },
        completion = {
          menu = {
            draw = {
              treesitter = { 'lsp' },
              components = {
                label = {
                  text = menu_label,
                  highlight = menu_highlight,
                },
              },
            },
          },
          documentation = {
            auto_show = true,
          },
        },
        sources = {
          default = { 'lsp', 'path', 'snippets', 'buffer' },
          providers = {
            path = {
              score_offset = 50,
            },
            lsp = {
              score_offset = 40,
            },
          },
        },
      }
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
      if not ok_files then
        return
      end

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
            require('easy-dotnet').create_item(target_dir)
          end, { buffer = buf_id, desc = 'Create file from dotnet template' })
        end,
      })

      ---Open MiniFiles in the parent directory of the current buffer.
      local function open_parent_directory()
        MiniFiles.open(vim.api.nvim_buf_get_name(0), true)
      end

      ---Open MiniFiles in the current working directory.
      local function open_working_directory()
        MiniFiles.open(vim.fn.getcwd(), true)
      end

      vim.keymap.set('n', '-', open_parent_directory, { noremap = true, desc = 'Open parent directory' })
      vim.keymap.set(
        'n',
        '<leader>-',
        open_working_directory,
        { noremap = true, desc = 'Open current working directory' }
      )

      require('mini.ai').setup()
      require('mini.pairs').setup()
      require('mini.move').setup {
        mappings = {
          left = '',
          right = '',
          down = 'J',
          up = 'K',
          line_left = '',
          line_right = '',
          line_down = '',
          line_up = '',
        },
      }
      require('mini.bracketed').setup()
      require('mini.splitjoin').setup()
      require('mini.surround').setup()
      require('mini.align').setup()
      require('mini.operators').setup()
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
