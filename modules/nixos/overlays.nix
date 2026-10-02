# Local packages not in nixpkgs.
{ ... }:

{
  nixpkgs.overlays = [
    (final: prev: {
      hypr-kdeconnect-portal = final.callPackage ../../pkgs/hypr-kdeconnect-portal.nix { };
    })
  ];
}
