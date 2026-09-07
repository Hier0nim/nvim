# Neovim configuration

Requires **Neovim 0.12** and Git. Shared Lua uses explicit lze modules; Nix
categories provision plugins/tools, while non-Nix installs plugins with `vim.pack`.

## Install

- Nix: `nix build .#neovim`, then `./result/bin/nvim`. The flake also exports
  `wrapperModules.default`, `nixosModules.default`, and `homeModules.default`.
  Package outputs target x86_64-linux and aarch64-linux.
- Non-Nix: place this checkout at `~/.config/nvim`. Install a C compiler, a current
  compatible tree-sitter CLI (tested 0.26.11), tar, curl, Node.js/npm and Python
  with pip/venv support before starting. Mason provisions supported language
  servers, formatters, ShellCheck and debugpy. Optional manual BasedPyright
  installation is `pip install basedpyright` (not `@anthropics/basedpyright`).
- Keep Git, ripgrep, fd and lazygit on PATH outside Nix. Install Nushell (`nu`)
  and Zsh when using those filetypes. No environment manager is configured.
- .NET development requires an external .NET SDK. Non-Nix also needs
  `dotnet tool install -g EasyDotnet --version 3.4.24` (use `update` if installed)
  and `~/.dotnet/tools` on PATH. Nix provides EasyDotnet 3.4.24.
  The plugin is pinned to `640612c3d1f691ed47074ae0b262670057b18445`.

Open .NET repositories at their root with one `.slnx`; select a startup project
once through the Dotnet menu and let EasyDotnet persist it. Run/debug use the
default launch profile, never a custom source-file-based project selector.
Python execution uses the active VIRTUAL_ENV/CONDA_PREFIX, otherwise PATH Python.
Python tests require pytest in that environment.

## Editing

Space is leader; backslash is localleader. Native LSP mappings, search counts,
bracket motions and `an`/`in` remain native (`gd` uses Snacks definitions).
Use `ys`/`ds`/`cs` for surrounds, `gS` for split/join and `cr` for replace.
MiniFiles: `-` at the current file, `<leader>e` at cwd; its `<leader>a` creates
a .NET item. Markdown actions use localleader.

`.NET`: `<leader>rr` run, `rd` debug, `rb` project quickfix build, `rB` solution
build, `rw` watch, `rs` stop, `rm` menu. Tests: `tt` runner, `tr` current,
`ta` file/all, `td` debug, `tp` failed stack, `te` errors. F5/F10/F11/F12
and `<leader>d` retain DAP controls.

## Maintenance

Run `:checkhealth`. Open a C# file to load EasyDotnet before running
`:checkhealth easy-dotnet`. For non-Nix updates run
`:lua vim.pack.update()`, review the confirmation buffer, `:w` to accept, then
restart. Keep the generated `nvim-pack-lock.json`; do not edit revisions by hand.
Remove declarations, restart, then use `:packdel ++all` where supported.
Neovim 0.12.4 has no `:packdel`; its public API equivalent for inactive plugins is:

```vim
:lua vim.pack.del(vim.iter(vim.pack.get(nil, {info=false})):filter(function(p) return not p.active end):map(function(p) return p.spec.name end):totable())
```

Nix updates use `nix flake update` and a rebuild; keep the EasyDotnet pin/server
pair deliberate. `<leader>up` toggles Snacks profiling. Hlslens live incremental
search is experimental: headless checks are not evidence of interactive latency.
The lazygit remote-edit glue and dncdbg packaging workaround remain until their
removal is verified on the relevant systems.
