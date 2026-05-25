return {
  {
    'mini.sessions',
    event = 'VimEnter',
    ---Configure mini.sessions for automatic session read/write.
    after = function()
      require('mini.sessions').setup {
        autoread = true,
        autowrite = true,
        force = { read = false, write = true, delete = false },
        verbose = { read = false, write = true, delete = true },
      }
    end,
  },
  {
    'mini.starter',
    event = 'VimEnter',
    ---Configure mini.starter as the start screen.
    after = function()
      local starter = require('mini.starter')
      starter.setup {
        evaluate_single = true,
        items = {
          starter.sections.builtin_actions(),
          starter.sections.recent_files(10, true),
          starter.sections.recent_files(10, false),
        },
        content_hooks = {
          starter.gen_hook.adding_bullet(),
          starter.gen_hook.aligning('center', 'center'),
        },
      }
    end,
  },
}
