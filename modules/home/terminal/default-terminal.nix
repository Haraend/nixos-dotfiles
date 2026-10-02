# Default terminal wiring - the single place that decides which emulator is "the" default.
# Flip the default by editing this file only; consumers (niri binds, Thunar actions,
# $TERMINAL, xdg-terminal-exec, Xfce helpers) all resolve through it.
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    xdg-terminal-exec # Spec-based launcher: resolves default from xdg-terminals.list
  ];

  home.sessionVariables.TERMINAL = "foot";

  # xdg-terminal-exec priority list (desktop entry IDs; first match wins)
  xdg.configFile."xdg-terminals.list".text = ''
    foot.desktop
    Alacritty.desktop
  '';

  # Xfce/exo helper lookup used by Thunar and other XFCE-derived launchers
  xdg.configFile."xfce4/helpers.rc".text = ''
    [Default]
    TerminalEmulator=foot
    TerminalEmulatorDismissed=true
  '';
}
