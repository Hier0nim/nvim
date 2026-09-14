return {
  {
    'mini.sessions',
    event = 'VimEnter',
    ---Configure mini.sessions to save restored sessions without reading one at startup.
    after = function()
      require('mini.sessions').setup {
        autoread = false,
        autowrite = true,
        force = { read = false, write = true, delete = false },
        verbose = { read = false, write = true, delete = true },
      }
    end,
  },
}
