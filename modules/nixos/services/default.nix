# NixOS service modules
{ ... }:

{
  imports = [
    ./networking.nix
    ./polkit.nix
    ./ssh.nix
    ./docker.nix
  ];

  programs.kdeconnect.enable = true;

  # GNOME Keyring - required for Secret portal (screenshare, etc.)
  services.gnome.gnome-keyring.enable = true;
}
