return {
  {
    'render-markdown.nvim',
    ft = 'markdown',
    ---Configure render-markdown.nvim.
    after = function()
      require('render-markdown').setup {
        enabled = true,
        max_file_size = 1.5,
        log_level = 'error',
      }
    end,
    keys = {
      {
        '<leader>mr',
        '<cmd>RenderMarkdown toggle<CR>',
        desc = 'Markdown render toggle',
      },
    },
  },
  {
    'markdown-plus.nvim',
    ft = 'markdown',
    ---Configure markdown-plus.nvim.
    after = function()
      require('markdown-plus').setup {}
    end,
  },
}
