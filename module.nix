inputs:
{
  config,
  wlib,
  lib,
  pkgs,
  ...
}:
{
  imports = [ wlib.wrapperModules.neovim ];

  options.nvim-lib.neovimPlugins = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf wlib.types.stringable;
    default = config.nvim-lib.pluginsFromPrefix "plugins-" inputs;
  };

  config.settings.config_directory = ./.;

  config.binName = "nvim";
  config.settings.aliases = [ "vim" ];

  options.settings.colorscheme = lib.mkOption {
    type = lib.types.str;
    default = "kanagawa-paper-ink";
  };

  config.specs.colorscheme = {
    lazy = true;
    data = builtins.getAttr config.settings.colorscheme (
      with pkgs.vimPlugins;
      {
        "onedark_dark" = onedarkpro-nvim;
        "onedark_vivid" = onedarkpro-nvim;
        "onedark" = onedarkpro-nvim;
        "onelight" = onedarkpro-nvim;
        "moonfly" = vim-moonfly-colors;
        "kanagawa-paper-ink" = kanagawa-paper-nvim;
      }
    );
  };

  config.specs.lze = [
    config.nvim-lib.neovimPlugins.lze
    {
      data = config.nvim-lib.neovimPlugins.lzextras;
      name = "lzextras";
    }
  ];

  config.specs.nix = {
    data = null;
    extraPackages = with pkgs; [
      nixd
      nixfmt
    ];
  };

  config.specs.lua = {
    after = [ "general" ];
    lazy = true;
    data = with pkgs.vimPlugins; [
      lazydev-nvim
    ];
    extraPackages = with pkgs; [
      lua-language-server
      stylua
    ];
  };

  config.specs.general = {
    after = [ "lze" ];
    extraPackages = with pkgs; [
      lazygit
      tree-sitter
      ripgrep
      fd
      git
    ];
    lazy = true;
    data = with pkgs.vimPlugins; [
      {
        data = vim-sleuth;
        lazy = false;
      }

      mini-nvim
      snacks-nvim
      nvim-lspconfig
      nvim-surround
      vim-startuptime

      blink-cmp
      blink-compat
      cmp-cmdline
      colorful-menu-nvim

      lualine-nvim
      gitsigns-nvim
      which-key-nvim
      fidget-nvim
      nvim-lint
      conform-nvim
      nvim-treesitter-textobjects
      nvim-treesitter.withAllGrammars
    ];
  };

  config.specMods =
    {
      parentSpec ? null,
      config,
      ...
    }:
    {
      options.extraPackages = lib.mkOption {
        type = lib.types.listOf wlib.types.stringable;
        default = [ ];
      };
    };

  config.extraPackages = config.specCollect (acc: v: acc ++ (v.extraPackages or [ ])) [ ];

  options.settings.cats = lib.mkOption {
    readOnly = true;
    type = lib.types.attrsOf lib.types.bool;
    default = builtins.mapAttrs (_: v: v.enable) config.specs;
  };

  options.nvim-lib.pluginsFromPrefix = lib.mkOption {
    type = lib.types.raw;
    readOnly = true;
    default =
      prefix: inputs:
      lib.pipe inputs [
        builtins.attrNames
        (builtins.filter (s: lib.hasPrefix prefix s))
        (map (
          input:
          let
            name = lib.removePrefix prefix input;
          in
          {
            inherit name;
            value = config.nvim-lib.mkPlugin name inputs.${input};
          }
        ))
        builtins.listToAttrs
      ];
  };
}
