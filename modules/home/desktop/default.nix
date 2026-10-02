# Home Manager desktop modules
{ ... }:

{
  imports = [
    ./utilities.nix
    ./browsers.nix
    ./web-apps.nix
    ./niri.nix
    ./xwayland.nix
    ./wayland-env.nix
    ./apps.nix
    ./graphics.nix
    ./disk-usage.nix
    ./windows-vm.nix
    ./noctalia/default.nix
    ./editors.nix
    ./opencode.nix
    ./android.nix
    ./kanshi.nix
    ./audio.nix
  ];
}
