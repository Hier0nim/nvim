local lsp_config = require 'config.lsp'

return {
  {
    'nvim-lspconfig',
    auto_enable = true,
    lsp = function(plugin)
      vim.lsp.config(plugin.name, plugin.lsp or {})
      vim.lsp.enable(plugin.name)
    end,
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

    load = function(name)
      vim.cmd.packadd(name)
      vim.cmd.packadd('mason-lspconfig.nvim')

      require('mason').setup()

      require('mason-lspconfig').setup({
        automatic_installation = true,
        ensure_installed = {
          'lua_ls',
        },
      })
    end,
  },
  {
    'lazydev.nvim',
    auto_enable = true,
    cmd = { 'LazyDev' },
    ft = 'lua',
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
}
