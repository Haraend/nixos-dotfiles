# Stylix - Automated theming engine
# Sets wallpaper, colors, cursor, and fonts system-wide
{ pkgs, vars, ... }:

{
  stylix = {
    enable = true;
    image = vars.wallpaper;
    base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
    polarity = "dark";
    
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
