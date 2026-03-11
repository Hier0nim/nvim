---Clone paq-nvim if it is not already installed.
---
---Used for the non-Nix fallback plugin installation path.
---@return boolean  True if paq-nvim was installed during this run.
local function clone_paq()
  local path = vim.fn.stdpath 'data' .. '/site/pack/paqs/start/paq-nvim'
  local is_installed = vim.fn.empty(vim.fn.glob(path)) == 0

  if not is_installed then
    vim.fn.system {
      'git',
      'clone',
      '--depth=1',
      'https://github.com/savq/paq-nvim.git',
      path,
    }
    return true
  end

  return false
end

---Bootstrap paq-nvim and install the requested plugin list.
---
---This runs only when the configuration is not using the Nix wrapper.
---@param packages table[]
local function bootstrap_paq(packages)
  local first_install = clone_paq()

  vim.cmd.packadd 'paq-nvim'

  local paq = require 'paq'
  if first_install then
    vim.notify 'Installing plugins. If prompted, press Enter to continue.'
  end

  paq(vim.list_extend({
    'savq/paq-nvim',
  }, packages))

  paq.install()
end

bootstrap_paq {
  { 'BirdeeHub/lze' },
  { 'BirdeeHub/lzextras' },

  { 'olimorris/onedarkpro.nvim' },
  { 'bluz71/vim-moonfly-colors' },
  { 'thesimonho/kanagawa-paper.nvim' },

  { 'nvim-mini/mini.nvim' },
  { 'nvim-tree/nvim-web-devicons' },
  { 'folke/snacks.nvim' },

  { 'neovim/nvim-lspconfig', opt = true },
  { 'williamboman/mason.nvim', opt = true },
  { 'williamboman/mason-lspconfig.nvim', opt = true },
  { 'folke/lazydev.nvim', opt = true },

  { 'nvim-treesitter/nvim-treesitter', build = ':TSUpdate', opt = true },
  { 'nvim-treesitter/nvim-treesitter-textobjects', opt = true },

  { 'stevearc/conform.nvim', opt = true },
  { 'mfussenegger/nvim-lint', opt = true },

  { 'Saghen/blink.cmp', branch = 'v1.*', opt = true },
  { 'Saghen/blink.compat', opt = true },
  { 'hrsh7th/cmp-cmdline', opt = true },
  { 'xzbdmw/colorful-menu.nvim', opt = true },

  { 'kylechui/nvim-surround', opt = true },
  { 'dstein64/vim-startuptime', opt = true },
  { 'j-hui/fidget.nvim', opt = true },
  { 'nvim-lualine/lualine.nvim', opt = true },
  { 'lewis6991/gitsigns.nvim', opt = true },
  { 'folke/which-key.nvim', opt = true },
  { 'tpope/vim-sleuth' },


  { 'MeanderingProgrammer/render-markdown.nvim', opt = true },
  { 'YousefHadder/markdown-plus.nvim', opt = true },
}
