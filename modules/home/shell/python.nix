# Python / conda environment management via micromamba.
#
# Micromamba ships from nixpkgs as a wrapper over mamba-cpp. Every env, Python
# version, and package lives under $MAMBA_ROOT_PREFIX (default: ~/micromamba) —
# fully mutable in $HOME, NOT in the Nix store.
#
# nixpkgs' micromamba shell hook embeds `.mamba-wrapped` as the executable name,
# so libmamba never defines the `micromamba()` function. We patch the hook: point
# __mamba_exe at the real `mamba` binary and force __exe_name to `micromamba`.
#
# Cheat sheet (works with `micromamba`, `mamba`, or `conda`):
#   conda create -n py312 python=3.12          # new env with a Python version
#   conda activate py312                       # enter env
#   conda install numpy pandas                 # install packages (conda-forge)
#   conda env list                             # list envs
#   conda deactivate                           # leave env
#   conda search 'python>=3.11'                # search channels
{ config, pkgs, ... }:

let
  mambaRoot = "${config.home.homeDirectory}/micromamba";
  mambaExe = "${pkgs.micromamba}/bin/micromamba";
in

{
  home.packages = [ pkgs.micromamba ];

  home.file.".condarc".text = ''
    channels:
      - conda-forge
    channel_priority: strict
    changeps1: false
  '';

  home.sessionVariables = {
    PYTHONDONTWRITEBYTECODE = "1";
    MAMBA_ROOT_PREFIX = mambaRoot;
  };

  programs.zsh.initContent = ''
    export MAMBA_ROOT_PREFIX="${mambaRoot}"
    [ -d "$MAMBA_ROOT_PREFIX" ] || mkdir -p "$MAMBA_ROOT_PREFIX"

    if command -v micromamba >/dev/null 2>&1; then
      __mamba_hook="$(${mambaExe} shell hook --shell zsh 2>/dev/null \
        | sed 's|\.mamba-wrapped|mamba|g' \
        | sed 's|^__exe_name=.*|__exe_name="micromamba"|')"
      eval "$__mamba_hook"
      unset __mamba_hook
      alias conda=micromamba
      alias mamba=micromamba
    fi
  '';
}
