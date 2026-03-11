return {
  ---------------------------------------------------------------------------
  -- Render Markdown inside buffer
  ---------------------------------------------------------------------------
  {
    "render-markdown.nvim",
    ft = "markdown",
    after = function()
      require("render-markdown").setup({
        enabled = true,
        max_file_size = 1.5,
        log_level = 'error',
      })
    end,
    keys = {
      {
        "<leader>mr",
        "<cmd>RenderMarkdown toggle<CR>",
        desc = "Markdown render toggle",
      },
    },
  },

  ---------------------------------------------------------------------------
  -- Modern markdown editing 
  ---------------------------------------------------------------------------
  {
    "markdown-plus.nvim",
    ft = "markdown",
    after = function()
      require("markdown-plus").setup({})
    end,
  },
}
