return {
  {
    'j-hui/fidget.nvim',
    opts = {
      notification = {
        override_vim_notify = true,
      },
    },
  },

  -- Disable noice.nvim
  {
    'folke/noice.nvim',
    enabled = false,
  },

  -- Configure snacks.nvim
  {
    'folke/snacks.nvim',
    opts = {
      notifier = {
        enabled = true,
      },
    },
  },
}
