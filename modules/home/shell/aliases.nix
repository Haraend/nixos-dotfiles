# Shell aliases
{ config, lib, pkgs, vars, ... }:

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
    n = "nvim"; # LazyVim opens the current directory (Omarchy convention)
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

    # path: includes gitignored vars.nix and hardware-configuration.nix.
    # The flake output is always #nixos; vars.hostname is only the network name.
    nrs = "nh os switch path:${vars.configPath}#nixos";
    nrb = "nh os build path:${vars.configPath}#nixos";
    # Intentionally not `nix flake update`: that bumps every input and causes
    # large surprise rebuilds. Prefer `nix flake update <input>` or
    # `nix flake update nixpkgs home-manager stylix nixos-hardware`.
    nfu = "printf '%s\\n' 'nfu is disabled (it bumped every flake input).' 'Use: nix flake update <input>' ' or: nix flake update nixpkgs home-manager stylix nixos-hardware' >&2; false";

    # Cursor: unset NIXOS_OZONE_WL so the Nix Electron wrapper does not inject
    # Chromium flags Cursor warns about. Wayland still comes from ELECTRON_OZONE_PLATFORM_HINT
    # in modules/home/desktop/wayland-env.nix. Leading backslash skips the alias (zsh).
    curs = "env -u NIXOS_OZONE_WL cursor";
    cursor = "env -u NIXOS_OZONE_WL \\cursor";
    agent = "cursor-agent";
    zed = "zeditor";
  };
}
