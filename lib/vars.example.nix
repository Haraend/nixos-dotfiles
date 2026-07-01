# Shared variables used across the configuration.
# Copy to lib/vars.nix and customize (lib/vars.nix is gitignored).
{
  # User configuration
  username = "youruser";
  fullName = "Your Name";
  email = "you@example.com";
  gitName = "Your Name";

  # Absolute path to this repo clone (Noctalia wallpaper directory)
  configPath = "/home/youruser/nixos-dotfiles";

  # SSH public keys for key-only login (see hosts/nixos/configuration.nix)
  sshPublicKeys = [
    # "ssh-ed25519 AAAA... you@host"
  ];

  # System configuration
  hostname = "nixos";
  timezone = "America/New_York";
  locale = "en_US.UTF-8";

  # NixOS version
  stateVersion = "25.11";

  # Wallpaper
  wallpaper = ./../wallpapers/clouds.jpg;

  # Touchpad settings
  touchpad = {
    naturalScroll = true;
    tap = true;
    disableWhileTyping = true;
  };

  # Power management
  power = {
    hibernateDelaySec = "2h"; # Time after suspend before hibernating
  };
}
