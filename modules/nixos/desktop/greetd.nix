{ pkgs, ... }:

{
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session";
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
