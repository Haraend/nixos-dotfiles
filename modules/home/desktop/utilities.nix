# Wayland desktop utilities
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Clipboard (history is handled by Noctalia)
    wl-clipboard # Wayland copy/paste (wl-copy, wl-paste)

    # Controls
    brightnessctl # Screen brightness control

    # Noctalia screen_recorder plugin (plugin.toml dependencies)
    gpu-screen-recorder

    # Archives
    unzip # Extract .zip files
    zip # Create .zip files
    p7zip # 7z, 7za - 7-Zip for .7z and many formats
    unrar # Extract .rar files
    gnutar # tar with gzip/bzip2/xz support

    # Media CLI used by Puppeteer and local encodes
    ffmpeg
  ];
}
