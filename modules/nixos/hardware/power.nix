{ config, pkgs, vars, ... }:

{
  # Bluetooth (GUI is handled by Noctalia — no blueman applet needed)
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  # Power management (TLP for battery thresholds)
  # NOTE: TLP owns CPU power profiles here, so Noctalia's PowerProfile card
  # (which speaks to power-profiles-daemon) is intentionally inert — PPD and
  # TLP are mutually exclusive.
  services.power-profiles-daemon.enable = false;
  services.tlp = {
    enable = true;
    settings = {
      START_CHARGE_THRESH_BAT0 = 75;
      STOP_CHARGE_THRESH_BAT0 = 80;
    };
  };

  # Passwordless sudo for the TLP subcommands used by the `fullcharge` /
  # `chargelimit` helpers (see modules/home/shell/battery.nix). Each rule
  # matches the exact command with no extra args, which is all the helpers
  # invoke. TLP's udev hooks auto-revert `fullcharge` on next AC unplug.
  security.sudo.extraRules = [
    {
      users = [ vars.username ];
      commands = [
        { command = "${pkgs.tlp}/bin/tlp fullcharge"; options = [ "NOPASSWD" ]; }
        { command = "${pkgs.tlp}/bin/tlp setcharge";  options = [ "NOPASSWD" ]; }
      ];
    }
  ];

  # Battery info (for Noctalia battery widget)
  services.upower.enable = true;

  # Logind configuration (Hardware Event Handlers)
  # Available actions: ignore, poweroff, reboot, halt, kexec, suspend, hibernate, suspend-then-hibernate, lock
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "lock";
    HandlePowerKey = "suspend-then-hibernate";
    HandleLidSwitchDocked="lock";
    HandlePowerKeyLongPress="poweroff";
  };

  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = vars.power.hibernateDelaySec;
  };
}
