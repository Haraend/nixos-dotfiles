{ config, lib, ... }:

{
  services.openssh = {
    enable = true;
    ports = [ 22 ];
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
      AllowTcpForwarding = false;
      AllowAgentForwarding = false;
    };
    openFirewall = true;
  };

  # Block repeated failed login attempts
  services.sshguard.enable = true;
}
