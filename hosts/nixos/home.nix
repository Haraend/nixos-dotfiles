{ config, pkgs, inputs, vars, lib, ... }:

{
  imports = [
    ../../modules/home  # Imports all Home Manager modules via default.nix
  ];

  # Theming is handled by Stylix (see modules/nixos/stylix.nix)
  # Stylix auto-themes: GTK, Qt, cursor, icons, fonts

  home.username = vars.username;
  home.homeDirectory = "/home/${vars.username}";
  home.stateVersion = vars.stateVersion;

  # Default editor (used by `$EDITOR`, git, less, etc.)
  home.sessionVariables = {
    EDITOR = "vim";
    VISUAL = "vim";
  };

  # Vim config for this user; system profile also has vim (configuration.nix) for root/rescue.
  programs.vim = {
    enable = true;
    defaultEditor = true;
    settings = {
      number = true;
      relativenumber = true;
      expandtab = true;
      shiftwidth = 2;
      tabstop = 2;
    };
    extraConfig = ''
      syntax on
      set cursorline
      set ignorecase
      set smartcase
      set mouse=a
      set clipboard=unnamedplus
      set scrolloff=5
    '';
  };

  # User packages
  home.packages = with pkgs; [
    # Add user applications here (browsers, editors, tools)
  ];

  # Git configuration (using shared vars)
  programs.git = {
    enable = true;
    settings = {
      user.name = vars.gitName;
      user.email = vars.email;
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  programs.home-manager.enable = true;
}
