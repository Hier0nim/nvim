nixInfo.lze.load {
  { import = 'plugins.appearance' },
  { import = 'plugins.search' },
  { import = 'plugins.editor' },
  { import = 'plugins.lsp' },
  { import = 'plugins.git' },
  { import = 'plugins.ui' },
  { import = 'plugins.markdown' },
  { import = 'plugins.session' },
  { import = 'plugins.dotnet' },
  {
    'plenary.nvim',
  },
}
