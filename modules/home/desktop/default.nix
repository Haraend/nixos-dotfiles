# Home Manager desktop modules
{ ... }:

{
  imports = [
    ./utilities.nix
    ./browsers.nix
    ./niri.nix
    ./portals.nix
    ./xwayland.nix
    ./wayland-env.nix
    ./apps.nix
    ./noctalia/default.nix
    ./editors.nix
    ./antigravity.nix
    ./android.nix
    ./kanshi.nix
    ./audio.nix
  ];
}
