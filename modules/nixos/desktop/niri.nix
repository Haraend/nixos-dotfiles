{ pkgs, lib, ... }:

{
  programs.niri.enable = true;

  # XDG Desktop Portal configuration for Niri
  # Critical for screen sharing/screencasting to work.
  # RemoteDesktop uses hypr-kdeconnect-portal so KDE Connect phone
  # mouse/keyboard works (gnome portal has no Niri RemoteDesktop backend).
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
      pkgs.hypr-kdeconnect-portal
    ];
    config = {
      common = {
        default = [ "gnome" "gtk" ];
      };
      niri = {
        default = [ "gnome" "gtk" ];
        # FileChooser uses GTK (doesn't require nautilus)
        "org.freedesktop.impl.portal.FileChooser" = "gtk";
        # ScreenCast and Screenshot MUST use gnome for Niri
        "org.freedesktop.impl.portal.ScreenCast" = "gnome";
        "org.freedesktop.impl.portal.Screenshot" = "gnome";
        "org.freedesktop.impl.portal.RemoteDesktop" = "hypr-kdeconnect";
      };
    };
    configPackages = [ pkgs.niri ];
  };
}
