# Tmux - terminal session manager
{ config, lib, pkgs, ... }:

{
  programs.tmux = {
    enable = true;
    shell = "${pkgs.zsh}/bin/zsh";
    terminal = "tmux-256color";
    prefix = "C-a";  # Use Ctrl+A instead of Ctrl+B
    keyMode = "vi";
    mouse = true;
    escapeTime = 0;
    baseIndex = 1;
    historyLimit = 10000;
  };
}
