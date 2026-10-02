# Shell configuration modules
{ ... }:

{
  imports = [
    ./zsh.nix
    ./starship.nix
    ./navigation.nix
    ./cli-replacements.nix
    ./dev-tools.nix
    ./aliases.nix
    ./yazi.nix
    ./fnm.nix
    ./python.nix
    ./java.nix
    ./flutter.nix
    ./battery.nix
  ];
}
