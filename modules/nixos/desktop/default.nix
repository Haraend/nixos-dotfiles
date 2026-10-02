# NixOS desktop modules (Niri, greetd, Steam, Thunar)
{ ... }:

{
  imports = [
    ./niri.nix
    ./greetd.nix
    ./thunar.nix
    ./steam.nix
    ./brave-policy.nix
  ];
}
