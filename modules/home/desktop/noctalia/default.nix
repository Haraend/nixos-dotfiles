{ inputs, pkgs, lib, vars, ... }:

let
  wallpaper = builtins.toString vars.wallpaper;
  wallpaperDir = builtins.toString (builtins.dirOf vars.wallpaper);
  logo = builtins.toString ../../../../wallpapers/nixos-logo.png;
  suspendCmd =
    if vars.resumeDevice == null
    then "systemctl suspend"
    else "systemctl suspend-then-hibernate";
  settings = pkgs.writeText "noctalia-config.toml" (
    lib.replaceStrings
      [ "@WALLPAPER_DIR@" "@WALLPAPER@" "@LOGO@" "@LOCATION@" "@SUSPEND_CMD@" ]
      [ wallpaperDir wallpaper logo vars.location suspendCmd ]
      (builtins.readFile ./config.toml)
  );
in
{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # Noctalia theme templates write ~/.config/btop/themes/noctalia.theme (see config.toml theme.templates).
  stylix.targets.btop.enable = false;
  # Stylix's noctalia target injects attrset settings (theme/font/wallpaper/opacity).
  # That cannot merge with a TOML file; keep theming in config.toml.
  stylix.targets.noctalia.enable = false;

  programs.noctalia = {
    enable = true;
    package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
    systemd.enable = false;
    checkConfig = true;
    settings = settings;
  };

  programs.waybar.enable = lib.mkForce false;
}
