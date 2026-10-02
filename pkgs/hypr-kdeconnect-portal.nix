{ lib
, stdenv
, fetchFromGitHub
, cmake
, pkg-config
, qt6
, wayland
, wayland-scanner
, libxkbcommon
, libei
,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "hypr-kdeconnect-portal";
  version = "0.1.0-unstable-2026-07-26";

  src = fetchFromGitHub {
    owner = "gfhdhytghd";
    repo = "hypr-kdeconnect-fix";
    rev = "e86a0fb17826cb8ea987665ded7428534e4a1a9d";
    hash = "sha256-VcXxVtlnkPjO6l0ky/n+0qa87Uc3c8hRM0twfgl+AiM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
    wayland-scanner
  ];

  buildInputs = [
    qt6.qtbase
    wayland
    libxkbcommon
    libei
  ];

  cmakeFlags = [
    "-DHKCF_PORTAL_USE_IN=wlroots;Hyprland;sway;Wayfire;river;phosh;niri;labwc"
  ];

  meta = {
    description = "RemoteDesktop portal bridge for KDE Connect remote input on Niri/wlroots";
    homepage = "https://github.com/gfhdhytghd/hypr-kdeconnect-fix";
    license = lib.licenses.mit;
    platforms = lib.platforms.linux;
    mainProgram = "hypr-kdeconnect-portal";
  };
})
