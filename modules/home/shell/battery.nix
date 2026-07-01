# Battery charge threshold helpers.
#
# Base thresholds (75% start / 80% stop) live in
# modules/nixos/hardware/power.nix via TLP. These helpers let you bypass the
# cap occasionally without rebuilding or editing the system config:
#
#   fullcharge   → charge to 100% this cycle; TLP's udev hook reverts to
#                  75/80% automatically on the next AC unplug.
#   chargelimit  → re-apply the configured 75/80% thresholds immediately
#                  (useful if you unplug briefly and want the cap back).
#
# Passwordless sudo for the exact `tlp fullcharge` / `tlp setcharge` calls
# below is granted in power.nix, so these run without a password prompt —
# safe to bind to keybinds or Noctalia custom power buttons.
{ config, lib, pkgs, ... }:

let
  fullcharge = pkgs.writeShellApplication {
    name = "fullcharge";
    runtimeInputs = with pkgs; [ tlp libnotify ];
    text = ''
      set -eu
      sudo -n tlp fullcharge
      notify-send -a "Battery" "Full charge enabled" \
        "Charging to 100% this cycle — reverts to 75/80% on next AC unplug."
    '';
  };

  chargelimit = pkgs.writeShellApplication {
    name = "chargelimit";
    runtimeInputs = with pkgs; [ tlp libnotify ];
    text = ''
      set -eu
      sudo -n tlp setcharge
      notify-send -a "Battery" "Charge thresholds restored" \
        "Re-applied configured thresholds (75% start / 80% stop)."
    '';
  };
in
{
  home.packages = [ fullcharge chargelimit ];
}
