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
vim.o.softtabstop = -1
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

vim.o.splitright = true
vim.o.splitbelow = true
vim.o.confirm = true
vim.opt.sidescrolloff = 8

vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,localoptions'

-- Large file safety: stop syntax/regex matching on very long lines
vim.o.synmaxcol = 500
