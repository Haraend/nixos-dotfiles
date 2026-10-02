# Browsers — Zen (default), Chrome, Brave + MIME type associations
{ pkgs, inputs, ... }:

let
  zenBrowser = inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".beta;
  zenDesktopFile = "zen-beta.desktop";
  browserMimeTypes = [
    "application/x-extension-shtml"
    "application/x-extension-xhtml"
    "application/x-extension-html"
    "application/x-extension-xht"
    "application/x-extension-htm"
    "x-scheme-handler/unknown"
    "x-scheme-handler/mailto"
    "x-scheme-handler/chrome"
    "x-scheme-handler/about"
    "x-scheme-handler/https"
    "x-scheme-handler/http"
    "application/xhtml+xml"
    "text/html"
  ];
  # Plain text/JSON open in Zed, not the browser (see textEditorMimeTypes below).
  textEditorMimeTypes = [
    "application/json"
    "text/plain"
  ];
  textEditorAssociations = builtins.listToAttrs (
    map
      (name: {
        inherit name;
        value = [ "dev.zed.Zed.desktop" ];
      })
      textEditorMimeTypes
  );
  browserAssociations = builtins.listToAttrs (
    map
      (name: {
        inherit name;
        value = [ zenDesktopFile ];
      })
      browserMimeTypes
  );
in
{
  # Don't let Stylix theme Zen — we want sync with Windows to manage appearance
  stylix.targets.zen-browser.enable = false;

  home.packages = [
    zenBrowser
    pkgs.google-chrome
    pkgs.brave
  ];

  xdg.mimeApps = {
    enable = true;
    associations.added = browserAssociations // textEditorAssociations;
    defaultApplications = browserAssociations // textEditorAssociations;
  };
}
