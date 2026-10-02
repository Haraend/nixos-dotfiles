{ config, ... }:

{
  networking.networkmanager.enable = true;

  # Don't block boot on Wi-Fi/DHCP; NM still connects in the background.
  systemd.services."NetworkManager-wait-online".enable = false;

  # mDNS/DNS-SD for local network discovery (access via hostname.local)
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };
}
