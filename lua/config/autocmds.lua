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

-- Set Python indentation to 4 spaces
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('PythonIndent', { clear = true }),
  pattern = 'python',
  desc = 'Set Python indentation to 4 spaces',
  callback = function()
    vim.bo.expandtab = true
    vim.bo.tabstop = 4
    vim.bo.shiftwidth = 4
    vim.bo.softtabstop = 4
  end,
})