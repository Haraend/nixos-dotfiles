# All Home Manager modules
{ ... }:

{
  imports = [
    ./desktop
    ./shell
    ./terminal
    # Fonts are managed by Stylix (see modules/nixos/stylix.nix)
  ];
}
