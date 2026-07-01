# Wayland desktop utilities
{ pkgs, ... }:

let
  cliphistTextWatcher = pkgs.writeShellApplication {
    name = "cliphist-text-watcher";
    runtimeInputs = with pkgs; [
      cliphist
      wl-clipboard
    ];
    text = ''
      exec wl-paste --type text --watch cliphist store
    '';
  };
  cliphistImageWatcher = pkgs.writeShellApplication {
    name = "cliphist-image-watcher";
    runtimeInputs = with pkgs; [
      cliphist
      wl-clipboard
    ];
    text = ''
      exec wl-paste --type image --watch cliphist store
    '';
  };
in
{
  home.packages = with pkgs; [
    # Clipboard
    wl-clipboard   # Wayland copy/paste (wl-copy, wl-paste)
    cliphist       # Clipboard history manager
    wtype          # Type text via Wayland

    # Screenshots
    grim           # Screenshot tool
    slurp          # Region selection for screenshots

    # Controls
    brightnessctl  # Screen brightness control
    playerctl      # Media player control (play/pause/next/prev)

    # Archives
    unzip          # Extract .zip files
    zip            # Create .zip files
    p7zip          # 7z, 7za - 7-Zip for .7z and many formats
    unrar          # Extract .rar files
    gnutar         # tar with gzip/bzip2/xz support
  ];

  systemd.user.services.cliphist-text-watcher = {
    Unit = {
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${cliphistTextWatcher}/bin/cliphist-text-watcher";
      Restart = "always";
      RestartSec = 1;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.services.cliphist-image-watcher = {
    Unit = {
      After = [ "graphical-session.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      ExecStart = "${cliphistImageWatcher}/bin/cliphist-image-watcher";
      Restart = "always";
      RestartSec = 1;
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };
}