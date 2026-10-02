# Trial: these helpers call TLP, which is commented out in
# modules/nixos/hardware/power.nix. Noctalia's power tab owns the charge
# stop threshold for now. Uncomment the block below together with services.tlp
# to restore the 75/80 cap and the `fullcharge` / `chargelimit` commands.
#
# Base thresholds (75% start / 80% stop) lived in power.nix via TLP:
#   fullcharge   → charge to 100% this cycle; TLP's udev hook reverts to
#                  75/80% automatically on the next AC unplug.
#   chargelimit  → re-apply the configured 75/80% thresholds immediately.
{ ... }:
{
  # { config, lib, pkgs, ... }:
  #
  # let
  #   fullcharge = pkgs.writeShellApplication {
  #     name = "fullcharge";
  #     runtimeInputs = with pkgs; [ tlp libnotify ];
  #     text = ''
  #       set -eu
  #       sudo -n tlp fullcharge
  #       notify-send -a "Battery" "Full charge enabled" \
  #         "Charging to 100% this cycle — reverts to 75/80% on next AC unplug."
  #     '';
  #   };
  #
  #   chargelimit = pkgs.writeShellApplication {
  #     name = "chargelimit";
  #     runtimeInputs = with pkgs; [ tlp libnotify ];
  #     text = ''
  #       set -eu
  #       sudo -n tlp setcharge
  #       notify-send -a "Battery" "Charge thresholds restored" \
  #         "Re-applied configured thresholds (75% start / 80% stop)."
  #     '';
  #   };
  # in
  # {
  #   home.packages = [ fullcharge chargelimit ];
  # }
}
