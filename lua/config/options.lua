vim.o.exrc = true
vim.o.background = 'dark'

vim.opt.list = true
vim.opt.listchars = {
  tab = '> ',
  trail = '-',
  nbsp = '+',
}

vim.opt.hlsearch = true
vim.opt.inccommand = 'split'
vim.opt.scrolloff = 10

vim.wo.number = true
vim.wo.relativenumber = true
vim.wo.signcolumn = 'yes'

vim.o.mouse = 'a'

vim.opt.cpoptions:append 'I'
vim.o.expandtab = true
vim.o.smartindent = true
vim.o.autoindent = true
vim.o.tabstop = 2
vim.o.softtabstop = 4
vim.o.shiftwidth = 2
vim.o.shiftround = true

vim.o.breakindent = true
vim.o.linebreak = true

vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.o.completeopt = 'menu,preview,noselect'
vim.o.termguicolors = true
vim.opt.cmdheight = 0
vim.opt.spelllang = { 'en_us', 'pl' }

vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'

vim.g.netrw_liststyle = 0
vim.g.netrw_banner = 0
