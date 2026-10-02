# AGENTS.md

Guidance for AI agents working in this repository. Keep it short; read the linked files when you need detail.

## What this repo is

A **NixOS + Home Manager flake** for a ThinkPad T14 (Intel Gen 1) running the **Niri** scrollable-tiling compositor. Shared values live in gitignored [lib/vars.nix](lib/vars.nix), copied from [lib/vars.example.nix](lib/vars.example.nix). The flake output is always `nixos`; `hostname` in vars is only the network name. Rebuilds use `path:` so Nix can see `lib/vars.nix` and `hosts/nixos/hardware-configuration.nix`.

## Commands

Use **`nh`** (Nix helper) for all build, switch, and clean operations — do not reach for raw `nixos-rebuild` or ad-hoc `nix build` unless `nh` cannot do the job.

- Test a change (always do this before switching): `nh os build path:~/nixos-dotfiles#nixos`
- Apply: `nh os switch path:~/nixos-dotfiles#nixos`
- After `nh os build` / `nixos-rebuild build`, **delete `result`** (`rm -f ~/nixos-dotfiles/result ~/result`) — leftover result symlinks are GC roots and pin entire system closures.
- Fallback (only if `nh` is unavailable): `sudo nixos-rebuild build --flake path:~/nixos-dotfiles#nixos` / `sudo nixos-rebuild switch --flake path:~/nixos-dotfiles#nixos`
- **Pinned unstable:** `nixpkgs` uses `nixos-unstable` but the rev is fixed in `flake.lock` until you bump it. Prefer targeted updates over `nix flake update` (no args).
  - App flakes only: `nix flake update <input>` — e.g. `zen-browser`
  - **Noctalia:** pin **v5.2.0** by tag in `flake.nix` (`noctalia` + `config.toml`; GUI overrides in `~/.local/state/noctalia/settings.toml`). Do **not** set `inputs.nixpkgs.follows` on this input — that misses `noctalia.cachix.org`. Bump the tag deliberately and build-test. Archived v4 lives on branch `noctalia-v4-snapshot` (`noctalia-shell` + JSON at v4.7.7).
  - OS + nixpkgs packages (Cursor IDE, cursor-cli, Chrome, Steam, etc.): `nix flake update nixpkgs home-manager stylix nixos-hardware` then build test, then switch. After a nixpkgs bump, Hydra may still be building that rev — if many packages compile from source, wait a day and rebuild.
  - Avoid: `nix flake update` with no arguments. The `nfu` alias is disabled (prints a warning).
