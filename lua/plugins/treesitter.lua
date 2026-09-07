return {
  {
    'nvim-treesitter',
    auto_enable = true,
    lazy = false,
    after = function()
      local ts = require 'nvim-treesitter'
      ts.setup {}
      if not nixInfo.isNix then
        ts.install { 'lua', 'vim', 'vimdoc', 'query', 'nix', 'markdown', 'markdown_inline', 'python', 'bash', 'c_sharp', 'json', 'yaml', 'html', 'css', 'javascript', 'typescript', 'tsx' }
      end
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('TreesitterAttach', { clear = true }),
        callback = function(args)
          if vim.bo[args.buf].filetype == 'bigfile' then return end
          local language = vim.treesitter.language.get_lang(args.match)
          if not language or not pcall(vim.treesitter.start, args.buf, language) then return end
          if language ~= 'c_sharp' then
            vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo.foldmethod = 'expr'
          vim.wo.foldlevel = 99
        end,
      })
    end,
  },
  {
    'nvim-treesitter-textobjects',
    auto_enable = true,
    lazy = false,
    after = function()
      require('nvim-treesitter-textobjects').setup {
        select = { lookahead = true, selection_modes = { ['@function.outer'] = 'V' } },
      }
      local select = require('nvim-treesitter-textobjects.select').select_textobject
      vim.keymap.set({ 'x', 'o' }, 'am', function() select('@function.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'im', function() select('@function.inner', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'ac', function() select('@class.outer', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'ic', function() select('@class.inner', 'textobjects') end)
      vim.keymap.set({ 'x', 'o' }, 'aS', function() select('@local.scope', 'locals') end)
    end,
  },
}
