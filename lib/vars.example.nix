# Shared variables used across the configuration.
# Copy to lib/vars.nix and customize (lib/vars.nix is gitignored).
{
  # Account you already log in as. NixOS keeps that account's existing password.
  username = "youruser";
  fullName = "Your Name";
  email = "you@example.com";
  gitName = "Your Name";

  # Absolute path to this clone. Used by the nrs / nrb aliases only.
  # Wallpapers come from `wallpaper` below, not from this path.
  configPath = "/home/youruser/nixos-dotfiles";

  # SSH public keys for key-only login (see hosts/nixos/configuration.nix).
  # Leave this empty and SSH will not accept logins until you add one.
  sshPublicKeys = [
    # "ssh-ed25519 AAAA... you@host"
  ];

  # System configuration.
  # hostname is the network name. Rebuilds always use the flake output `#nixos`.
  hostname = "nixos";
  timezone = "America/New_York";
  # Noctalia weather query. Change this with timezone.
  location = "New York, United States";
  # Messages and UI. Do not include the "/UTF-8" archive suffix.
  locale = "en_US.UTF-8";
  # Calendar only. en_GB starts weeks on Monday.
  lcTime = "en_GB.UTF-8";

  # NixOS version. Leave this at the release you installed.
  stateVersion = "25.11";

  # Stylix palette source and the Noctalia wallpaper. Must be a path in this repo.
  wallpaper = ./../wallpapers/clouds.jpg;

  # Touchpad settings
  touchpad = {
    naturalScroll = true;
    tap = true;
    disableWhileTyping = true;
  };

  # Power management.
  # resumeDevice = null keeps lid-close and the power key on suspend.
  # After hardware-configuration.nix has a swap partition at least as large as RAM:
  #   resumeDevice = "/dev/disk/by-label/swap";
  resumeDevice = null;

  power = {
    hibernateDelaySec = "2h"; # Time after suspend before hibernating
  };
}
