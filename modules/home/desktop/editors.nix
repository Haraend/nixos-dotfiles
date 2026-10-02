{ pkgs, lib, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default.userSettings = {
      "window.titleBarStyle" = "native";
      "window.zoomLevel" = 0;
      "editor.fontLigatures" = true;
    };
  };

  programs.micro = {
    enable = true;
    settings = {
      autoindent = true;
      autosu = false;
      cursorline = true;
      mkparents = true;
      mouse = true;
      savehistory = true;
      scrollbar = true;
      softwrap = true;
      tabsize = 2;
      tabstospaces = true;
    };
  };

  home.packages = with pkgs; [
    zed-editor
    code-cursor
    cursor-cli
  ];

  # Zed: declarative baseline copied to a writable file so the GUI can save changes.
  home.file.".config/zed/settings.json.template".source = ./zed/settings.json;

  home.activation.zedSettingsInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SETTINGS_FILE="$HOME/.config/zed/settings.json"
    TEMPLATE_FILE="$HOME/.config/zed/settings.json.template"

    if [ ! -f "$SETTINGS_FILE" ] || [ -L "$SETTINGS_FILE" ]; then
      echo "Initializing Zed settings from template..."
      mkdir -p "$(dirname "$SETTINGS_FILE")"
      rm -f -- "$SETTINGS_FILE"
      cp "$TEMPLATE_FILE" "$SETTINGS_FILE"
      chmod 644 "$SETTINGS_FILE"
    fi
  '';

  # Wayland env vars (ELECTRON_OZONE_PLATFORM_HINT, etc.) live in wayland-env.nix.
}
