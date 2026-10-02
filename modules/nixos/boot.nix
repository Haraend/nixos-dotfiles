# Bootloader, Plymouth splash, and quiet boot
{ ... }:

{
  boot = {
    loader = {
      systemd-boot = {
        enable = true;
        configurationLimit = 8;
      };
      efi.canTouchEfiVariables = true;
      timeout = 1;
    };

    plymouth = {
      enable = true;
      # fade-in = NixOS logo + shimmering stars; spinner = simple dots only
      theme = "spinner";
    };

    consoleLogLevel = 3;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
  };
}
