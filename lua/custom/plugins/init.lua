-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information

require('nvim-treesitter.install').compilers = { 'zig' }
vim.wo.wrap = false
vim.opt.tabsto = 2
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
return {}
