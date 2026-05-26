local lsp_config = require 'config.lsp'

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
    ---Apply shared LSP defaults before registering servers.
    before = function()
      vim.lsp.config('*', {
        on_attach = lsp_config.on_attach,
      })
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
}
