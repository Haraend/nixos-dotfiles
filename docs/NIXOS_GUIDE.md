# Using this configuration

A practical guide to working with this NixOS + Home Manager flake. For the high-level overview of what's installed and why, see the [README](../README.md). For agent conventions, see [AGENTS.md](../AGENTS.md).

> Keep this guide in sync: if you add/remove a tool, service, or workflow, update the relevant section here (and the README).

---

## First-time setup

See the [README fork & customize](../README.md#fork--customize) section: copy `lib/vars.example.nix` → `lib/vars.nix`, set up `hardware-configuration.nix`, then build and switch.

---

## Layout

```
nixos-dotfiles/
├── flake.nix            # Inputs + outputs (one host: "nixos")
├── flake.lock           # Pinned input revisions (never edit by hand)
├── lib/
│   ├── vars.example.nix # Template — copy to vars.nix (gitignored)
│   └── vars.nix         # Local identity (not committed)
├── hosts/nixos/         # The ThinkPad T14 host
│   ├── configuration.nix        # System: boot, users, nix settings
│   ├── hardware-configuration.example.nix
│   ├── hardware-configuration.nix  # Generated locally — not committed
│   └── home.nix                 # Home Manager entry: git, vim, EDITOR
├── modules/
│   ├── nixos/           # System modules: desktop, hardware, services, stylix
│   └── home/            # User modules: desktop, shell, terminal
└── wallpapers/          # Stylix reads the base16 source image from here
```

Each module directory has a `default.nix` that imports its siblings. Host files only import the aggregators `modules/nixos` and `modules/home`.

| File | Edit frequency |
|------|----------------|
| `modules/**/*.nix` | Most edits happen here |
| `hosts/nixos/configuration.nix` | Occasionally (system-wide settings) |
| `lib/vars.nix` | When adding a host or changing identity |
| `flake.nix` | When adding/removing a flake input |
| `flake.lock`, `hardware-configuration.nix` | Never by hand |

---

## Daily commands

```bash
# Test that the config builds (do this before switching)
sudo nixos-rebuild build --flake .#nixos

# Apply it
nh os switch ~/nixos-dotfiles          # preferred wrapper
sudo nixos-rebuild switch --flake .#nixos

# Aliases defined in modules/home/shell/aliases.nix
nrs   # = sudo nixos-rebuild switch --flake .#nixos
nrb   # = sudo nixos-rebuild build  --flake .#nixos
nfu   # = nix flake update (bumps ALL inputs — prefer targeted updates below)
```

Garbage collection and store optimisation run on a weekly timer. To clean manually:

```bash
nh clean all --keep 5 --keep-since 14d
```

---

## Adding things

### A package

- All users need it (CLI utility): add to `environment.systemPackages` in `hosts/nixos/configuration.nix`.
- Only your user (apps, dev tools): add to `home.packages` in the relevant `modules/home/**` file (e.g. GUI apps in `modules/home/desktop/apps.nix`, shell tools in `modules/home/shell/`).

Prefer a Home Manager program module over a raw package when one exists — it gives type-checked config:

```nix
programs.starship = {
  enable = true;
  settings = { /* ... */ };
};
```

### A new module

1. Create the `.nix` file under the right category (`modules/nixos/...` or `modules/home/...`).
2. Add it to that directory's `default.nix` `imports` list.
3. `sudo nixos-rebuild build --flake .#nixos` to verify.

### A service

System services go in `modules/nixos/services/` and remember to add any required user groups, e.g.:

```nix
virtualisation.docker.enable = true;
users.users.${vars.username}.extraGroups = [ "docker" ];
```

---

## Updating inputs

**Pinned unstable:** `flake.nix` points at `nixos-unstable`, but the real pin is `flake.lock`.
Rebuilds stay fast until you deliberately move an input.

| What you want | Command |
|---|---|
| One app flake (Zen, Noctalia, Antigravity) | `nix flake update <input>` |
| nixpkgs apps (Cursor, Chrome, Steam, …) | `nix flake update nixpkgs home-manager stylix` |
| Everything at once (avoid) | `nix flake update` |

Always `sudo nixos-rebuild build --flake .#nixos` before switching after a nixpkgs bump.

```bash
nix flake update antigravity-nix    # fast — one flake input
nix flake update nixpkgs            # heavy — all nixpkgs-sourced packages

# Try a newer package without touching flake.lock:
nix shell nixpkgs/nixos-unstable#code-cursor
```

---

## Language runtimes

- **Python / conda** — [micromamba](https://mamba.readthedocs.io). Envs live in `~/micromamba/envs/...` (mutable, outside the Nix store). `conda`/`mamba` are aliased to `micromamba`; `activate`/`deactivate` work via the zsh hook. Config: `modules/home/shell/python.nix`.

  ```bash
  conda create -n py312 python=3.12 -c conda-forge
  conda activate py312
  conda install numpy pandas
  ```

- **uv** — fast Python package/tool installer; `uv tool install` puts binaries in `~/.local/bin` (kept on `PATH`). Config: `modules/home/shell/dev-tools.nix`.
- **Node.js** — [fnm](https://github.com/Schniz/fnm) + `nix-ld` so fnm-installed binaries link at runtime. Config: `modules/home/shell/fnm.nix`.
- **Java** — JDK 17 default (`JAVA_HOME` set); required by React Native / Android. Config: `modules/home/shell/java.nix`.

---

## Displays / monitors

Niri uses the **wlr-output-management** protocol.

- **`wdisplays`** — GUI to drag outputs, set scale/mode/rotation (ad-hoc, runtime-only).
- **Kanshi** — persistent per-layout profiles in `modules/home/desktop/kanshi.nix`. A profile matches when its number of `profile.outputs` equals the connected heads. Arrange in `wdisplays`, read values from `niri msg outputs` / `wlr-randr`, transcribe into a profile, then `killall -HUP kanshi`.
- **Mirror/duplicate** (Niri has no native clone): `wl-mirror`, fullscreened on the external output.
- `nwg-displays` is **not** used — it targets Sway/Hyprland IPC, not Niri.

---

## Rollback & debugging

```bash
sudo nixos-rebuild list-generations
sudo nixos-rebuild switch --rollback                       # instant rollback
sudo nixos-rebuild switch --flake .#nixos -L --show-trace  # verbose failing build
nix why-depends /run/current-system /nix/store/<hash>-<name>
```

---

## Troubleshooting

- **Missing package**: confirm the name with `nix search nixpkgs <name>`.
- **Wrong option path**: check [search.nixos.org/options](https://search.nixos.org/options) and the [Home Manager options](https://nix-community.github.io/home-manager/options.html).
- **Changes not applying**: you ran `build`, not `switch`.
- **Home Manager activation fails on Stylix/Kvantum** (`mkdir: File exists`, `ln: No such file or directory`): a symlink under `~` points at a store path removed by GC. This config uses `home-manager.backupCommand` to clear dead symlinks and back up real files before relinking — just run `nh os switch` again; only remove paths manually if it still fails.

---

## Adding a host

1. Create `hosts/<hostname>/` and copy `configuration.nix` + `home.nix` from `hosts/nixos/`.
2. Generate `hardware-configuration.nix` with `nixos-generate-config --root /`.
3. Add the host under `nixosConfigurations` in `flake.nix`.
4. Update `lib/vars.nix` if the user/hostname differ.

---

## References

- [NixOS options](https://search.nixos.org/options) · [Packages](https://search.nixos.org/packages)
- [Home Manager options](https://nix-community.github.io/home-manager/options.html) · [manual](https://nix-community.github.io/home-manager/)
- [NixOS Wiki](https://wiki.nixos.org/) · [Discourse](https://discourse.nixos.org/)
