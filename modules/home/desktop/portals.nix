# XDG Desktop Portal — DISABLED 2026-04-22
#
# REASON: The NixOS `xdg.portal` module in modules/nixos/desktop/niri.nix already
# installs `xdg-desktop-portal-gtk` and `xdg-desktop-portal-gnome` and generates
# the matching systemd user services automatically. Declaring them here as well
# duplicates the packages and creates a second set of user services on the same
# D-Bus names, which can cause the portal to double-activate or race.
#
# If screen share / file picker stops working in Niri, uncomment the block
# below and rebuild. Otherwise, this file can be deleted.
{ ... }:

{ }

/*
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
  ];

  # Portal services - properly configured for screen sharing (from black-don-os)
  systemd.user.services.xdg-desktop-portal = {
    Unit = {
      Description = "Portal service";
      After = [
        "graphical-session.target"
        "pipewire.service"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.portal.Desktop";
      ExecStart = "${pkgs.xdg-desktop-portal}/libexec/xdg-desktop-portal";
      Restart = "on-failure";
      Environment = [
        "XDG_CURRENT_DESKTOP=niri"
        "WAYLAND_DISPLAY=wayland-1"
      ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.xdg-desktop-portal-gnome = {
    Unit = {
      Description = "Portal service (GNOME implementation)";
      After = [
        "graphical-session.target"
        "pipewire.service"
      ];
      PartOf = [ "graphical-session.target" ];
      Requires = [ "pipewire.service" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.impl.portal.desktop.gnome";
      ExecStart = "${pkgs.xdg-desktop-portal-gnome}/libexec/xdg-desktop-portal-gnome";
      Restart = "on-failure";
      Environment = [
        "XDG_CURRENT_DESKTOP=niri"
      ];
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.xdg-desktop-portal-gtk = {
    Unit = {
      Description = "Portal service (GTK/GNOME implementation)";
      After = [
        "graphical-session.target"
      ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Type = "dbus";
      BusName = "org.freedesktop.impl.portal.desktop.gtk";
      ExecStart = "${pkgs.xdg-desktop-portal-gtk}/libexec/xdg-desktop-portal-gtk";
      Restart = "on-failure";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}
*/
