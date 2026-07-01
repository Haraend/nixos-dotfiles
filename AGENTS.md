# AGENTS.md

Guidance for AI agents working in this repository. Keep it short; read the linked files when you need detail.

## What this repo is

An **NixOS + Home Manager flake** for a single host: `nixos`, a ThinkPad T14 (Intel Gen 1) running the **Niri** scrollable-tiling Wayland compositor. Shared values live in local [`lib/vars.nix`](lib/vars.nix) (gitignored; template is [`lib/vars.example.nix`](lib/vars.example.nix)).

## Commands

- Test a change (always do this before switching): `sudo nixos-rebuild build --flake .#nixos`
- Apply: `nh os switch ~/nixos-dotfiles` (preferred) or `sudo nixos-rebuild switch --flake .#nixos`
- **Pinned unstable:** `nixpkgs` uses `nixos-unstable` but the rev is fixed in `flake.lock` until you bump it. Prefer targeted updates over `nix flake update` (no args).
  - App flakes only: `nix flake update <input>` — e.g. `zen-browser`, `antigravity-nix`
  - **Noctalia:** pinned to **v4.7.7** (`noctalia-shell` binary + JSON `settings.json`). Do not `nix flake update noctalia` without reviewing breaking changes.
  - OS + nixpkgs packages (Cursor, Chrome, Steam, etc.): `nix flake update nixpkgs home-manager stylix` then build test, then switch
  - Avoid: `nix flake update` and the `nfu` alias (updates every input at once)
- Format Nix files: `nixpkgs-fmt` (the flake's `formatter`)
- Clean up: `nh clean all --keep 5 --keep-since 14d`

Never:
- Use imperative installs (`nix-env -i`) or channels (`nix-channel`).
- Run `nixos-rebuild` without `--flake`.
- Run bare `nix flake update` (or `nfu`) unless you intend to bump every input at once.
- Hand-edit `flake.lock` (use `nix flake update <input>`) or `hosts/nixos/hardware-configuration.nix` (regenerate only).
- Commit `lib/vars.nix` or `hosts/nixos/hardware-configuration.nix` (gitignored; use `.example` templates).

## Where things go

- System-level (services, hardware, security) → `modules/nixos/`
- User-level (programs, dotfiles, shell) → `modules/home/`
- Values used in more than one place → local `lib/vars.nix` (from `vars.example.nix`)
- Host entry points → `hosts/nixos/{configuration,home}.nix`

Every module directory has a `default.nix` that imports its siblings. When you add a `.nix` file, **add it to the nearest `default.nix`** — host configs only import the top-level aggregators (`modules/nixos`, `modules/home`).

Package placement: system utilities all users need → `environment.systemPackages`; user apps/tools → `home.packages` in the relevant `modules/home/**` file.

## Conventions

- 2-space indentation; one concept per file; keep modules focused.
- Use `lib/vars.nix` for shared values instead of hardcoding.
- Comments explain non-obvious intent only — not what the code plainly does.

## Tooling already present (don't reinvent)

- **`nh`** — Nix helper, the preferred rebuild/clean wrapper.
- **direnv + nix-direnv** — per-project envs.
- **micromamba** — Python/conda envs under `~/micromamba` (`conda`/`mamba` aliased to it); see [modules/home/shell/python.nix](modules/home/shell/python.nix).
- **fnm** — Node version manager (works with `nix-ld`).
- **uv** — Python package installer; tools land in `~/.local/bin`.
- **JDK 17**, **docker**, **awscli2**, **gh**, **lazygit**.
- **Antigravity 2.0** — base app, IDE, and CLI via [modules/home/desktop/antigravity.nix](modules/home/desktop/antigravity.nix) (`antigravity-nix` flake).

## Keep docs in sync (important)

When you change the repo, update the affected docs in the same change:
- New/removed tool, service, or app → reflect it in [README.md](README.md) ("What's in the box") and, if relevant, [docs/NIXOS_GUIDE.md](docs/NIXOS_GUIDE.md).
- New flake input → update README "Flake inputs" and the update commands here.
- New convention, command, or tool an agent should know → update this file.
