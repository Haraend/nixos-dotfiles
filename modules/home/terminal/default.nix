# Terminal emulator and session management modules
{ ... }:

{
  imports = [
    ./alacritty.nix
    ./tmux.nix
  ];
}
