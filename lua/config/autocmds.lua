-- Remove automatic comment continuation when creating new lines
vim.api.nvim_create_autocmd('FileType', {
  desc = 'Remove automatic comment continuation',
  callback = function()
    vim.opt.formatoptions:remove { 'c', 'r', 'o' }
  end,
})

-- Highlight text after it is yanked
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })

vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  group = highlight_group,
  callback = function()
    vim.hl.on_yank()
  end,
})
