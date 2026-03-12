vim.loader.enable()

-- Non-Nix fallback:
-- bootstrap plugin downloads before requiring any plugin modules.
if vim.g.nix_info_plugin_name == nil then
  vim.g.nix_info_plugin_name = 'nvim_wrapper_info_fallback'
  require 'non_nix_download'
end

do
  local ok
  ok, _G.nixInfo = pcall(require, vim.g.nix_info_plugin_name)

  if not ok then
    ---Return the default value for nixInfo calls when running without Nix metadata.
    ---@param _ table
    ---@param default any
    ---@return any
    local function nix_info_fallback(_, default)
      return default
    end

    ---Create a minimal nixInfo module when running without Nix metadata.
    ---@return table
    local function create_nix_info_fallback()
      return setmetatable({}, {
        __call = nix_info_fallback,
      })
    end

    package.preload[vim.g.nix_info_plugin_name] = create_nix_info_fallback
    _G.nixInfo = require(vim.g.nix_info_plugin_name)
  end

  nixInfo.isNix = vim.g.nix_info_plugin_name ~= 'nvim_wrapper_info_fallback'

  ---@module 'lzextras'
  ---@type lzextras | lze
  nixInfo.lze = setmetatable(require 'lze', getmetatable(require 'lzextras'))

  ---Get the installed plugin path from nix metadata.
  ---@param name string
  ---@return string|nil
  function nixInfo.get_nix_plugin_path(name)
    return nixInfo(nil, 'plugins', 'lazy', name) or nixInfo(nil, 'plugins', 'start', name)
  end
end

---Apply auto_enable rules for a plugin spec.
---@param plugin table
---@return table
local function apply_auto_enable(plugin)
  if nixInfo.isNix then
    if type(plugin.auto_enable) == 'table' then
      for _, name in pairs(plugin.auto_enable) do
        if not nixInfo.get_nix_plugin_path(name) then
          plugin.enabled = false
          break
        end
      end
    elseif type(plugin.auto_enable) == 'string' then
      if not nixInfo.get_nix_plugin_path(plugin.auto_enable) then
        plugin.enabled = false
      end
    elseif type(plugin.auto_enable) == 'boolean' and plugin.auto_enable then
      if not nixInfo.get_nix_plugin_path(plugin.name) then
        plugin.enabled = false
      end
    end
  end
  return plugin
end

---Apply cat-based enablement rules for a plugin spec.
---@param plugin table
---@return table
local function apply_for_cat(plugin)
  if nixInfo.isNix and type(plugin.for_cat) == 'string' then
    plugin.enabled = nixInfo(false, 'settings', 'cats', plugin.for_cat)
  end
  return plugin
end

nixInfo.lze.register_handlers {
  {
    spec_field = 'auto_enable',
    set_lazy = false,
    modify = apply_auto_enable,
  },
  {
    spec_field = 'for_cat',
    set_lazy = false,
    modify = apply_for_cat,
  },
  nixInfo.lze.lsp,
}

---Return fallback filetypes for a missing LSP config.
---@param name string
---@return string[]
local function lsp_filetype_fallback(name)
  local lspcfg = nixInfo.get_nix_plugin_path 'nvim-lspconfig'
  if lspcfg then
    local ok, cfg = pcall(dofile, lspcfg .. '/lsp/' .. name .. '.lua')
    return (ok and cfg or {}).filetypes or {}
  else
    return (vim.lsp.config[name] or {}).filetypes or {}
  end
end

nixInfo.lze.h.lsp.set_ft_fallback(lsp_filetype_fallback)

vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
