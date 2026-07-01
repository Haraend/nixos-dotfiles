# GUI applications — Vesktop, Spotify, OBS, Obsidian, etc.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Communication
    vesktop

    # Media
    obs-studio
    spotify
    pavucontrol
    gthumb          # GPL image browser/organizer (GStreamer for video in catalog)

    # Notes
    obsidian

    # Files
    file-roller     # GUI archive manager (zip, tar, 7z, etc.)

    # Display / monitor management
    # (GUI arranger `wdisplays` and the Kanshi autoconfig daemon live in
    # ./kanshi.nix — nwg-displays was dropped because it only supports
    # Sway/Hyprland IPC, not the wlr-output-management protocol Niri uses.)
    wl-mirror       # Mirror one Wayland output into a window (stand-in for "duplicate")
    wlr-randr       # CLI to query/set output state (used by scripts & tools)

    # Databases
    mongodb-compass

    # Games
    prismlauncher
  ];
}
