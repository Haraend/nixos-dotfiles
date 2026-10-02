{ config, pkgs, ... }:

{
  # Installs kdeconnect-kde and opens firewall TCP/UDP 1714–1764.
  # Pair from kdeconnect-app; mDNS discovery via Avahi (networking.nix).
  programs.kdeconnect.enable = true;

  # User-scope daemon bound to the graphical session: restarts on crash and
  # starts/stops with Niri. Replaces a bare `spawn-at-startup "kdeconnectd"`
  # in the niri config. Package comes from the module (Qt6 kdePackages).
  systemd.user.services.kdeconnectd = {
    description = "KDE Connect daemon";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = "${config.programs.kdeconnect.package}/libexec/kdeconnectd";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # Required by the Noctalia kde-connect plugin for "Browse files" (SFTP mount).
  environment.systemPackages = [ pkgs.sshfs ];

  # Remote mouse/keyboard (phone → laptop) needs the RemoteDesktop portal
  # bridge on Niri — see modules/nixos/desktop/niri.nix (hypr-kdeconnect-portal).
  # After switch: systemctl --user restart xdg-desktop-portal; use Remote Input
  # on the phone. Optional: hypr-kdeconnect-portal --self-test-motion 120 0
}
