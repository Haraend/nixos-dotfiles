# Wayland environment variables — shared across all Wayland apps
# NOTE: Do NOT set GDK_BACKEND globally - it breaks the screencast portal per Niri docs
{ ... }:

{
  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland;xcb";
    XDG_CURRENT_DESKTOP = "niri";
    XDG_SESSION_DESKTOP = "niri";
    XDG_SESSION_TYPE = "wayland";
    DESKTOP_SESSION = "niri";

    # Portal and Electron fixes
    GTK_USE_PORTAL = "1";
    ELECTRON_OZONE_PLATFORM_HINT = "wayland";

    # Noctalia lockscreen PAM (fingerprint via /etc/pam.d/noctalia-lock only)
    NOCTALIA_PAM_SERVICE = "noctalia-lock";
  };
}
