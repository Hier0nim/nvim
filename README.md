# Neovim Configuration

Personal Neovim config using nix-wrapper-modules (Nix) or vim.pack (non-Nix).

## Plugin Management

### Nix machine

```bash
cd ~/Projects/nvim
nix build .#neovim
```

Plugins are pinned by flake inputs and nixpkgs. Update with `nix flake update`.

### Non-Nix machine (Ubuntu)

Plugins are managed by Neovim's built-in `vim.pack` module.
Plugins live in `~/.local/share/nvim/site/pack/core/opt/`.

#### Update plugins

1. Open nvim
2. Run `:lua vim.pack.update()`
3. A confirmation buffer opens in a new tab showing pending changes
4. **Press `:w` to apply the updates** (or `:q` to discard)
5. Run `:restart` or quit and reopen nvim

#### Add a new plugin

1. Add entry to `lua/non_nix_download.lua`:
   ```lua
   { src = gh 'author/plugin-name', load = false },
   ```
2. Restart nvim (plugin will be cloned automatically)
3. Add the lze spec to the appropriate file in `lua/plugins/`

#### Lock file

`nvim-pack-lock.json` tracks plugin revisions. It is updated automatically
when you confirm updates with `:w`. Commit it to version control.

## EasyDotnet Server

The EasyDotnet server must match the plugin version.

```bash
# Install
dotnet tool install -g EasyDotnet

# Update to latest
dotnet tool update -g EasyDotnet

# Check version
dotnet-easydotnet --version
```

If you see "Server does not broadcast support for msbuild/project-properties",
update both the plugin (vim.pack.update + :w) and the server (dotnet tool update).

After updating, fully restart nvim (`:qa` then reopen).

## Language Support

### Nix machine

All language servers, formatters, and debuggers are provided by Nix specs
automatically. No manual installation needed.

### Non-Nix machine (Ubuntu)

Install external tools for each language you need:

#### Python

- `basedpyright` -- type checker / LSP (Mason auto-installs, or `npm i -g @anthropics/basedpyright`)
- `ruff` -- linter + formatter LSP (Mason auto-installs, or `pip install ruff`)
- `debugpy` -- DAP adapter (`pip install debugpy`)

#### Bash / Shell

- `bash-language-server` -- LSP (Mason auto-installs, or `npm i -g bash-language-server`)
- `shellcheck` -- linter (apt: `sudo apt install shellcheck`)
- `shfmt` -- formatter (`go install mvdan.cc/sh/v3/cmd/shfmt@latest`)

#### Nushell

- `nu` -- the Nushell binary provides its own LSP via `nu --lsp`

#### Zsh

- `zsh` -- used as a linter via `zsh -n` (nvim-lint)

## Keymap Namespace

| Prefix | Meaning | Examples |
|--------|---------|----------|
| `<leader>f` | Find | `ff` files, `fg` grep, `fr` recent, `fd` diagnostics |
| `<leader>t` | Tests | `tt` runner, `tr` run, `td` debug, `ta` all |
| `<leader>r` | Run | `rr` run, `rd` debug, `rb` build, `rw` watch |
| `<leader>d` | Debug | `db` breakpoint, `du` UI, `de` eval, `dc` cursor |
| `<leader>g` | Git | `gg` lazygit, `gs` stage, `gr` reset, `gb` blame |
| `<leader>u` | UI | `us` spell, `uw` wrap, `ud` diagnostics, `uh` hints |
| `<leader>w` | Windows | `wv` vsplit, `ws` hsplit, `wq` close |
| `<leader>c` | Code | `cf` format, `cR` rename file, `ce` diagnostic |
| `<leader>e` | Explorer | Open at cwd |
| `-` | Explorer | Relative to current file |

### LSP (native Neovim 0.12 defaults + Snacks pickers)

| Key | Action |
|-----|--------|
| `gd` | Go to definition (Snacks picker) |
| `gra` | Code action |
| `grn` | Rename |
| `grr` | References (Snacks picker) |
| `gri` | Implementations (Snacks picker) |
| `grt` | Type definition |
| `grx` | Run code lens |
| `gO` | Document symbols |
| `K` | Hover |
| `[d` / `]d` | Prev/next diagnostic |

### Navigation

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Window focus |
| `[h` / `]h` | Prev/next git hunk |
| `[b` / `]b` | Prev/next buffer |
| `[r` / `]r` | Prev/next reference |
| `<C-\>` | Terminal |

### Editing

| Key | Action |
|-----|--------|
| `sa` / `sd` / `sr` | Surround add/delete/replace (mini.surround) |
| `cr` / `crr` | Replace operator (mini.operators) |
| `gc` / `gcc` | Comment |
| `am` / `im` | Around/inside method |
| `ac` / `ic` | Around/inside class |
