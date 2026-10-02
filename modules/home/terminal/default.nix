# Terminal emulator and session management modules
{ ... }:

{
  imports = [
    ./alacritty.nix
    ./foot.nix
    ./default-terminal.nix
    ./tmux.nix
    ./neovim.nix
  ];
}
