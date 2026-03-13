nixInfo.lze.load {
  { import = 'plugins.appearance' },
  { import = 'plugins.search' },
  { import = 'plugins.editor' },
  { import = 'plugins.lsp' },
  { import = 'plugins.dotnet' },
  { import = 'plugins.git' },
  { import = 'plugins.ui' },
  { import = 'plugins.markdown' },
  { import = 'plugins.session' },
  {
    'plenary.nvim',
  },
}
