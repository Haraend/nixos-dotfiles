{ config, lib, pkgs, ... }:

{
  # Enable polkit for privilege escalation
  security.polkit.enable = true;

  # Install polkit agent (auto-started by desktop environments)
  # For standalone WMs like Niri, we need to start it manually
  environment.systemPackages = with pkgs; [
    polkit_gnome
  ];

  # Auto-start polkit agent for users in graphical session
  # This will work with Niri and other WMs
  systemd.user.services.polkit-gnome-authentication-agent-1 = {
    description = "polkit-gnome-authentication-agent-1";
    wantedBy = [ "graphical-session.target" ];
    wants = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = 10;
    };
  };
}
