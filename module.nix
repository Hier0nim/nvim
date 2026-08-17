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
    data = with pkgs.vimPlugins; [
      kanagawa-paper-nvim
      onedarkpro-nvim
    ];
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
    runtimePkgs = with pkgs; [
      nixd
      nixfmt
    ];
  };

  config.specs.web = {
    data = null;
    runtimePkgs = with pkgs; [
      typescript-language-server
      vscode-langservers-extracted
      yaml-language-server
      prettierd
    ];
  };

  config.specs.lua = {
    after = [ "general" ];
    lazy = true;
    data = with pkgs.vimPlugins; [
      lazydev-nvim
    ];
    runtimePkgs = with pkgs; [
      lua-language-server
      stylua
    ];
  };

  config.specs.dotnet = {
    lazy = true;
    data = with pkgs.vimPlugins; [
      (config.nvim-lib.neovimPlugins.easy-dotnet-nvim.overrideAttrs { pname = "easy-dotnet.nvim"; })
      plenary-nvim
      nvim-dap
    ];
    runtimePkgs = with pkgs; [
      (pkgs.callPackage ./pkgs/easydotnet.nix { })
    ];
  };

  config.specs.general = {
    after = [ "lze" ];
    runtimePkgs = with pkgs; [
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
      vim-startuptime

      blink-cmp
      colorful-menu-nvim
      lualine-nvim
      gitsigns-nvim
      which-key-nvim
      fidget-nvim
      conform-nvim
      nvim-treesitter-textobjects
      nvim-treesitter.withAllGrammars

      (config.nvim-lib.neovimPlugins.markdown-plus-nvim.overrideAttrs { pname = "markdown-plus.nvim"; })
      render-markdown-nvim

      (config.nvim-lib.neovimPlugins.auto-dark-mode-nvim.overrideAttrs { pname = "auto-dark-mode.nvim"; })
    ];
  };

  config.specMods =
    {
      _parentSpec ? null,
      _parentOpts ? null,
      _parentName ? null,
      config,
      ...
    }:
    {
      options.runtimePkgs = lib.mkOption {
        type = lib.types.listOf wlib.types.stringable;
        default = [ ];
      };
    };

  config.runtimePkgs = config.specCollect (acc: v: acc ++ (v.runtimePkgs or [ ])) [ ];

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
