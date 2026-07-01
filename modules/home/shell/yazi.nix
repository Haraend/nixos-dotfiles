# Yazi - terminal file manager
{ config, lib, pkgs, ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";  # New default (was "yy" before stateVersion 26.05)
  };
}
