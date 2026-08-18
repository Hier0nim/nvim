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
    'mason.nvim',
    enabled = not nixInfo.isNix,
    priority = 100,
    on_plugin = { 'nvim-lspconfig' },
    ---Configure mason.nvim and mason-lspconfig.nvim.
    ---@param name string
    load = function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd('mason-lspconfig.nvim')

      require('mason').setup()

      require('mason-lspconfig').setup {
        ensure_installed = {
          'lua_ls',
          'ts_ls',
          'html',
          'cssls',
          'jsonls',
          'yamlls',
          'eslint',
          'basedpyright',
          'ruff',
          'bashls',
        },
        handlers = {
          function(server_name)
            vim.lsp.enable(server_name)
          end,
        },
      }
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
  { 'jsonls', for_cat = 'web', lsp = {} },
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
