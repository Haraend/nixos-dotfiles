# Modern CLI replacements: eza, bat, delta, fd, ripgrep
{ config, lib, pkgs, ... }:

{
  # Eza - modern ls (configured via module for theming)
  programs.eza = {
    enable = true;
    git = true;
    icons = "auto"; # Auto-detect if icons should be shown
    enableZshIntegration = false; # We manage aliases manually
    enableBashIntegration = false;
  };

  # Bat - cat with syntax highlighting
  programs.bat = {
    enable = true;
    config = {
      paging = "never";
      style = "numbers,changes";
    };
  };

  # Delta - pretty git diffs
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
    };
  };

  # Additional CLI tools
  home.packages = with pkgs; [
    fd # Modern find
    ripgrep # Fast code search (rg)
  ];
}
