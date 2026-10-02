# Foot - lightweight Wayland-native terminal emulator (trial)
# Theming (colors, font, opacity) comes from Stylix via autoEnable; no manual config here.
{ ... }:

{
  programs.foot.enable = true;

  # Match Alacritty's window padding ("pad" since foot 1.24; Stylix owns colors/font/opacity)
  programs.foot.settings.main.pad = "10x10";
}
