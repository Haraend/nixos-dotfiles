# Google Antigravity 2.0 — base (agent app), IDE, and CLI via antigravity-nix flake
{ pkgs, inputs, ... }:

let
  ag = inputs.antigravity-nix.packages.${pkgs.stdenv.hostPlatform.system};
in
{
  home.packages = [
    ag.google-antigravity-no-fhs # base / agent command center (antigravity)
    ag.google-antigravity-ide-no-fhs # VS Code-style IDE (antigravity-ide)
    ag.google-antigravity-cli # CLI (agy)
  ];
}