- **Binary caches:** `cache.nixos.org`, `noctalia.cachix.org`, `nix-community.cachix.org` (`nix.settings` in `hosts/nixos/configuration.nix`).
- Format Nix files: `nixpkgs-fmt` (the flake's `formatter`)
- **CI** (on push/PR): [.github/workflows/check.yml](.github/workflows/check.yml) copies the example templates, then runs `nixpkgs-fmt --check .` and `nix flake check path:.`. Run the same locally before pushing.
- Clean up: `rm -f ~/nixos-dotfiles/result ~/result` then `nh clean all --keep 5 --keep-since 14d`

### Build workflow

- **Full or slow builds** (flake input bumps, new packages, first build after a big change): give the user the exact `nh` command to run and ask them to report back with the result. Do not start the build yourself and poll/wait on it for minutes.
- **Tiny config-only changes** (small `.nix` / `.toml` edits where the rebuild should finish quickly): the agent may run `nh os build` and wait for it inline.
- When in doubt, prefer asking the user to build — a missed fast build is better than tying up the session on a 10+ minute compile.

Never:
- Use imperative installs (`nix-env -i`) or channels (`nix-channel`).
- Run `nixos-rebuild` without `--flake`.
- Run bare `nix flake update` unless you intend to bump every input at once (`nfu` is a warning-only alias).
- Hand-edit `flake.lock` (use `nix flake update <input>`) or commit `lib/vars.nix` / `hosts/nixos/hardware-configuration.nix` (both gitignored; regenerate hardware, edit vars from the example).

## Where things go

- System-level (services, hardware, security) → `modules/nixos/`
- User-level (programs, dotfiles, shell) → `modules/home/`
- Values used in more than one place → [lib/vars.nix](lib/vars.nix) (from [lib/vars.example.nix](lib/vars.example.nix))
- Host entry points → `hosts/nixos/{configuration,home}.nix`

Every module directory has a `default.nix` that imports its siblings. When you add a `.nix` file, **add it to the nearest `default.nix`** — host configs only import the top-level aggregators (`modules/nixos`, `modules/home`).

Package placement: system utilities all users need → `environment.systemPackages`; user apps/tools → `home.packages` in the relevant `modules/home/**` file.

## Conventions

- 2-space indentation; one concept per file; keep modules focused.
- Use `lib/vars.nix` for shared values instead of hardcoding.
- Comments explain non-obvious intent only — not what the code plainly does.

## Tooling already present (don't reinvent)

- **`nh`** — Nix helper; use for `os build`, `os switch`, and `clean` instead of raw `nixos-rebuild` / `nix build`.
- **direnv + nix-direnv** — per-project envs.
- **micromamba** — Python/conda envs under `~/micromamba` (`conda`/`mamba` aliased to it); see [modules/home/shell/python.nix](modules/home/shell/python.nix).
- **fnm** — Node version manager (works with `nix-ld`).
- **uv** — Python package installer; tools land in `~/.local/bin`.
- **cloudflared** — Quick Tunnels to share localhost (`cloudflared tunnel --url http://localhost:3000`); no Cloudflare account. See [docs/NIXOS_GUIDE.md](docs/NIXOS_GUIDE.md#share-a-local-project).
- **JDK 17**, **Flutter** (`pkgs.flutter`; Dart bundled), **docker**, **awscli2**, **gh**, **lazygit**. Android SDK is Android Studio under `~/Android/Sdk` (`modules/home/desktop/android.nix`); `adb` via `android-tools` (`modules/nixos/services/adb.nix`; systemd 258 USB uaccess).
- **Neovim + LazyVim** — default `$EDITOR`/`VISUAL` (alias `n`). Vendored config in [modules/home/terminal/nvim/](modules/home/terminal/nvim/) is deployed read-only by HM; plugins/lockfile live in `~/.local/share/nvim`. Plain `vim` stays for root/rescue. VS Code is enabled in [modules/home/desktop/editors.nix](modules/home/desktop/editors.nix) alongside Zed and Cursor.
- **Windows VM** — dockurr/windows in Docker, driven by the `winvm` wrapper ([modules/home/desktop/windows-vm.nix](modules/home/desktop/windows-vm.nix)); compose file at `~/.config/windows/docker-compose.yml`, shared dir `~/Windows`.
- **Graphics** — GIMP, Inkscape, ImageMagick (`magick`) in [modules/home/desktop/graphics.nix](modules/home/desktop/graphics.nix). qimgv remains the image viewer (do not steal MIME defaults).
- **Media playback** — VLC owns audio and video MIME defaults for Thunar ([modules/home/desktop/apps.nix](modules/home/desktop/apps.nix)). qimgv remains the image viewer (do not steal image MIME defaults). Audacity stays for waveform editing only.
- **Disk usage** — `ncdu` (TUI) / Baobab (GUI); Thunar right-click actions in [modules/home/desktop/disk-usage.nix](modules/home/desktop/disk-usage.nix).
- **OpenCode** — terminal AI agent via [modules/home/desktop/opencode.nix](modules/home/desktop/opencode.nix) (`pkgs.opencode`; do not `opencode upgrade`). Auth: `/connect`. Skills: `npx skills add … -g -a opencode` (leave HM `settings`/`skills` empty so `~/.config/opencode` stays writable).
- **Web apps** — Brave `--app=URL` via `brave-webapp` ([modules/home/desktop/web-apps.nix](modules/home/desktop/web-apps.nix), isolated profile `~/.local/share/brave-webapps`) plus a `niri-focus-or-spawn` bind in [modules/home/desktop/niri.nix](modules/home/desktop/niri.nix). Do not use Zen (`--app` is Chromium-only). Match the exact Wayland `app_id` (`brave-<url with / as __>-Default`). Outbound http(s) links go to Zen via the unpacked extension in [modules/home/desktop/web-apps/open-in-default-browser/](modules/home/desktop/web-apps/open-in-default-browser/). Continue dialog is suppressed by [modules/nixos/desktop/brave-policy.nix](modules/nixos/desktop/brave-policy.nix) (scoped `webapp-open` origins only). Adding a site: extension `matches` **and** that origin in the policy JSON. Setup / login (full Brave, same profile; close `--app` windows first): `brave --user-data-dir="$HOME/.local/share/brave-webapps" --new-window`. How-to: [docs/NIXOS_GUIDE.md](docs/NIXOS_GUIDE.md#brave-web-apps).

## Keep docs in sync (important)

When you change the repo, update the affected docs in the same change:
- New/removed tool, service, or app → reflect it in [README.md](README.md) ("What's in the box") and, if relevant, [docs/NIXOS_GUIDE.md](docs/NIXOS_GUIDE.md).
- New flake input → update README "Flake inputs" and the update commands here.
- New convention, command, or tool an agent should know → update this file.
