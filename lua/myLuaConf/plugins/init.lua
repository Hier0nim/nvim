local colorschemeName = nixCats 'colorscheme'
if not require('nixCatsUtils').isNixCats then
  colorschemeName = 'kanagawa-paper-ink'
end
-- Could I lazy load on colorscheme with lze?
-- sure. But I was going to call vim.cmd.colorscheme() during startup anyway
-- this is just an example, feel free to do a better job!
vim.cmd.colorscheme(colorschemeName)

local ok, notify = pcall(require, 'notify')
if ok then
  notify.setup {
    on_open = function(win)
      vim.api.nvim_win_set_config(win, { focusable = false })
    end,
  }
  vim.notify = notify
  vim.keymap.set('n', '<Esc>', function()
    notify.dismiss { silent = true }
    vim.cmd 'nohlsearch'
  end, { desc = 'dismiss notify popup and clear hlsearch' })
end

require 'myLuaConf.plugins.mini-files'

require('lze').load {
  { import = 'myLuaConf.plugins.telescope' },
  { import = 'myLuaConf.plugins.markdown' },
  { import = 'myLuaConf.plugins.treesitter' },
  { import = 'myLuaConf.plugins.completion' },
  {
    'undotree',
    for_cat = 'general.extra',
    cmd = { 'UndotreeToggle', 'UndotreeHide', 'UndotreeShow', 'UndotreeFocus', 'UndotreePersistUndo' },
    keys = { { '<leader>U', '<cmd>UndotreeToggle<CR>', mode = { 'n' }, desc = 'Undo Tree' } },
    before = function(_)
      vim.g.undotree_WindowLayout = 1
      vim.g.undotree_SplitWidth = 40
    end,
  },
  {
    'comment.nvim',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    after = function(plugin)
      require('Comment').setup()
    end,
  },
  {
    'indent-blankline.nvim',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    after = function(plugin)
      require('ibl').setup()
    end,
  },
  {
    'nvim-surround',
    for_cat = 'general.always',
    event = 'DeferredUIEnter',
    -- keys = "",
    after = function(plugin)
      require('nvim-surround').setup()
    end,
  },
  {
    'vim-startuptime',
    for_cat = 'general.extra',
    cmd = { 'StartupTime' },
    before = function(_)
      vim.g.startuptime_event_width = 0
      vim.g.startuptime_tries = 10
      vim.g.startuptime_exe_path = nixCats.packageBinPath
    end,
  },
  {
    'fidget.nvim',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    -- keys = "",
    after = function(_)
      require('fidget').setup {}
    end,
  },
  {
    'continue.nvim',
    for_cat = 'general.always',
    event = 'VimEnter',
    -- keys = "",
    after = function(_)
      require('continue').setup {
        opts = {
          picker = 'native',
        },
      }
    end,
  },
  {
    'log-highlight.nvim',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    after = function(_)
      require('log-highlight').setup {}
    end,
  },
  {
    'hlargs',
    for_cat = 'general.extra',
    event = 'DeferredUIEnter',
    -- keys = "",
    dep_of = { 'nvim-lspconfig' },
    after = function(plugin)
      require('hlargs').setup {
        color = '#32a88f',
      }
      vim.cmd [[hi clear @lsp.type.parameter]]
      vim.cmd [[hi link @lsp.type.parameter Hlargs]]
    end,
  },
  {
    'lualine.nvim',
    for_cat = 'general.always',
    -- cmd = { "" },
    event = 'DeferredUIEnter',
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require('lualine').setup {
        options = {
          icons_enabled = false,
          theme = colorschemeName,
          component_separators = '|',
          section_separators = '',
        },
        sections = {
          lualine_c = {
            {
              'filename',
              path = 1,
              status = true,
            },
          },
        },
        inactive_sections = {
          lualine_b = {
            {
              'filename',
              path = 3,
              status = true,
            },
          },
          lualine_x = { 'filetype' },
        },
      }
    end,
  },
  {
    'gitsigns.nvim',
    for_cat = 'general.always',
    event = 'DeferredUIEnter',
    -- cmd = { "" },
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require('gitsigns').setup {
        -- See `:help gitsigns.txt`
        signs = {
          add = { text = '+' },
          change = { text = '~' },
          delete = { text = '_' },
          topdelete = { text = '‾' },
          changedelete = { text = '~' },
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns

          local function map(mode, l, r, opts)
            opts = opts or {}
            opts.buffer = bufnr
            vim.keymap.set(mode, l, r, opts)
          end

          -- Navigation
          map({ 'n', 'v' }, ']c', function()
            if vim.wo.diff then
              return ']c'
            end
            vim.schedule(function()
              gs.next_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to next hunk' })

          map({ 'n', 'v' }, '[c', function()
            if vim.wo.diff then
              return '[c'
            end
            vim.schedule(function()
              gs.prev_hunk()
            end)
            return '<Ignore>'
          end, { expr = true, desc = 'Jump to previous hunk' })

          -- Actions
          -- visual mode
          map('v', '<leader>hs', function()
            gs.stage_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'stage git hunk' })
          map('v', '<leader>hr', function()
            gs.reset_hunk { vim.fn.line '.', vim.fn.line 'v' }
          end, { desc = 'reset git hunk' })
          -- normal mode
          map('n', '<leader>gs', gs.stage_hunk, { desc = 'git stage hunk' })
          map('n', '<leader>gr', gs.reset_hunk, { desc = 'git reset hunk' })
          map('n', '<leader>gS', gs.stage_buffer, { desc = 'git Stage buffer' })
          map('n', '<leader>gu', gs.undo_stage_hunk, { desc = 'undo stage hunk' })
          map('n', '<leader>gR', gs.reset_buffer, { desc = 'git Reset buffer' })
          map('n', '<leader>gp', gs.preview_hunk, { desc = 'preview git hunk' })
          map('n', '<leader>gb', function()
            gs.blame_line { full = false }
          end, { desc = 'git blame line' })
          map('n', '<leader>gd', gs.diffthis, { desc = 'git diff against index' })
          map('n', '<leader>gD', function()
            gs.diffthis '~'
          end, { desc = 'git diff against last commit' })

          -- Toggles
          map('n', '<leader>gtb', gs.toggle_current_line_blame, { desc = 'toggle git blame line' })
          map('n', '<leader>gtd', gs.toggle_deleted, { desc = 'toggle git show deleted' })

          -- Text object
          map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'select git hunk' })
        end,
      }
      vim.cmd [[hi GitSignsAdd guifg=#04de21]]
      vim.cmd [[hi GitSignsChange guifg=#83fce6]]
      vim.cmd [[hi GitSignsDelete guifg=#fa2525]]
    end,
  },
  {
    'which-key.nvim',
    for_cat = 'general.extra',
    -- cmd = { "" },
    event = 'DeferredUIEnter',
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require('which-key').setup {
        preset = 'helix',
      }
      require('which-key').add {
        { '<leader><leader>', group = 'buffer commands' },
        { '<leader><leader>_', hidden = true },
        { '<leader>c', group = '[c]ode' },
        { '<leader>c_', hidden = true },
        { '<leader>d', group = '[d]ocument' },
        { '<leader>d_', hidden = true },
        { '<leader>g', group = '[g]it' },
        { '<leader>g_', hidden = true },
        { '<leader>m', group = '[m]arkdown' },
        { '<leader>m_', hidden = true },
        { '<leader>r', group = '[r]ename' },
        { '<leader>r_', hidden = true },
        { '<leader>s', group = '[s]earch' },
        { '<leader>s_', hidden = true },
        { '<leader>f', group = '[f]find' },
        { '<leader>f_', hidden = true },
        { '<leader>t', group = '[t]oggles' },
        { '<leader>t_', hidden = true },
        { '<leader>w', group = '[w]orkspace' },
        { '<leader>w_', hidden = true },
      }
    end,
  },
}
