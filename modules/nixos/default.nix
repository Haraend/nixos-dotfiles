# All NixOS system modules
{ ... }:

{
  imports = [
    ./boot.nix
    ./desktop
    ./hardware
    ./overlays.nix
    ./services
    ./stylix.nix
  ];
}
