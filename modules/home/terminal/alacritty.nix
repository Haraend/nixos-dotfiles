# Alacritty - GPU-accelerated terminal emulator (kept installed; default lives in default-terminal.nix)
{ ... }:

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
}

