# NixOS Configuration

Opinionated NixOS + Home Manager flake for a ThinkPad T14 (Intel Gen 1) running the [Niri](https://github.com/YaLTeR/niri) scrollable-tiling compositor.

- **How-to guide:** [`docs/NIXOS_GUIDE.md`](docs/NIXOS_GUIDE.md) — adding packages/modules, updating inputs, runtimes, displays, troubleshooting.
- **AI agents:** [`AGENTS.md`](AGENTS.md) — conventions, commands, and tooling agents should know.

---

## Fork & customize

1. Fork or clone to `~/nixos-dotfiles`.
2. `cp lib/vars.example.nix lib/vars.nix` — set `username`, `email`, `configPath`, and `sshPublicKeys`.
3. `cp hosts/nixos/hardware-configuration.example.nix hosts/nixos/hardware-configuration.nix`, then on NixOS run `sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix`.
4. *(Optional)* swap `wallpapers/clouds.jpg` for a different Stylix palette.
5. `sudo nixos-rebuild build --flake .#nixos`, then `nh os switch ~/nixos-dotfiles` (or `sudo nixos-rebuild switch --flake .#nixos`).

`lib/vars.nix` and `hosts/nixos/hardware-configuration.nix` are gitignored — only the `.example` templates are committed.

---

## Quick reference

```bash
# Rebuild and switch
sudo nixos-rebuild switch --flake ~/nixos-dotfiles -L
# …or with the nicer wrapper (already installed):
nh os switch ~/nixos-dotfiles

# Update every flake input at once (avoid — prefer targeted updates below)
nix flake update

# Update one app flake (fast rebuilds)
nix flake update zen-browser
nix flake update antigravity-nix

# Deliberate nixpkgs bump (Cursor, Chrome, kernel, Steam, etc.)
nix flake update nixpkgs home-manager stylix
nix flake update nixpkgs
nix flake update stylix

# Build without switching (for testing)
sudo nixos-rebuild build --flake ~/nixos-dotfiles

# Roll back
sudo nixos-rebuild switch --rollback
sudo nixos-rebuild list-generations
```

Garbage-collection and store optimisation run automatically every week
(configured in `hosts/nixos/configuration.nix`). To clean up manually:

```bash
nh clean all --keep 5 --keep-since 14d
```

---

## What's in the box

### Desktop
- **Compositor:** Niri (scrollable tiling, prefers server-side decorations)
- **Shell / bar / launcher / lock / notifications / clipboard:** [Noctalia](https://github.com/noctalia-dev/noctalia-shell) (one shell, many roles — replaces Waybar, Mako, swaylock, Cliphist, fuzzel for most things)
- **App launcher fallback:** Fuzzel
- **Theming:** Stylix — auto-generates a Base16 scheme from `wallpapers/clouds.jpg`, themes GTK, Qt, cursor, icons, fonts. Catppuccin Mocha-adjacent palette.
- **XWayland:** `xwayland-satellite` (managed by niri 25.08+ itself, no systemd service needed)
- **Portals:** `xdg-desktop-portal-gtk` + `xdg-desktop-portal-gnome` — declared at the NixOS level only (the duplicate home-manager services in `modules/home/desktop/portals.nix` are intentionally inert; see that file's header for why).
- **Login:** `greetd` + `tuigreet` (terminal greeter, remembers last session/user)
- **Idle / lock:** `swayidle` spawned by niri, Noctalia handles the lock screen.

### Shell environment
- **Shell:** Zsh with autosuggestions + syntax highlighting, no oh-my-zsh.
- **Prompt:** Starship, Catppuccin colors. Shows: nix-shell badge, directory, git branch, git status (dirty/staged/ahead/behind), git state (rebase/merge progress), conda env name.
- **Terminal:** Alacritty (Wayland-native, GPU-accelerated).
- **Multiplexer:** tmux with `Ctrl+A` prefix, vi keys, mouse on, 1-indexed.
- **File managers:** Yazi (terminal) + Thunar (GUI, with archive plugin + thumbnails).
- **CLI replacements:** `eza` (ls), `bat` (cat), `delta` (git diffs), `fd` (find), `ripgrep` (grep), `zoxide` (cd), `fzf`, `lazygit`, `htop`, `btop`, `fastfetch`.
- **Dev tooling:** direnv + nix-direnv, `gh`, `nh` (Nix helper), `awscli2`, `uv` (fast Python package/tool installer).
- **Editor:** Vim is the default (`EDITOR=vim`, `VISUAL=vim`), configured via home-manager with line numbers, system clipboard, mouse, smart case, etc. GUIs: VS Code, Antigravity 2.0 (base app + IDE + CLI via flake), Cursor and Zed (launched via `cursor` / `curs` / `zed`).

### Languages / runtimes
- **Python / conda:** [micromamba](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html) — envs live under `~/micromamba/envs/…` (fully mutable, outside the Nix store). `conda` and `mamba` are aliased to `micromamba`, and the zsh shell hook provides working `activate` / `deactivate`. See `modules/home/shell/python.nix` for the full cheat sheet.
- **Node.js:** FNM (Fast Node Manager) + `nix-ld` so FNM-installed Node binaries can link at runtime.
- **Java:** JDK 17 as default (`JAVA_HOME` set via home-manager). PrismLauncher uses the stock cached build.
- **Android:** Android Studio (manages its own SDK under `~/Android/Sdk`). `ANDROID_HOME` and `ANDROID_SDK_ROOT` are set; `adb`/`fastboot` available via `android-tools`. Emulator uses KVM (user is in the `kvm` group).

### GUI apps
- **Browsers:** Zen (default, via `zen-browser-flake`), Google Chrome, Brave. MIME types all point at Zen.
- **Media:** OBS Studio, Spotify, `pavucontrol`, `playerctl`, `gthumb` (image browser).
- **Comms:** Vesktop (Discord), KDE Connect (phone pairing).
- **Notes:** Obsidian.
- **Files:** Thunar, `file-roller` (archives).
- **Databases:** MongoDB Compass.
- **Games:** Steam (niri: `-system-composer` via `programs.steam.package`), PrismLauncher.
- **Display management:** `wdisplays` (GUI arranger, wlroots / Niri), **Kanshi** (persistent profiles in `modules/home/desktop/kanshi.nix`), `wl-mirror` (stand-in for Windows-style "duplicate"), `wlr-randr` (CLI).

### System services
- **Audio:** PipeWire (ALSA, Pulse, 32-bit support, WirePlumber, rtkit).
- **Networking:** NetworkManager + Avahi/mDNS (device discovery via `hostname.local`).
- **Bluetooth:** On, powered on boot. UI provided by Noctalia (no blueman applet).
- **Power:** TLP (battery charge thresholds 75–80%). `power-profiles-daemon` disabled to avoid conflicts with TLP. Logind: lid-close → suspend-then-hibernate; hibernate after 30 min idle.
- **Graphics:** Intel iHD + VA-API, 32-bit enabled.
- **Docker:** Daemon + Compose, weekly autoprune, user in `docker` group.
- **SSH:** openssh on port 22, key-only (no password, no root), `sshguard` rate-limits failures.
- **Polkit:** system polkit + `polkit-gnome` agent auto-started for graphical sessions.
- **Gaming:** Steam with Remote Play / Dedicated Server / LAN Game Transfer firewall ports open.
- **Phone pairing:** `programs.kdeconnect.enable = true;` — opens TCP/UDP `1714-1764`.
- **GNOME Keyring:** auto-unlocks via PAM when logging in through greetd (so Chrome, SSH agent, Wi-Fi don't re-prompt).
- **Hardware:** Xbox controller support via `xpadneo` kernel module.

---

## Structure

```
nixos-dotfiles/
├── flake.nix                         # Inputs + outputs (one nixosSystem: "nixos")
├── flake.lock                        # Pinned revisions
├── lib/
│   ├── vars.example.nix              # Template — copy to vars.nix (gitignored)
│   └── vars.nix                      # Local identity (not committed)
├── hosts/
│   └── nixos/                        # ThinkPad T14 host
│       ├── configuration.nix         # System config (boot, users, nix settings)
│       ├── hardware-configuration.example.nix
│       ├── hardware-configuration.nix  # Local, machine-specific (not committed)
│       └── home.nix                  # Home-manager entry: git, vim, EDITOR
├── wallpapers/                       # Stylix reads from here
├── docs/
├── modules/
│   ├── nixos/                        # System-level modules
│   │   ├── default.nix               # Aggregates desktop + hardware + services + stylix
│   │   ├── stylix.nix                # Theming (wallpaper, colors, fonts, cursor, icons)
│   │   ├── desktop/
│   │   │   ├── default.nix
│   │   │   ├── niri.nix              # Niri system options + XDG portals
│   │   │   ├── greetd.nix            # tuigreet + PAM keyring unlock
│   │   │   ├── steam.nix             # -system-composer + firewall rules
│   │   │   └── thunar.nix            # + tumbler + ffmpegthumbnailer
│   │   ├── hardware/
│   │   │   ├── default.nix
│   │   │   ├── audio.nix             # PipeWire + rtkit
│   │   │   ├── graphics.nix          # Intel + VA-API
│   │   │   └── power.nix             # Bluetooth + TLP + upower + logind
│   │   └── services/
│   │       ├── default.nix           # KDE Connect + gnome-keyring
│   │       ├── docker.nix            # Docker + compose + autoprune
│   │       ├── networking.nix        # NetworkManager + Avahi
│   │       ├── polkit.nix            # + polkit-gnome agent
│   │       └── ssh.nix               # openssh (key-only) + sshguard
│   └── home/                         # Home Manager modules
│       ├── default.nix               # Aggregates desktop + shell + terminal
│       ├── desktop/
│       │   ├── default.nix
│       │   ├── niri.nix              # Niri KDL config + keybinds + helper scripts
│       │   ├── noctalia/             # Noctalia module + settings.json template
│       │   ├── browsers.nix          # Zen (default), Chrome, Brave + MIME associations
│       │   ├── editors.nix           # VS Code, Cursor, Zed
│       │   ├── antigravity.nix       # Antigravity 2.0 base + IDE + CLI
│       │   ├── apps.nix              # Vesktop, Spotify, OBS, Obsidian,
│       │   │                         # MongoDB Compass, wl-mirror, wlr-randr, etc.
│       │   ├── android.nix           # Android Studio + env vars
│       │   ├── utilities.nix         # wl-clipboard, cliphist watchers, screenshots,
│       │   │                         # brightnessctl, archives
│       │   ├── wayland-env.nix       # Wayland env vars (NIXOS_OZONE_WL etc.)
│       │   ├── xwayland.nix          # xwayland-satellite package
│       │   └── portals.nix           # INERT — kept as documentation stub, see file
│       ├── shell/
│       │   ├── default.nix
│       │   ├── zsh.nix               # Zsh config, plugins, keybindings
│       │   ├── starship.nix          # Prompt (git_branch, git_status, git_state, conda)
│       │   ├── aliases.nix           # Shell aliases (git, nix, eza, navigation)
│       │   ├── cli-replacements.nix  # eza, bat, delta, fd, ripgrep
│       │   ├── navigation.nix        # zoxide, fzf
│       │   ├── dev-tools.nix         # direnv, lazygit, htop, gh, nh, awscli2, uv
│       │   ├── fnm.nix               # Fast Node Manager
│       │   ├── java.nix              # JDK 17 (default for Android/RN)
│       │   ├── python.nix            # micromamba + conda/mamba aliases + zsh hook
│       │   └── yazi.nix              # Terminal file manager
│       └── terminal/
│           ├── default.nix
│           ├── alacritty.nix         # + TERMINAL env var
│           └── tmux.nix              # Ctrl+A prefix, vi keys
```

---

## Flake inputs

| Input | Purpose | Follows nixpkgs? |
|---|---|---|
| `nixpkgs` | Main package set (`nixos-unstable`, rev pinned in `flake.lock`) | — |
| `nixos-hardware` | ThinkPad T14 Gen 1 module | N/A |
| `home-manager` | User-space config | ✅ |
| `stylix` | Theming | ✅ |
| `zen-browser` | Zen browser package | ✅ |
| `noctalia` | Noctalia shell + home module (pinned to **v4.7.7** on `main`) | ✅ |
| `antigravity-nix` | Antigravity 2.0 base app, IDE, and CLI (not in nixpkgs) | ✅ |

Every input that can follows the root `nixpkgs`, so a single `nixpkgs` lock entry
feeds the whole tree. The lock file pins the revision — it only moves when you run
`nix flake update nixpkgs` (not on every rebuild).

---

## Pinned unstable workflow

`nixpkgs` tracks `nixos-unstable`, but **`flake.lock` holds the pin**. Day-to-day:

```bash
# One app from its own flake (Zen, Noctalia, Antigravity, …)
nix flake update antigravity-nix
sudo nixos-rebuild build --flake ~/nixos-dotfiles
nh os switch ~/nixos-dotfiles

# Everything from nixpkgs (Cursor, VS Code, browsers, Steam, Android Studio, …)
nix flake update nixpkgs home-manager stylix
sudo nixos-rebuild build --flake ~/nixos-dotfiles   # test first
nh os switch ~/nixos-dotfiles
```

Avoid `nix flake update` with no arguments — it bumps every input and causes large,
surprise rebuilds. The `nfu` shell alias does the same thing.

Try a newer nixpkgs package without changing the system:

```bash
nix shell nixpkgs/nixos-unstable#code-cursor
```

---

## Language runtimes

- **Python / conda:** micromamba, envs in `~/micromamba/…` (`modules/home/shell/python.nix`). `uv` for fast package/tool installs.
- **Node.js:** fnm + `nix-ld` (`modules/home/shell/fnm.nix`).
- **Java:** JDK 17 default, `JAVA_HOME` set (`modules/home/shell/java.nix`).

See [`docs/NIXOS_GUIDE.md`](docs/NIXOS_GUIDE.md#language-runtimes) for env workflows and examples.

---

## Displays / monitors

Niri uses the **wlr-output-management** protocol: `wdisplays` (GUI), **Kanshi** for persistent profiles (`modules/home/desktop/kanshi.nix`), `wl-mirror` for duplicate/clone, and `wlr-randr` / `niri msg outputs` on the CLI. `nwg-displays` is not used (Sway/Hyprland-only IPC).

Full walkthrough in [`docs/NIXOS_GUIDE.md`](docs/NIXOS_GUIDE.md#displays--monitors).

---

## KDE Connect

- Enabled system-wide in `modules/nixos/services/default.nix` (`programs.kdeconnect.enable = true;`).
- Opens TCP + UDP ports `1714-1764`.
- mDNS discovery courtesy of Avahi.
- Pair your phone (same WLAN) from the KDE Connect app — search it in fuzzel or Noctalia's launcher.

---

## Electron IDE Wayland note

The `cursor` and `curs` aliases unset `NIXOS_OZONE_WL` before launching **Cursor** from the shell, which silences Chromium-flag CLI warnings from the Nix Electron wrapper. The app launcher still uses the stock `code-cursor` binary (harmless warnings if you only launch from the GUI). Wayland is still requested via `ELECTRON_OZONE_PLATFORM_HINT` in `modules/home/desktop/wayland-env.nix`.

---

## Module pattern

Every module directory has a `default.nix` that imports the siblings inside it.
The host config just imports the top-level aggregators (`modules/nixos` and `modules/home`),
keeping host files short. To disable a module, remove it from the nearest `default.nix`.

Adding packages, modules, services, hosts, and rollback/debugging steps are all covered in [`docs/NIXOS_GUIDE.md`](docs/NIXOS_GUIDE.md).

---

## Quality-of-life tweaks baked in

- `auto-optimise-store` is **off** (it slows every rebuild). Replaced with a weekly timer.
- Nix garbage collection runs weekly, deletes generations older than 14 days.
- `nh` is available as a nicer wrapper around `nixos-rebuild` and `home-manager` (`nh os switch`, `nh clean all`).
- Double-Esc in zsh adds `sudo` to the current line.
- `reload` alias re-sources `~/.zshrc`.
