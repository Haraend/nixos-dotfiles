{ config, ... }:

{
  networking.networkmanager.enable = true;

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
