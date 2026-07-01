# Navigation tools: zoxide, fzf
{ config, lib, pkgs, ... }:

{
  # Zoxide - smart cd that learns your habits (replaces cd)
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    options = [ "--cmd cd" ];  # Use 'cd' instead of 'z'
  };

  # Fzf - fuzzy finder
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
  };
}
