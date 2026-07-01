{ config, pkgs, lib, inputs, vars, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos  # Imports all NixOS modules via default.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-t14-intel-gen1
  ];

  # Hostname (from shared vars)
  networking.hostName = vars.hostname;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Nix settings
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      max-jobs = "auto";
      cores = 0;
    };
    # Run store deduplication on a timer instead of synchronously during every
    # build (auto-optimise-store) — the sync version noticeably slows rebuilds.
    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # Timezone and locale (from shared vars)
  time.timeZone = vars.timezone;
  i18n.defaultLocale = vars.locale;

  # Keyboard
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # User configuration
  users.users.${vars.username} = {
    isNormalUser = true;
    description = vars.fullName;
    shell = pkgs.zsh;  # Set Zsh as default shell
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "kvm" "input" ];
    openssh.authorizedKeys.keys = vars.sshPublicKeys;
  };

  # Enable Zsh system-wide (required for user shell)
  programs.zsh.enable = true;

  # Home Manager
  home-manager = {
    extraSpecialArgs = { inherit inputs vars; };
    users.${vars.username} = import ./home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    overwriteBackup = true;
    # backupFileExtension does not handle dead symlinks (e.g. Stylix/Kvantum after nix gc).
    backupCommand = lib.getExe (pkgs.writeShellScriptBin "hm-backup" ''
      set -eu
      target="$1"
      ext="''${HOME_MANAGER_BACKUP_EXT:-backup}"
      if [ -L "$target" ] && [ ! -e "$target" ]; then
        rm -f -- "$target"
        exit 0
      fi
      backup="$target.$ext"
      if [ -e "$backup" ] || [ -L "$backup" ]; then
        rm -rf -- "$backup"
      fi
      mv -- "$target" "$backup"
    '');
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # System packages
  environment.systemPackages = with pkgs; [
    vim
    wget
    git
    btop
    fastfetch
  ];

  # Enable nix-ld for unpatched binaries (e.g. Node.js from FNM)
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    stdenv.cc.cc.lib
    zlib
  ];

  # Xbox controller support
  hardware.xpadneo.enable = true;

  # Do not change - tracks initial install version
  system.stateVersion = vars.stateVersion;
}
