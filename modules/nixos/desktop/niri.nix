{ pkgs, lib, ... }:

{
  programs.niri.enable = true;

  # XDG Desktop Portal configuration for Niri
  # Critical for screen sharing/screencasting to work
  xdg.portal = {
    enable = true;
    extraPortals = [ 
      pkgs.xdg-desktop-portal-gtk 
      pkgs.xdg-desktop-portal-gnome 
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
      };
    };
    configPackages = [ pkgs.niri ];
  };
}
