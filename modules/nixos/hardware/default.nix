# NixOS hardware modules
{ ... }:

{
  imports = [
    ./audio.nix
    ./power.nix
    ./graphics.nix

  ];
}
