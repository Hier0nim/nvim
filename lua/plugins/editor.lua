return {
  {
    'nvim-treesitter',
    auto_enable = true,
    lazy = false,
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

      local installable_parsers = ts.get_available()

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
            pcall(function()
              ts.install(parser)
            end)
          end
        end
      end

      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
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
            ts.install(language):await(function()
              treesitter_try_attach(buf, language)
            end)
          end
        end,
      })
    end,
  },
  {
    'nvim-treesitter-textobjects',
    auto_enable = true,
    lazy = false,
    before = function()
      vim.g.no_plugin_maps = true
    end,
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

      vim.keymap.set({ 'x', 'o' }, 'am', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@function.outer', 'textobjects')
      end)

      vim.keymap.set({ 'x', 'o' }, 'im', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@function.inner', 'textobjects')
      end)

      vim.keymap.set({ 'x', 'o' }, 'ac', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@class.outer', 'textobjects')
      end)

      vim.keymap.set({ 'x', 'o' }, 'ic', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@class.inner', 'textobjects')
      end)

      vim.keymap.set({ 'x', 'o' }, 'as', function()
        require('nvim-treesitter-textobjects.select').select_textobject('@local.scope', 'locals')
      end)
    end,
  },
  {
    'conform.nvim',
    auto_enable = true,
    keys = {
      { '<leader>cf', desc = '[C]ode [F]ormat' },
    },
    after = function()
      local conform = require 'conform'

      conform.setup {
        formatters_by_ft = {
          lua = nixInfo(nil, 'settings', 'cats', 'lua') and { 'stylua' } or nil,
        },
      }

      vim.keymap.set({ 'n', 'v' }, '<leader>cf', function()
        conform.format {
          lsp_fallback = true,
          async = false,
          timeout_ms = 1000,
        }
      end, { desc = '[C]ode [F]ormat' })
    end,
  },
  {
    'nvim-lint',
    auto_enable = true,
    event = 'FileType',
    after = function()
      require('lint').linters_by_ft = {}

      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        callback = function()
          require('lint').try_lint()
        end,
      })
    end,
  },
  {
    'cmp-cmdline',
    auto_enable = true,
    on_plugin = { 'blink.cmp' },
    load = nixInfo.lze.loaders.with_after,
  },
  {
    'blink.compat',
    auto_enable = true,
    dep_of = { 'cmp-cmdline' },
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
    after = function()
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
          sources = function()
            local cmdtype = vim.fn.getcmdtype()
            if cmdtype == '/' or cmdtype == '?' then
              return { 'buffer' }
            end
            if cmdtype == ':' or cmdtype == '@' then
              return { 'cmdline', 'cmp_cmdline' }
            end
            return {}
          end,
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
                  text = function(ctx)
                    return require('colorful-menu').blink_components_text(ctx)
                  end,
                  highlight = function(ctx)
                    return require('colorful-menu').blink_components_highlight(ctx)
                  end,
                },
              },
            },
          },
          documentation = {
            auto_show = true,
          },
        },
        sources = {
          default = { 'lsp', 'path', 'buffer', 'omni' },
          providers = {
            path = {
              score_offset = 50,
            },
            lsp = {
              score_offset = 40,
            },
            cmp_cmdline = {
              name = 'cmp_cmdline',
              module = 'blink.compat.source',
              score_offset = -100,
              opts = {
                cmp_name = 'cmdline',
              },
            },
          },
        },
      }
    end,
  },
  {
    'nvim-surround',
    auto_enable = true,
    event = 'DeferredUIEnter',
    after = function()
      require('nvim-surround').setup()
    end,
  },
}
