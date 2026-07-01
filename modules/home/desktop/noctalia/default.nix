{ config, inputs, pkgs, lib, vars, ... }:

let
  settingsTemplate =
    lib.replaceStrings
      [ "@HOME@" "@CONFIG@" ]
      [ config.home.homeDirectory vars.configPath ]
      (builtins.readFile ./settings.json);
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  home.packages = [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];

  # Create a template file in the store based on our repo's settings.json
  # We do NOT link the actual settings.json because we want it to be mutable (rw).
  home.file.".config/noctalia/settings.json.template".text = settingsTemplate;

  # Activation script: "Bootstrap" logic
  # 1. Runs on every rebuild/activation.
  # 2. Checks if the live settings file exists.
  # 3. IF MISSING (or is a symlink/read-only): Overwrite it with our template and make it writable.
  # 4. IF EXISTS: Leave it alone (preserves your un-synced local changes).
  home.activation.noctaliaSettingsInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    SETTINGS_FILE="$HOME/.config/noctalia/settings.json"
    TEMPLATE_FILE="$HOME/.config/noctalia/settings.json.template"

    # If file doesn't exist OR is a symlink (which means it's an old direct-link from Nix)
    if [ ! -f "$SETTINGS_FILE" ] || [ -L "$SETTINGS_FILE" ]; then
      echo "Initializing Noctalia settings from template..."
      mkdir -p "$(dirname "$SETTINGS_FILE")"

      # Remove it first if it's a symlink or file
      rm -f "$SETTINGS_FILE"

      # Copy the template content to a real file
      cp "$TEMPLATE_FILE" "$SETTINGS_FILE"

      # IMPORTANT: Make it writable so the GUI can save changes
      chmod 644 "$SETTINGS_FILE"
    fi
  '';

  # Disable Waybar if it was enabled (Noctalia replaces it)
  programs.waybar.enable = lib.mkForce false;
}
