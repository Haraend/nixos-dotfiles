{ config, pkgs, inputs, vars, lib, ... }:

{
  imports = [
    ../../modules/home # Imports all Home Manager modules via default.nix
  ];

  # Theming is handled by Stylix (see modules/nixos/stylix.nix)
  # Stylix auto-themes: GTK, Qt, cursor, icons, fonts

  home.username = vars.username;
  home.homeDirectory = "/home/${vars.username}";
  home.stateVersion = vars.stateVersion;

  # Default editor (used by `$EDITOR`, git, less, etc.)
  # nvim = LazyVim (modules/home/terminal/neovim.nix); plain vim stays on the
  # system profile for root/rescue.
  home.sessionVariables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };

  # XDG user dirs: declared so paths like ~/Pictures/Screenshots (Noctalia's
  # screenshot target) exist deterministically, not by manual mkdir.
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    # Legacy default (stateVersion < 26.05) pinned explicitly to silence the
    # HM migration warning; exports XDG_*_DIR into the session environment.
    setSessionVariables = true;
    documents = "$HOME/Documents";
    download = "$HOME/Downloads";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    videos = "$HOME/Videos";
    extraConfig = {
      SCREENSHOTS = "$HOME/Pictures/Screenshots";
    };
  };

  # Vim config for this user; system profile also has vim (configuration.nix) for root/rescue.
  # defaultEditor stays off - $EDITOR points at nvim above.
  programs.vim = {
    enable = true;
    defaultEditor = false;
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
