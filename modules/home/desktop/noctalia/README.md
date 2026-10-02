# Noctalia Shell Configuration (v5.2.0)

Noctalia **v5.2.0** (tag-pinned in `flake.nix`) uses TOML config with a declarative baseline plus GUI-managed overrides. Bump the pin deliberately and build-test. Do not set `inputs.nixpkgs.follows` on the noctalia input: that misses `noctalia.cachix.org`.

## Config layers

| Layer | Path | Managed by |
|---|---|---|
| Declarative baseline | `config.toml` in this directory, with placeholders filled at build time | Git + rebuild |
| GUI overrides | `~/.local/state/noctalia/settings.toml` | Noctalia Settings app |

GUI overrides win on merge and survive rebuilds. They stay on the machine and are not part of this repo.

`config.toml` contains `@WALLPAPER@`, `@WALLPAPER_DIR@`, `@LOGO@`, `@LOCATION@`, and `@SUSPEND_CMD@`. [`default.nix`](default.nix) fills those from `vars.wallpaper`, `wallpapers/nixos-logo.png`, `vars.location`, and `vars.resumeDevice`.

## Update settings

1. Edit `modules/home/desktop/noctalia/config.toml` or the matching fields in `lib/vars.nix`.
2. Rebuild: `nh os switch path:~/nixos-dotfiles#nixos`.

**Reset GUI overrides:** delete `~/.local/state/noctalia/settings.toml` and restart noctalia.
