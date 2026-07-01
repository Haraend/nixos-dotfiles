# FNM - Fast Node Manager
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    fnm
  ];

  # Initialize FNM in Zsh
  programs.zsh.initContent = ''
    # FNM configuration
    eval "$(fnm env --use-on-cd)"
  '';
}
