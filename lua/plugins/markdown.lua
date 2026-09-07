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
        '<localleader>mr',
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
      -- Opt in to actions without replacing native bracket motions or gx.
      require('markdown-plus').setup { keymaps = { enabled = false } }
      local function maps()
        vim.keymap.set({ 'n', 'x' }, '<localleader>mb', '<Plug>(MarkdownPlusBold)', { buffer = true, desc = 'Bold' })
        vim.keymap.set({ 'n', 'x' }, '<localleader>mi', '<Plug>(MarkdownPlusItalic)', { buffer = true, desc = 'Italic' })
        vim.keymap.set('n', '<localleader>mt', '<Plug>(MarkdownPlusGenerateTOC)', { buffer = true, desc = 'Generate TOC' })
        vim.keymap.set('n', '<localleader>ml', '<Plug>(MarkdownPlusInsertLink)', { buffer = true, desc = 'Insert link' })
        vim.keymap.set('n', '<localleader>mc', '<Plug>(MarkdownPlusCodeBlockInsert)', { buffer = true, desc = 'Code block' })
      end
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('MarkdownActions', { clear = true }),
        pattern = 'markdown',
        callback = maps,
      })
      if vim.bo.filetype == 'markdown' then maps() end
    end,
  },
}
