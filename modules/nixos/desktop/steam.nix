# Steam on niri + xwayland-satellite (Intel): without -system-composer the main
# client window is black / broken (CEF GPU compositor vs X11 damage tracking).
# extraArgs applies to every launch path (desktop, terminal, steam:// URIs).
# See: https://github.com/niri-wm/niri/wiki/Application-Specific-Issues#steam
{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    package = pkgs.steam.override {
      extraArgs = "-system-composer";
    };
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true; # Open ports in the firewall for Steam Local Network Game Transfers
  };
}
