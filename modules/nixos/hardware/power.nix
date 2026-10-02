{ config, pkgs, inputs, vars, lib, ... }:

let
  noctalia = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  canHibernate = vars.resumeDevice != null;
  sleepAction = if canHibernate then "suspend-then-hibernate" else "suspend";
in
{
  # Set vars.resumeDevice to the swap device from hardware-configuration.nix
  # (a partition at least as large as RAM). Until then the lid and power key suspend.
  boot = lib.optionalAttrs canHibernate {
    resumeDevice = vars.resumeDevice;
  };

  # Compressed RAM swap in front of the disk swap partition: cold pages get
  # zstd-compressed instead of written to NVMe. Hibernation is unaffected —
  # it always writes to resumeDevice (the disk swap), never to zram.
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 50;
  };

  services.thermald.enable = true;

  # Bluetooth (GUI is handled by Noctalia — no blueman applet needed)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Trial: Noctalia's power tab speaks to power-profiles-daemon. TLP cannot
  # run beside it, so the 75/80 charge window and its sudo rules are commented
  # out. Uncomment TLP and set the daemon back to false if the trial fails.
  # The ThinkPad EC still has TLP's 75/80. UPower treats that as "set by
  # another tool" until EnableChargeThreshold adopts those values.
  services.power-profiles-daemon.enable = true;
  # services.tlp = {
  #   enable = true;
  #   settings = {
  #     START_CHARGE_THRESH_BAT0 = 75;
  #     STOP_CHARGE_THRESH_BAT0 = 80;
  #   };
  # };

  # Passwordless sudo for the TLP subcommands used by the `fullcharge` /
  # `chargelimit` helpers (see modules/home/shell/battery.nix). Each rule
  # matches the exact command with no extra args, which is all the helpers
  # invoke. TLP's udev hooks auto-revert `fullcharge` on next AC unplug.
  # security.sudo.extraRules = [
  #   {
  #     users = [ vars.username ];
  #     commands = [
  #       { command = "${pkgs.tlp}/bin/tlp fullcharge"; options = [ "NOPASSWD" ]; }
  #       { command = "${pkgs.tlp}/bin/tlp setcharge"; options = [ "NOPASSWD" ]; }
  #     ];
  #   }
  # ];

  # Battery info (for Noctalia battery widget)
  services.upower.enable = true;

  # Adopt the existing 75/80 window so Noctalia's charge-threshold toggle works.
  # UPower saves this in /var/lib/upower/charging-threshold-status; the oneshot
  # covers a boot where that file is missing and the EC limits are still set.
  systemd.services.upower-adopt-charge-threshold = {
    description = "Let UPower own the battery charge thresholds";
    after = [ "upower.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      dev=/org/freedesktop/UPower/devices/battery_BAT0
      iface=org.freedesktop.UPower.Device
      for _ in $(seq 1 30); do
        enabled=$(${pkgs.systemd}/bin/busctl get-property org.freedesktop.UPower "$dev" "$iface" ChargeThresholdEnabled 2>/dev/null || true)
        case "$enabled" in
          "b true")
            exit 0
            ;;
          "b false")
            ${pkgs.systemd}/bin/busctl call org.freedesktop.UPower "$dev" "$iface" EnableChargeThreshold b true
            exit 0
            ;;
        esac
        sleep 1
      done
    '';
  };

  # Logind configuration (Hardware Event Handlers)
  # Available actions: ignore, poweroff, reboot, halt, kexec, suspend, hibernate, suspend-then-hibernate, lock
  services.logind.settings.Login = {
    HandleLidSwitch = sleepAction;
    HandleLidSwitchExternalPower = "lock";
    HandlePowerKey = sleepAction;
    HandleLidSwitchDocked = "lock";
    HandlePowerKeyLongPress = "poweroff";
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = vars.power.hibernateDelaySec;
  };

  # Lock before sleep via Noctalia IPC (loginctl lock-sessions is a no-op when Noctalia's
  # logind Lock-signal listener is inactive). The `msg` client derives its socket name from
  # WAYLAND_DISPLAY, so we recover it from the live session socket (noctalia-wayland-*.sock);
  # skip noctalia-dmenu-*.sock (launcher IPC) which would set the wrong display and skip lock.
  # Stop fprintd afterwards for a fresh PAM session after resume.
  powerManagement.powerDownCommands = ''
    uid=$(${pkgs.coreutils}/bin/id -u ${vars.username})
    runtime_dir=/run/user/$uid
    sock=$(${pkgs.coreutils}/bin/ls "$runtime_dir"/noctalia-wayland-*.sock 2>/dev/null | ${pkgs.coreutils}/bin/head -n1 || true)
    if [ -n "$sock" ]; then
      wl=$(${pkgs.coreutils}/bin/basename "$sock" .sock)
      wl=''${wl#noctalia-}
      ${pkgs.util-linux}/bin/runuser -u ${vars.username} -- \
        ${pkgs.coreutils}/bin/env XDG_RUNTIME_DIR="$runtime_dir" WAYLAND_DISPLAY="$wl" \
        ${noctalia}/bin/noctalia msg session lock 2>/dev/null || true
    fi
    ${pkgs.coreutils}/bin/sleep 1
    ${pkgs.systemd}/bin/systemctl stop fprintd.service 2>/dev/null || true
  '';

  powerManagement.resumeCommands = ''
    ${pkgs.systemd}/bin/systemctl start fprintd.service 2>/dev/null || true
  '';
}
