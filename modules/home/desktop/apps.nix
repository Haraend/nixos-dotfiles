# GUI applications — Vesktop, Spotify, OBS, Obsidian, etc.
{ pkgs, ... }:

let
  qimgvDesktop = "qimgv.desktop";
  vlcDesktop = "vlc.desktop";
  # Id is the filename, not the Name ("Audacity 4 Portable").
  # Audacity stays installed for waveform editing; VLC owns playback defaults.
  mimeAssociations = desktop: types:
    builtins.listToAttrs (
      map
        (name: {
          inherit name;
          value = [ desktop ];
        })
        types
    );
  imageMimeTypes = [
    "image/jpeg"
    "image/png"
    "image/gif"
    "image/webp"
    "image/bmp"
    "image/tiff"
    "image/avif"
    "image/heif"
    "image/heic"
    "image/jxl"
  ];
  videoMimeTypes = [
    "video/mp4"
    "video/webm"
    "video/x-matroska"
    "video/quicktime"
    "video/x-msvideo"
    "video/mpeg"
    "video/ogg"
    "video/x-ms-wmv"
    "video/mp2t"
  ];
  audioMimeTypes = [
    "audio/mpeg"
    "audio/mp3"
    "audio/x-mp3"
    "audio/x-mpeg"
    "audio/aac"
    "audio/x-aac"
    "audio/mp4"
    "audio/x-m4a"
    "audio/flac"
    "audio/x-flac"
    "audio/ogg"
    "audio/x-vorbis+ogg"
    "audio/opus"
    "audio/x-opus+ogg"
    "audio/wav"
    "audio/x-wav"
    "audio/x-wavpack"
    "audio/x-ms-wma"
    "audio/mpegurl"
    "audio/x-mpegurl"
    "audio/x-scpls"
    "application/xspf+xml"
  ];
  imageAssociations = mimeAssociations qimgvDesktop imageMimeTypes;
  videoAssociations = mimeAssociations vlcDesktop videoMimeTypes;
  audioAssociations = mimeAssociations vlcDesktop audioMimeTypes;
  # nixpkgs ships these filenames, not libreoffice-*.desktop.
  writerDesktop = "writer.desktop";
  calcDesktop = "calc.desktop";
  impressDesktop = "impress.desktop";
  writerMimeTypes = [
    "application/msword" # .doc
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document" # .docx
    "application/vnd.oasis.opendocument.text" # .odt
    "application/rtf" # .rtf
    "text/rtf"
  ];
  calcMimeTypes = [
    "application/vnd.ms-excel" # .xls
    "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" # .xlsx
    "application/vnd.oasis.opendocument.spreadsheet" # .ods
  ];
  impressMimeTypes = [
    "application/vnd.ms-powerpoint" # .ppt
    "application/vnd.openxmlformats-officedocument.presentationml.presentation" # .pptx
    "application/vnd.oasis.opendocument.presentation" # .odp
  ];
  officeAssociations =
    mimeAssociations writerDesktop writerMimeTypes
    // mimeAssociations calcDesktop calcMimeTypes
    // mimeAssociations impressDesktop impressMimeTypes;
  mediaAssociations =
    imageAssociations // videoAssociations // audioAssociations // officeAssociations;
in
{
  home.packages = with pkgs; [
    # Communication
    vesktop

    # Media
    obs-studio
    spotify
    pavucontrol
    qimgv # Folder image gallery; MIME defaults below for Thunar
    vlc # Local audio/video playback; MIME defaults below for Thunar
    audacity # Waveform editing (not the Thunar playback default)

    # Office — Writer/Calc/Impress; MIME defaults below for Thunar
    libreoffice

    # Notes
    obsidian

    # Files
    file-roller # GUI archive manager (zip, tar, 7z, etc.)

    # Display / monitor management
    # (GUI arranger `wdisplays` and the Kanshi autoconfig daemon live in
    # ./kanshi.nix — nwg-displays was dropped because it only supports
    # Sway/Hyprland IPC, not the wlr-output-management protocol Niri uses.)
    wl-mirror # Mirror one Wayland output into a window (stand-in for "duplicate")
    wlr-randr # CLI to query/set output state (used by scripts & tools)

    # Databases
    mongodb-compass
    # Force light GTK so Eclipse SWT chrome matches DBeaver Light under Stylix dark.
    # Desktop Exec hardcodes the unwrapped store path — retarget it to the wrap.
    (pkgs.symlinkJoin {
      name = "dbeaver-bin";
      paths = [ pkgs.dbeaver-bin ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/dbeaver --set GTK_THEME Adwaita:light

        rm -f $out/share/applications/dbeaver.desktop
        cp ${pkgs.dbeaver-bin}/share/applications/dbeaver.desktop \
          $out/share/applications/dbeaver.desktop
        chmod +w $out/share/applications/dbeaver.desktop
        substituteInPlace $out/share/applications/dbeaver.desktop \
          --replace-fail "${pkgs.dbeaver-bin}/bin/dbeaver" "$out/bin/dbeaver"
      '';
    })

    # Hardware / imaging — Imager 2.x requires a root GUI; elevate via setuid pkexec + XWayland
    (pkgs.symlinkJoin {
      name = "rpi-imager";
      paths = [ pkgs.rpi-imager ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        rm -f $out/bin/rpi-imager
        makeWrapper ${pkgs.writeShellScript "rpi-imager-elevated" ''
          ${pkgs.xhost}/bin/xhost +SI:localuser:root >/dev/null 2>&1 || true
          /run/wrappers/bin/pkexec env \
            DISPLAY="''${DISPLAY:-}" \
            XAUTHORITY="''${XAUTHORITY:-}" \
            XDG_RUNTIME_DIR="''${XDG_RUNTIME_DIR:-}" \
            QT_QPA_PLATFORM=xcb \
            ${pkgs.rpi-imager}/bin/rpi-imager "$@"
          status=$?
          ${pkgs.xhost}/bin/xhost -SI:localuser:root >/dev/null 2>&1 || true
          exit "$status"
        ''} $out/bin/rpi-imager
      '';
    })

    # Password manager CLI (bw login after switch)
    bitwarden-cli

    # Games
    prismlauncher
  ];

  # Do not bind inode/directory — that would steal folder open from Thunar.
  xdg.mimeApps = {
    enable = true;
    associations.added = mediaAssociations;
    defaultApplications = mediaAssociations;
  };
}
