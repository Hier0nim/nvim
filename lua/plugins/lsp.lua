return {
  {
    'nvim-lspconfig',
    auto_enable = true,
    ---Enable an LSP server with its configuration.
    ---@param plugin table
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
  },
  {
    'SchemaStore.nvim',
    auto_enable = true,
    after = function()
      local schemastore = require 'schemastore'

      vim.lsp.config('jsonls', {
        settings = {
          json = {
            schemas = schemastore.json.schemas(),
          },
        },
      })
      vim.lsp.config('yamlls', {
        settings = {
          yaml = {
            schemaStore = {
              enable = false,
              url = '',
            },
            schemas = schemastore.yaml.schemas(),
          },
        },
      })
    end,
  },
  {
    'mason.nvim',
    enabled = not nixInfo.isNix,
    priority = 100,
    lazy = false,
    ---Configure mason.nvim and mason-lspconfig.nvim.
    ---@param name string
    load = function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd 'mason-lspconfig.nvim'

      require('mason').setup()

      require('mason-lspconfig').setup {
        automatic_enable = false,
      }
      vim.cmd.packadd 'mason-tool-installer.nvim'
      require('mason-tool-installer').setup {
        ensure_installed = {
          'lua-language-server',
          'typescript-language-server',
          'html-lsp',
          'css-lsp',
          'json-lsp',
          'yaml-language-server',
          'eslint-lsp',
          'basedpyright',
          'ruff',
          'bash-language-server',
          'stylua',
          'prettierd',
          'shfmt',
          'shellcheck',
          'debugpy',
        },
        run_on_start = false,
        auto_update = false,
        start_delay = 3000,
      }
      vim.api.nvim_create_user_command('MasonUpdateConfigured', function()
        vim.cmd 'MasonToolsUpdate'
      end, { desc = 'Install or update configured Mason tools and LSP servers' })
    end,
  },
  {
    'lazydev.nvim',
    auto_enable = true,
    cmd = { 'LazyDev' },
    ft = 'lua',
    ---Configure lazydev.nvim.
    after = function()
      require('lazydev').setup {
        library = {
          { words = { 'nixInfo%.lze' }, path = nixInfo('lze', 'plugins', 'start', 'lze') .. '/lua' },
          { words = { 'nixInfo%.lze' }, path = nixInfo('lzextras', 'plugins', 'start', 'lzextras') .. '/lua' },
        },
      }
    end,
  },
  {
    'lua_ls',
    for_cat = 'lua',
    lsp = {
      filetypes = { 'lua' },
      settings = {
        Lua = {
          runtime = { version = 'LuaJIT' },
          signatureHelp = { enabled = true },
          diagnostics = {
            globals = { 'nixInfo', 'vim' },
            disable = { 'missing-fields' },
          },
          telemetry = { enabled = false },
        },
      },
    },
  },
  {
    'nixd',
    enabled = nixInfo.isNix,
    for_cat = 'nix',
    lsp = {
      filetypes = { 'nix' },
      settings = {
        nixd = {
          nixpkgs = {
            expr = [[import <nixpkgs> {}]],
          },
          options = {},
          formatting = {
            command = { 'nixfmt' },
          },
          diagnostic = {
            suppress = {
              'sema-escaping-with',
            },
          },
        },
      },
    },
  },
  { 'ts_ls', for_cat = 'web', lsp = {} },
  { 'html', for_cat = 'web', lsp = {} },
  { 'cssls', for_cat = 'web', lsp = {} },
  { 'jsonls', for_cat = 'web', lsp = { filetypes = { 'json', 'jsonc', 'json5' } } },
  { 'yamlls', for_cat = 'web', lsp = {} },
  { 'eslint', for_cat = 'web', lsp = {} },
  {
    'basedpyright',
    for_cat = 'python',
    lsp = {
      filetypes = { 'python' },
      settings = {
        basedpyright = {
          analysis = {
            typeCheckingMode = 'standard',
            diagnosticMode = 'openFilesOnly',
          },
        },
      },
    },
  },
  {
    'ruff',
    for_cat = 'python',
    lsp = {
      filetypes = { 'python' },
      init_options = {
        settings = {
          showSyntaxErrors = true,
        },
      },
    },
  },
  {
    'bashls',
    for_cat = 'shell',
    lsp = {
      filetypes = { 'sh', 'bash' },
    },
  },
  {
    'nushell',
    for_cat = 'shell',
    lsp = {
      cmd = { 'nu', '--lsp' },
      filetypes = { 'nu' },
    },
  },
}
