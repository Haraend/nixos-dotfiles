# XWayland satellite — X11 app support under Wayland (Steam, Discord, etc.)
# niri 25.08+ manages the xwayland-satellite process automatically (no manual
# systemd service needed), but the NixOS niri module does NOT include the
# package itself — it must be installed here so the binary is in $PATH.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xwayland-satellite
  ];
}
