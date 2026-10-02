# OpenCode — terminal AI coding agent (pkgs.opencode via Home Manager).
# Leave settings / tui / skills unset so ~/.config/opencode stays writable:
# /connect and `npx skills add -g` write there; a store symlink would block them.
# Auth lives in ~/.local/share/opencode/auth.json (not Nix).
# Do not run `opencode upgrade` — the Nix wrap sets OPENCODE_DISABLE_AUTOUPDATE.
# Newer builds: nix flake update nixpkgs home-manager stylix nixos-hardware
{ ... }:

{
  programs.opencode.enable = true;
}
