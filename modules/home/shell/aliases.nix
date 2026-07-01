# Shell aliases
{ config, lib, pkgs, ... }:

{
  # Shell aliases for better defaults
  home.shellAliases = {
    # Navigation shortcuts (use builtin cd for parent dirs)
    ".." = "builtin cd ..";
    "..." = "builtin cd ../..";
    "...." = "builtin cd ../../..";
    "....." = "builtin cd ../../../..";
    
    # Quick directory access
    "~" = "builtin cd ~";
    "-" = "builtin cd -";
    
    # eza aliases (enhanced for graphical terminal)
    ls = "eza --icons --group-directories-first";
    ll = "eza --icons --group-directories-first -la --git --header --time-style=iso";
    la = "eza --icons --group-directories-first -a";
    lt = "eza --icons --group-directories-first --tree --level=2";
    l = "eza --icons --group-directories-first -l --header";
    
    # ripgrep with smart case
    rg = "rg --smart-case";
    
    # Quick edit/view
    e = "$EDITOR";
    v = "bat";
    
    # Git shortcuts (complement to lazygit)
    g = "git";
    gs = "git status";
    ga = "git add";
    gc = "git commit";
    gp = "git push";
    gl = "git log --oneline -10";
    gd = "git diff";
    lg = "lazygit";
    
    # System
    reload = "source ~/.zshrc";
    
    # NixOS specific
    nrs = "sudo nixos-rebuild switch --flake .#nixos";
    nrb = "sudo nixos-rebuild build --flake .#nixos";
    nfu = "nix flake update";

    # Cursor: unset NIXOS_OZONE_WL so the Nix Electron wrapper does not inject
    # Chromium flags Cursor warns about. Wayland still comes from ELECTRON_OZONE_PLATFORM_HINT
    # in modules/home/desktop/wayland-env.nix. Leading backslash skips the alias (zsh).
    curs = "env -u NIXOS_OZONE_WL cursor";
    cursor = "env -u NIXOS_OZONE_WL \\cursor";
    zed = "zeditor";
  };
}
