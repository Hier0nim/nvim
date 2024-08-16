-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")

--  Use zig compiler for treesitter
require("nvim-treesitter.install").compilers = { "zig" }
