-- NOTE: this just gives nixCats global command a default value
-- so that it doesnt throw an error if you didnt install via nix.
-- usage of both this setup and the nixCats command is optional,
-- but it is very useful for passing info from nix to lua so you will likely use it at least once.
require('nixCatsUtils').setup {
  non_nix_value = true,
}

-- NOTE: You might want to move the lazy-lock.json file
local function getlockfilepath()
  if require('nixCatsUtils').isNixCats and type(nixCats.settings.unwrappedCfgPath) == 'string' then
    return nixCats.settings.unwrappedCfgPath .. '/lazy-lock.json'
  else
    return vim.fn.stdpath 'config' .. '/lazy-lock.json'
  end
end
local lazyOptions = {
  lockfile = getlockfilepath(),
}

-- NOTE: this the lazy wrapper. Use it like require('lazy').setup() but with an extra
-- argument, the path to lazy.nvim as downloaded by nix, or nil, before the normal arguments.
require('nixCatsUtils.lazyCat').setup(nixCats.pawsible { 'allPlugins', 'start', 'lazy.nvim' }, {
  { 'LazyVim/LazyVim', import = 'lazyvim.plugins' },

  -- Extras
  { import = 'lazyvim.plugins.extras.lang.json' },
  { import = 'lazyvim.plugins.extras.lang.toml' },
  { import = 'lazyvim.plugins.extras.lang.markdown' },
  { import = 'lazyvim.plugins.extras.lang.nushell' },
  { import = 'lazyvim.plugins.extras.coding.mini-surround' },
  -- { import = 'lazyvim.plugins.extras.coding.nvim-cmp' },
  { import = 'lazyvim.plugins.extras.editor.neo-tree' },
  { import = 'lazyvim.plugins.extras.util.project' },
  { import = 'lazyvim.plugins.extras.editor.dial' },
  { import = 'lazyvim.plugins.extras.editor.inc-rename' },
  { import = 'lazyvim.plugins.extras.editor.snacks_picker' },

  {
    import = 'lazyvim.plugins.extras.dap.core',
    enabled = require('nixCatsUtils').enableForCategory('debug', false),
  },
  {
    import = 'lazyvim.plugins.extras.lang.python',
    enabled = require('nixCatsUtils').enableForCategory('python', false),
  },
  {
    import = 'lazyvim.plugins.extras.lang.sql',
    enabled = require('nixCatsUtils').enableForCategory('sql', false),
  },

  require('nixCatsUtils').lazyAdd({}, { import = 'lazyvim.plugins.extras.lang.nix' }),

  -- disable mason.nvim while using nix
  -- precompiled binaries do not agree with nixos, and we can just make nix install this stuff for us.
  {
    'williamboman/mason-lspconfig.nvim',
    version = '^1.0.0',
    enabled = require('nixCatsUtils').lazyAdd(true, false),
    config = function()
      require('mason').setup {
        registries = {
          'github:mason-org/mason-registry',
          'github:Crashdummyy/mason-registry',
        },
      }
    end,
  },
  { 'williamboman/mason.nvim', version = '^1.0.0', enabled = require('nixCatsUtils').lazyAdd(true, false) },
  { 'jay-babu/mason-nvim-dap.nvim', enabled = false },
  {
    'nvim-treesitter/nvim-treesitter',
    build = require('nixCatsUtils').lazyAdd ':TSUpdate',
    opts_extend = require('nixCatsUtils').lazyAdd(nil, false),
    opts = {
      -- nix already ensured they were installed, and we would need to change the parser_install_dir if we wanted to use it instead.
      -- so we just disable install and do it via nix.
      ensure_installed = require('nixCatsUtils').lazyAdd({
        'bash',
        'c',
        'diff',
        'html',
        'css',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'vim',
        'vimdoc',
        'yaml',
        'toml',

        -- Extras
        'nix',
        'json5',
      }, false),
      auto_install = require('nixCatsUtils').lazyAdd(true, false),
    },
  },
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        -- adds type hints for nixCats global, but LazyDev is just nice in general
        { path = (nixCats.nixCatsPath or '') .. '/lua', words = { 'nixCats' } },
      },
    },
  },

  -- import/override with your plugins
  { import = 'plugins' },
}, lazyOptions)

vim.g.snacks_animate = false
vim.opt.cmdheight = 0
vim.opt.spelllang = { 'en_us', 'pl' }
vim.filetype.add {
  extension = {
    csharp = 'cs',
  },
}

-- NOTE:  Use zig compiler for treesitter
require('nvim-treesitter.install').compilers = { 'zig' }
