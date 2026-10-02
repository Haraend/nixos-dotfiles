# Kanshi — Wayland output/display autoconfigurator.
#
# Niri implements the wlr-output-management-unstable-v1 protocol, so Kanshi
# works natively: it listens for output hotplug events, matches profiles by
# connector name or EDID (vendor/model/serial), and applies the first matching
# profile. Replaces `nwg-displays`, which is Sway/Hyprland-only.
#
# Discovering output names/EDIDs (run inside a Niri session):
#   niri msg outputs
# The connector name (e.g. "eDP-1", "HDMI-A-1", "DP-1") or an EDID triple
# ("Make Model Serial") can be used as `criteria`.
#
# GUI companion: `wdisplays` lets you arrange outputs visually; the resulting
# layout is what you transcribe into a profile here for persistence.
{ config, lib, pkgs, ... }:

{
  services.kanshi = {
    enable = true;

    # Bind to the generic graphical session so kanshi starts under Niri
    # (Niri reaches graphical-session.target once its Wayland socket is up).
    systemdTarget = "graphical-session.target";

    settings = [
      # Laptop panel only. A profile matches when its output count equals
      # the number of connected screens.
      {
        profile.name = "laptop";
        profile.outputs = [
          {
            criteria = "eDP-1";
            status = "enable";
            scale = 1.25;
          }
        ];
      }

      # External display. Uncomment and adjust after `niri msg outputs`.
      # {
      #   profile.name = "external";
      #   profile.outputs = [
      #     {
      #       criteria = "HDMI-A-1";
      #       status = "enable";
      #       mode = "1920x1080@60";
      #       position = "0,0";
      #     }
      #     {
      #       criteria = "eDP-1";
      #       status = "enable";
      #       scale = 1.25;
      #       position = "1920,0";
      #     }
      #   ];
      # }
    ];
  };

  home.packages = with pkgs; [
    wdisplays # GUI output arranger (wlroots, works with Niri)
  ];
}
