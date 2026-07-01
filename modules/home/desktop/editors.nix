{ pkgs, ... }:

{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;

    profiles.default.userSettings = {
      "window.titleBarStyle" = "native";
      "window.zoomLevel" = 0;
      "editor.fontLigatures" = true;
    };
  };

  programs.micro = {
    enable = true;
    settings = {
      autoindent = true;
      autosu = false;
      cursorline = true;
      mkparents = true;
      mouse = true;
      savehistory = true;
      scrollbar = true;
      softwrap = true;
      tabsize = 2;
      tabstospaces = true;
    };
  };

  home.packages = with pkgs; [
    zed-editor
    code-cursor
  ];

  # Antigravity 2.0 (base app, IDE, CLI) is in modules/home/desktop/antigravity.nix.
  # Wayland env vars (ELECTRON_OZONE_PLATFORM_HINT, etc.) live in wayland-env.nix.
}
