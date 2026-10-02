# Shared Brave --app launcher (isolated profile + outbound-link extension).
{ lib, pkgs, config }:

let
  brave = lib.getExe pkgs.brave;
  dataDir = "${config.xdg.dataHome}/brave-webapps";
  extensionDir = ./open-in-default-browser;
in
{
  geminiUrl = "https://gemini.google.com/app";
  whatsappUrl = "https://web.whatsapp.com";

  braveWebapp = pkgs.writeShellApplication {
    name = "brave-webapp";
    text = ''
      set -eu
      if [ "$#" -lt 1 ]; then
        echo "Usage: brave-webapp <url>" >&2
        exit 1
      fi
      exec ${lib.escapeShellArg brave} \
        --user-data-dir=${lib.escapeShellArg dataDir} \
        --load-extension=${lib.escapeShellArg "${extensionDir}"} \
        --new-window \
        --app="$1"
    '';
  };

  webappOpen = pkgs.writeShellApplication {
    name = "webapp-open";
    runtimeInputs = [
      pkgs.python3
      pkgs.xdg-utils
    ];
    text = ''
      exec python3 ${./webapp-open.py} "$@"
    '';
  };
}
