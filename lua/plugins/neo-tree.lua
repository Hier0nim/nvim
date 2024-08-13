return {
  "nvim-neo-tree/neo-tree.nvim",
  keys = {
    { "\\", ":Neotree reveal<CR>", desc = "NeoTree reveal" },
  },
  opts = {
    filesystem = {
      window = {
        mappings = {
          ["\\"] = "close_window",
        },
      },
    },
  },
}
