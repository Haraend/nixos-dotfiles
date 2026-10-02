# NixOS service modules
{ ... }:

{
  imports = [
    ./networking.nix
    ./polkit.nix
    ./fprintd.nix
    ./ssh.nix
    ./docker.nix
    ./fwupd.nix
    ./earlyoom.nix
    ./kdeconnect.nix
    ./adb.nix
  ];

  # GNOME Keyring - required for Secret portal (screenshare, etc.)
  services.gnome.gnome-keyring.enable = true;
}
