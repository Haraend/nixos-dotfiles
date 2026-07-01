# All NixOS system modules
{ ... }:

{
  imports = [
    ./desktop
    ./hardware
    ./services
    ./stylix.nix
  ];
}
