# Brave --app windows (Omarchy-style) for the app launcher.
# Isolated profile so --load-extension applies even if main Brave is running.
# Outbound http(s) links go through webapp-open → xdg-open (Zen).
{ lib, pkgs, config, ... }:

let
  inherit (import ./web-apps/launch.nix { inherit lib pkgs config; })
    braveWebapp
    webappOpen
    geminiUrl
    whatsappUrl
    ;
  launch = url: "${lib.getExe braveWebapp} ${url}";
in
{
  home.packages = [
    braveWebapp
    webappOpen
  ];

  xdg.desktopEntries = {
    whatsapp = {
      name = "WhatsApp";
      comment = "WhatsApp Web";
      exec = launch whatsappUrl;
      icon = "whatsapp";
      terminal = false;
      type = "Application";
      categories = [ "Network" "InstantMessaging" ];
      startupNotify = true;
    };
    gemini = {
      name = "Gemini";
      comment = "Google Gemini";
      exec = launch geminiUrl;
      # Papirus's "gemini" icon is Calligra Gemini, not Google Gemini.
      icon = "google";
      terminal = false;
      type = "Application";
      categories = [ "Network" "Office" ];
      startupNotify = true;
    };
    webapp-open = {
      name = "Open in default browser";
      comment = "Used by Brave web apps to hand http(s) links to xdg-open";
      exec = "${lib.getExe webappOpen} %u";
      terminal = false;
      type = "Application";
      noDisplay = true;
      mimeType = [ "x-scheme-handler/webapp-open" ];
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications."x-scheme-handler/webapp-open" = [ "webapp-open.desktop" ];
  };
}
