vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

vim.keymap.set('n', '<C-d>', '<C-d>zz', { desc = 'Scroll down' })
vim.keymap.set('n', '<C-u>', '<C-u>zz', { desc = 'Scroll up' })
vim.keymap.set('n', 'n', 'nzzzv', { desc = 'Next search result' })
vim.keymap.set('n', 'N', 'Nzzzv', { desc = 'Previous search result' })

vim.keymap.set('v', '<', '<gv^', { desc = 'Indent left and keep selection' })
vim.keymap.set('v', '>', '>gv^', { desc = 'Indent right and keep selection' })

vim.keymap.set('n', '<leader><leader>[', '<cmd>bprev<CR>', { desc = 'Previous buffer' })
vim.keymap.set('n', '<leader><leader>]', '<cmd>bnext<CR>', { desc = 'Next buffer' })
vim.keymap.set('n', '<leader><leader>l', '<cmd>b#<CR>', { desc = 'Last buffer' })
vim.keymap.set('n', '<leader><leader>d', '<cmd>bdelete<CR>', { desc = 'Delete buffer' })

vim.cmd [[command! W w]]
vim.cmd [[command! Wq wq]]
vim.cmd [[command! WQ wq]]
vim.cmd [[command! Q q]]

vim.keymap.set('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
vim.keymap.set('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1 }
end, { desc = 'Previous diagnostic' })

vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1 }
end, { desc = 'Next diagnostic' })

vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open diagnostic float' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

vim.keymap.set({ 'v', 'x', 'n' }, '<leader>y', '"+y', {
  noremap = true,
  silent = true,
  desc = 'Yank to clipboard',
})

vim.keymap.set('n', '<leader>Y', '"+yy', {
  noremap = true,
  silent = true,
  desc = 'Yank line to clipboard',
})

vim.keymap.set({ 'v', 'x' }, '<leader>Y', '"+y', {
  noremap = true,
  silent = true,
  desc = 'Yank selection to clipboard',
})

vim.keymap.set({ 'n', 'v', 'x' }, '<leader>p', '"+p', {
  noremap = true,
  silent = true,
  desc = 'Paste from clipboard',
})

vim.keymap.set('x', '<leader>P', '"_dP', {
  noremap = true,
  silent = true,
  desc = 'Paste over selection without overwriting unnamed register',
})
