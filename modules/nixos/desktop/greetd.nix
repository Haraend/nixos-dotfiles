{ pkgs, lib, config, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        # --cmd is the durable fallback: --remember-session stores an absolute
        # /nix/store/…-desktops/…/niri.desktop path that GC can collect.
        # --sessions is the NixOS session dir (not /usr/share/wayland-sessions).
        command = lib.concatStringsSep " " [
          (lib.getExe pkgs.tuigreet)
          "--time"
          "--remember"
          "--remember-session"
          "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
          "--cmd ${config.programs.niri.package}/bin/niri-session"
        ];
        user = "greeter";
      };
    };
  };

  # Auto-unlock GNOME Keyring when logging in via greetd
  # Without this, apps using the keyring (Chrome, SSH agent, Wi-Fi) prompt separately
  security.pam.services.greetd.enableGnomeKeyring = true;
  security.pam.services.login.enableGnomeKeyring = true;

  # Disable other display managers if enabled by default
  services.displayManager.sddm.enable = false;
  services.displayManager.gdm.enable = false;
}
