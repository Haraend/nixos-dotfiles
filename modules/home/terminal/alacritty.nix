# Alacritty - GPU-accelerated terminal emulator
{ config, lib, pkgs, ... }:

{
  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        padding = { x = 10; y = 10; };
        decorations = "none";
      };
    };
  };

  # Set Alacritty as the default terminal
  home.sessionVariables = {
    TERMINAL = "alacritty";
  };

  # Register as default terminal for xdg-terminal-exec (used by some apps)
  xdg.configFile."xdg-terminals.list".text = ''
    alacritty
  '';
}
