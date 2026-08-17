-- Remove automatic comment continuation when creating new lines
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('FormatOptions', { clear = true }),
  desc = 'Remove automatic comment continuation',
  callback = function()
    vim.opt_local.formatoptions:remove { 'c', 'r', 'o' }
  end,
})

-- Highlight text after it is yanked
vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('YankHighlight', { clear = true }),
  desc = 'Highlight yanked text',
  callback = function()
    vim.hl.on_yank()
  end,
})
