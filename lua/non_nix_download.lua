local gh = function(x) return 'https://github.com/' .. x end

vim.pack.add {
  { src = gh 'BirdeeHub/lze' },
  { src = gh 'BirdeeHub/lzextras' },

  { src = gh 'olimorris/onedarkpro.nvim' },
  { src = gh 'bluz71/vim-moonfly-colors' },
  { src = gh 'thesimonho/kanagawa-paper.nvim' },
  { src = gh 'f-person/auto-dark-mode.nvim' },

  { src = gh 'nvim-mini/mini.nvim' },
  { src = gh 'nvim-tree/nvim-web-devicons' },
  { src = gh 'folke/snacks.nvim' },

  { src = gh 'neovim/nvim-lspconfig', load = false },
  { src = gh 'williamboman/mason.nvim', load = false },
  { src = gh 'williamboman/mason-lspconfig.nvim', load = false },
  { src = gh 'folke/lazydev.nvim', load = false },

  { src = gh 'nvim-treesitter/nvim-treesitter', version = 'main', load = false },
  { src = gh 'nvim-treesitter/nvim-treesitter-textobjects', load = false },

  { src = gh 'stevearc/conform.nvim', load = false },
  { src = gh 'mfussenegger/nvim-lint', load = false },

  { src = gh 'Saghen/blink.cmp', version = vim.version.range('1.*'), load = false },
  { src = gh 'Saghen/blink.compat', load = false },
  { src = gh 'hrsh7th/cmp-cmdline', load = false },
  { src = gh 'xzbdmw/colorful-menu.nvim', load = false },

  { src = gh 'kylechui/nvim-surround', load = false },
  { src = gh 'dstein64/vim-startuptime', load = false },
  { src = gh 'j-hui/fidget.nvim', load = false },
  { src = gh 'nvim-lualine/lualine.nvim', load = false },
  { src = gh 'lewis6991/gitsigns.nvim', load = false },
  { src = gh 'folke/which-key.nvim', load = false },
  { src = gh 'tpope/vim-sleuth' },
  { src = gh 'niba/continue.nvim' },
  { src = gh 'nvim-lua/plenary.nvim' },

  { src = gh 'MeanderingProgrammer/render-markdown.nvim', load = false },
  { src = gh 'YousefHadder/markdown-plus.nvim', load = false },

  { src = gh 'GustavEikaas/easy-dotnet.nvim', load = false },
  { src = gh 'mfussenegger/nvim-dap', load = false },
}
