# Development tools: direnv, lazygit, htop
{ config, lib, pkgs, ... }:

let
  localBin = "${config.home.homeDirectory}/.local/bin";
in

{
  # Direnv - auto-load project environments
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;  # Better nix integration
  };

  # Lazygit - terminal git UI (module enabled for theming)
  programs.lazygit.enable = true;

  # Htop - process viewer (module enabled for theming)
  programs.htop = {
    enable = true;
    settings.show_program_path = false;
  };

  # Additional dev packages
  home.packages = with pkgs; [
    nh            # Nix helper
    gh            # GitHub CLI
    awscli2       # AWS CLI v2
    uv            # Fast Python package installer and resolver
  ];

  # uv tool install puts binaries here; can't use `uv tool update-shell` because
  # Home Manager owns ~/.zshenv (read-only symlink into the Nix store).
  home.sessionPath = [ localBin ];

  # fnm + micromamba init in .zshrc run after hm-session-vars and rebuild PATH,
  # dropping ~/.local/bin. Re-prepend at the very end of zsh startup.
  programs.zsh.initContent = lib.mkAfter ''
    path=("${localBin}" ''${path[@]})
  '';
}
