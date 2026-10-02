# Stylix - Automated theming engine
# Sets wallpaper, colors, cursor, and fonts system-wide
{ pkgs, vars, ... }:

{
  # Plain JetBrains Mono for apps (e.g. Obsidian) that should not use the Nerd Font.
  fonts.packages = [ pkgs.jetbrains-mono ];

  stylix = {
    enable = true;
    image = vars.wallpaper;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";

    # Plymouth theme is managed in modules/nixos/boot.nix (spinner).
    targets.plymouth.enable = false;

    opacity.terminal = 0.95;

    cursor = {
      package = pkgs.catppuccin-cursors.mochaMauve;
      name = "Catppuccin-Mocha-Mauve-Cursors";
      size = 24;
    };

    icons = {
      enable = true;
      package = pkgs.papirus-icon-theme;
      dark = "Papirus-Dark";
      light = "Papirus-Light";
    };

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };
      sizes = {
        applications = 12;
        terminal = 12;
        desktop = 11;
        popups = 12;
      };
    };
  };
}
