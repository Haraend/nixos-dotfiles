# Neovim - LazyVim distribution (the "omarchy-nvim" idea, vendored for NixOS)
# The config in ./nvim is deployed read-only via xdg.configFile; lazy.nvim keeps
# plugins + lockfile mutable under ~/.local/share/nvim. System vim stays
# installed (configuration.nix) for root/rescue shells.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    neovim
    # nvim-treesitter compiles parsers at install time; needs a C toolchain on PATH
    gcc
  ];

  xdg.configFile."nvim".source = ./nvim;
}
