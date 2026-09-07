vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up' })

vim.keymap.set('v', '<', '<gv^', { desc = 'Indent left and keep selection' })
vim.keymap.set('v', '>', '>gv^', { desc = 'Indent right and keep selection' })

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('n', '<leader>ce', vim.diagnostic.open_float, { desc = 'Open diagnostic float' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to below window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to above window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Delete the buffer without closing its window.
vim.keymap.set('n', '<leader><leader>d', function() Snacks.bufdelete() end, { desc = 'Delete buffer' })

-- Clipboard
vim.keymap.set({ 'n', 'x' }, '<leader>y', '"+y', {
  noremap = true,
  silent = true,
  desc = 'Yank to clipboard',
})

vim.keymap.set('n', '<leader>Y', '"+yy', {
  noremap = true,
  silent = true,
  desc = 'Yank line to clipboard',
})

vim.keymap.set('x', '<leader>Y', '"+y', {
  noremap = true,
  silent = true,
  desc = 'Yank selection to clipboard',
})

vim.keymap.set({ 'n', 'x' }, '<leader>p', '"+p', {
  noremap = true,
  silent = true,
  desc = 'Paste from clipboard',
})

vim.keymap.set('x', '<leader>P', '"_dP', {
  noremap = true,
  silent = true,
  desc = 'Paste over selection without overwriting unnamed register',
})
