return {
  { 'colorful-menu.nvim', auto_enable = true, on_plugin = { 'blink.cmp' } },
  {
    'blink.cmp',
    auto_enable = true,
    event = 'DeferredUIEnter',
    after = function()
      require('blink.cmp').setup {
        enabled = function() return vim.bo.filetype ~= 'bigfile' end,
        keymap = { preset = 'default' },
        sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
        cmdline = { enabled = true },
        signature = { enabled = true, window = { show_documentation = true } },
        completion = {
          documentation = { auto_show = true },
          menu = {
            draw = {
              treesitter = { 'lsp' },
              components = {
                label = {
                  text = function(ctx) return require('colorful-menu').blink_components_text(ctx) end,
                  highlight = function(ctx) return require('colorful-menu').blink_components_highlight(ctx) end,
                },
              },
            },
          },
        },
      }
    end,
  },
}
