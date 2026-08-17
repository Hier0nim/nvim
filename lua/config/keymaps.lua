vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous search result' })

vim.keymap.set('v', '<', '<gv^', { desc = 'Indent left and keep selection' })
vim.keymap.set('v', '>', '>gv^', { desc = 'Indent right and keep selection' })

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostics
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1 }
end, { desc = 'Previous diagnostic' })

vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1 }
end, { desc = 'Next diagnostic' })

vim.keymap.set('n', '<leader>ce', vim.diagnostic.open_float, { desc = 'Open diagnostic float' })

-- Window navigation
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = 'Move to left window' })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = 'Move to below window' })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = 'Move to above window' })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = 'Move to right window' })

-- Window management
vim.keymap.set('n', '<leader>wv', '<cmd>vsplit<CR>', { desc = 'Split vertical' })
vim.keymap.set('n', '<leader>ws', '<cmd>split<CR>', { desc = 'Split horizontal' })
vim.keymap.set('n', '<leader>w=', '<C-w>=', { desc = 'Equalize windows' })
vim.keymap.set('n', '<leader>wq', '<cmd>close<CR>', { desc = 'Close window' })

-- Buffers
vim.keymap.set('n', '<leader><leader>l', '<cmd>b#<CR>', { desc = 'Last buffer' })
vim.keymap.set('n', '<leader><leader>d', '<cmd>bdelete<CR>', { desc = 'Delete buffer' })

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
