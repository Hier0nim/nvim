return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = {
    { 'tpope/vim-dadbod', lazy = true },
    { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
  },
  cmd = {
    'DBUI',
    'DBUIToggle',
    'DBUIAddConnection',
    'DBUIFindBuffer',
  },
  lazy = true,
  init = function()
    -- Your DBUI configuration
    vim.g.db_ui_use_nerd_fonts = 1

    -- Create an autocommand for the 'dbout' file type
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'dbout',
      callback = function()
        vim.wo.foldenable = false
      end,
    })
  end,
}
