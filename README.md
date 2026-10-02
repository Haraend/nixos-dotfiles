# NixOS Configuration

NixOS + Home Manager flake for a ThinkPad T14 (Intel Gen 1) running the [Niri](https://github.com/YaLTeR/niri) scrollable-tiling compositor. On another machine, remove the thinkpad import in `hosts/nixos/configuration.nix` before the first switch.

- **How-to guide:** [`docs/NIXOS_GUIDE.md`](docs/NIXOS_GUIDE.md) — adding packages/modules, updating inputs, runtimes, displays, troubleshooting.
- **AI agents:** [`AGENTS.md`](AGENTS.md) — conventions, commands, and tooling agents should know.

---

## Fork and customize

1. Clone to `~/nixos-dotfiles`.
2. `cp lib/vars.example.nix lib/vars.nix`. Set `username` to the account you already log in as, and set `configPath` to the absolute clone path (that path is only for the `nrs` / `nrb` aliases). Set `timezone` and `location` together. SSH is key-only: paste a key into `sshPublicKeys`, or leave it empty and use the greeter. No password is stored in this repo. On a first install, run `passwd` as root before you leave the installer. NixOS keeps an existing account's password.
3. `cp hosts/nixos/hardware-configuration.example.nix hosts/nixos/hardware-configuration.nix`, then generate the real file **before** the first switch. The example only exists so the flake evaluates; its disk labels will not boot a machine.

   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
   ```

4. Lid close and the power key suspend until you set `resumeDevice` in `lib/vars.nix` to a swap partition at least as large as RAM (for example `"/dev/disk/by-label/swap"`). After that they use suspend-then-hibernate.
5. Optional: point `wallpaper` in `lib/vars.nix` at a different image. The default is `wallpapers/clouds.jpg`.
6. Build, then switch. Commands use `path:` so Nix includes the gitignored `lib/vars.nix` and `hosts/nixos/hardware-configuration.nix`. The flake output is always `#nixos`. `vars.hostname` is only the network name.

   ```bash
   sudo nixos-rebuild build --flake path:~/nixos-dotfiles#nixos
   nh os switch path:~/nixos-dotfiles#nixos
   ```

`lib/vars.nix` and `hosts/nixos/hardware-configuration.nix` are gitignored. Only the `.example` templates are committed.

---

## Quick reference

```bash
# Rebuild / switch (preferred). path: includes gitignored local files.
nh os build path:~/nixos-dotfiles#nixos
nh os switch path:~/nixos-dotfiles#nixos

# Fallback if nh is unavailable
sudo nixos-rebuild switch --flake path:~/nixos-dotfiles#nixos -L
sudo nixos-rebuild build --flake path:~/nixos-dotfiles#nixos

# After a build-only (not switch), drop the result GC root:
rm -f ~/nixos-dotfiles/result ~/result

# Update one app flake (fast rebuilds)
nix flake update zen-browser

# Deliberate nixpkgs bump (Cursor, Chrome, kernel, Steam, etc.)
nix flake update nixpkgs home-manager stylix nixos-hardware

# Avoid: bare `nix flake update` (bumps every input). `nfu` is disabled.

# Roll back
sudo nixos-rebuild switch --rollback
sudo nixos-rebuild list-generations
```

Garbage-collection and store optimisation run automatically every week
(configured in `hosts/nixos/configuration.nix`). systemd-boot keeps at most 8 generations.
To clean up manually:

```bash
rm -f ~/nixos-dotfiles/result ~/result
nh clean all --keep 5 --keep-since 14d
```

---

## CI

[`.github/workflows/check.yml`](.github/workflows/check.yml) runs static checks on every push/PR. It copies the example templates into the gitignored paths, then runs `nixpkgs-fmt --check .` and `nix flake check path:.` (full config evaluation; only tiny eval-time deps like `base16-schemes` are fetched, the system toplevel is never built). Local equivalent before pushing, after `lib/vars.nix` and `hardware-configuration.nix` exist:

```bash
nix run nixpkgs#nixpkgs-fmt -- --check .
nix flake check path:.
```

---

## What's in the box

### Desktop
- **Compositor:** Niri (scrollable tiling, prefers server-side decorations)
- **Shell / bar / launcher / lock / notifications / clipboard:** [Noctalia](https://github.com/noctalia-dev/noctalia) **v5.2.0** (tag-pinned in `flake.nix`; `noctalia` + TOML). Archived v4 on branch `noctalia-v4-snapshot`. Screen recording via Noctalia plugin + `gpu-screen-recorder`. Alt+Tab / Alt+Shift+Tab are Niri's recent-windows switcher (`next-window` / `previous-window`). Mod+X is the overview.
- **Theming:** Stylix — auto-generates a Base16 scheme from `wallpapers/clouds.jpg`, themes GTK, Qt, cursor, icons, fonts. Catppuccin Mocha-adjacent palette.
- **XWayland:** `xwayland-satellite` (managed by niri 25.08+ itself, no systemd service needed)
- **Portals:** `xdg-desktop-portal-gtk` + `xdg-desktop-portal-gnome` — declared at the NixOS level only (`modules/nixos/desktop/niri.nix`).
- **Login:** `greetd` + `tuigreet` (terminal greeter, remembers last session/user)
- **Idle / lock:** Noctalia idle native actions in `config.toml` (5m lock, 5m30s screen-off, 30m lock-and-suspend); pre-sleep lock via `noctalia msg session lock` in `modules/nixos/hardware/power.nix` (session socket `noctalia-wayland-*.sock`, not launcher dmenu). Lockscreen fingerprint via `fprintd` (password-only greeter). Session menu **Hibernate** locks first (`config.toml`).
- **Screenshots:** Noctalia region/fullscreen (`Super+Shift+S`, Print, Ctrl+Print); Alt+Print uses Niri window capture. Saves to `~/Pictures/Screenshots` + clipboard (`modules/home/desktop/noctalia/config.toml`).
- **Control center logo:** `wallpapers/nixos-logo.png` (Noctalia `[widget.control-center] custom_image`).

### Boot
- **Loader:** systemd-boot, 1 s boot menu timeout.
- **Splash:** Plymouth `spinner` theme + quiet kernel params (`modules/nixos/boot.nix`). ThinkPad firmware logo at power-on is unchanged (UEFI).

### Shell environment
- **Shell:** Zsh with autosuggestions + syntax highlighting, no oh-my-zsh.
- **Prompt:** Starship, Catppuccin colors. Shows: nix-shell badge, directory, git branch, git status (dirty/staged/ahead/behind), git state (rebase/merge progress), conda env name.
- **Terminal:** Foot (default; lightweight Wayland-native) with Alacritty kept installed as fallback. Default-terminal wiring (niri binds, Thunar actions, `$TERMINAL`, `xdg-terminal-exec`, Xfce helpers) lives in one file: `modules/home/terminal/default-terminal.nix`.
- **Multiplexer:** tmux with `Ctrl+A` prefix, vi keys, mouse on, 1-indexed. Omarchy-style prefixless chords: `Alt+Enter` split, `Alt+Shift+Enter` side-by-side, `Alt+Esc` kill pane, `Alt+1..9` windows, `Alt+arrows` focus/session, `Ctrl+Alt(+Shift)+arrows` pane focus/resize; top status bar.
- **File managers:** Yazi (terminal) + Thunar (GUI, with archive plugin + thumbnails). Right-click folder → "Analyze Disk Usage" via Baobab or ncdu (`modules/home/desktop/disk-usage.nix`).
- **CLI replacements:** `eza` (ls), `bat` (cat), `delta` (git diffs), `fd` (find), `ripgrep` (grep), `zoxide` (cd), `fzf`, `lazygit`, `htop`, `btop`, `fastfetch`.
- **Dev tooling:** direnv + nix-direnv, `gh`, `nh` (Nix helper), `awscli2`, `uv` (fast Python package/tool installer), `cloudflared` (Quick Tunnels to share localhost), `ffmpeg` (`modules/home/desktop/utilities.nix`).
- **Editor:** Neovim + LazyVim is the default (`EDITOR=nvim`, alias `n`; config vendored in `modules/home/terminal/nvim/` via Home Manager, mutable state in `~/.local/share/nvim`). Vim stays on the system profile for root/rescue. **Zed** is the primary GUI coding editor (`zed` alias); settings baseline in `modules/home/desktop/zed/settings.json`. Also: VS Code (`programs.vscode` in `modules/home/desktop/editors.nix`), Cursor IDE (`cursor` / `curs`), Cursor Agent CLI (`agent` / `cursor-agent` from nixpkgs `cursor-cli`), and **OpenCode** (`opencode` TUI/CLI from nixpkgs; `modules/home/desktop/opencode.nix`).

### Languages / runtimes
- **Python / conda:** [micromamba](https://mamba.readthedocs.io/en/latest/user_guide/micromamba.html) — envs live under `~/micromamba/envs/…` (fully mutable, outside the Nix store). `conda` and `mamba` are aliased to `micromamba`, and the zsh shell hook provides working `activate` / `deactivate`. See `modules/home/shell/python.nix` for the full cheat sheet.
- **Node.js:** FNM (Fast Node Manager) + `nix-ld` so FNM-installed Node binaries can link at runtime.
- **Java:** JDK 17 as default (`JAVA_HOME` set via home-manager). PrismLauncher uses the stock cached build.
- **Flutter:** Nix-patched SDK from nixpkgs (`pkgs.flutter`; Dart is bundled). Android toolchain is Android Studio’s SDK under `~/Android/Sdk`. USB debugging uses systemd 258 uaccess + `android-tools`. Config: `modules/home/shell/flutter.nix`, `modules/nixos/services/adb.nix`.
- **Android:** Android Studio (manages its own SDK under `~/Android/Sdk`). `ANDROID_HOME` and `ANDROID_SDK_ROOT` are set; cmdline-tools / `adb` / emulator on `PATH`. Emulator uses KVM (user is in the `kvm` group).

### GUI apps
- **Browsers:** Zen (default, via `zen-browser-flake`), Google Chrome, Brave. MIME types all point at Zen.
- **Web apps:** WhatsApp Web and Gemini as Brave `--app` windows (`modules/home/desktop/web-apps.nix`, profile `~/.local/share/brave-webapps`). Super+Shift+W / Super+Shift+G focus-or-spawn (or the Noctalia launcher). Outbound http(s) links open in Zen (Continue dialog suppressed via `modules/nixos/desktop/brave-policy.nix`). First-time login: `brave --user-data-dir="$HOME/.local/share/brave-webapps" --new-window` (close any `--app` windows first). See [`docs/NIXOS_GUIDE.md`](docs/NIXOS_GUIDE.md#brave-web-apps).
- **Media:** OBS Studio, Spotify, `pavucontrol`, VLC (audio/video; Thunar default), `qimgv` (image gallery; Thunar default), Audacity (waveform editing).
- **Graphics:** GIMP (raster), Inkscape (SVG/vector), ImageMagick (`magick` CLI). Viewer stays qimgv; config in `modules/home/desktop/graphics.nix`.
- **Comms:** Vesktop (Discord), KDE Connect (phone pairing).
- **Office:** LibreOffice. Thunar opens Word (`.doc`/`.docx`), spreadsheets, and slides with Writer, Calc, and Impress (`modules/home/desktop/apps.nix`).
- **Notes:** Obsidian.
- **Files:** Thunar, `file-roller` (archives). Folder size at a glance: right-click → Analyze Disk Usage (**Baobab** GUI / **ncdu** TUI).
- **Windows VM:** [dockurr/windows](https://github.com/dockur/windows) under Docker (16 GB RAM / 4 cores / 64 GB disk), connected over RDP with FreeRDP. Drive it with `winvm` (`connect [-k] | start | stop | status | logs`) or the "Windows" launcher entry; VM auto-stops when the RDP window closes. Shared folder `~/Windows`; virtual disk `~/.windows`; setup UI at `http://localhost:8006`. Config: `modules/home/desktop/windows-vm.nix`. First start downloads a ~10 GB Windows image.
- **Databases:** MongoDB Compass, DBeaver (`dbeaver-bin`, wrapped with `GTK_THEME=Adwaita:light` and desktop Exec retargeted so Appearance Light stays consistent under Stylix dark).
- **Hardware / imaging:** Raspberry Pi Imager (`rpi-imager`) for flashing SD cards — launches via setuid `pkexec` + XWayland (`xhost`); do not use bare `sudo`.
- **Passwords:** Bitwarden CLI (`bw`; `bw login` after install).
- **Games:** Steam (niri: `-system-composer` via `programs.steam.package`), PrismLauncher.
- **Display management:** `wdisplays` (GUI arranger, wlroots / Niri), **Kanshi** (persistent profiles in `modules/home/desktop/kanshi.nix`), `wl-mirror` (stand-in for Windows-style "duplicate"), `wlr-randr` (CLI).

### System services
- **Audio:** PipeWire (ALSA, Pulse, 32-bit support, WirePlumber, rtkit).
- **Networking:** NetworkManager + Avahi/mDNS (device discovery via `hostname.local`).
- **Bluetooth:** On, powered on boot. UI provided by Noctalia (no blueman applet).
- **Power:** `power-profiles-daemon` is on so Noctalia's power tab can switch profiles. TLP and `fullcharge` / `chargelimit` are commented out. On a ThinkPad, a boot oneshot calls UPower `EnableChargeThreshold` so the Noctalia charge toggle can adopt an existing EC limit. Logind: lid-close and the power key suspend until `resumeDevice` is set in `lib/vars.nix`; then they use suspend-then-hibernate, and hibernate starts **2h** after suspend (`HibernateDelaySec`). Noctalia idle lock-and-suspend at 30m is separate. `thermald` for Intel thermal management.
- **Graphics:** Intel iHD + VA-API, 32-bit enabled.
- **Firmware:** `fwupd` for Lenovo BIOS / Thunderbolt / device firmware updates.
- **OOM:** `earlyoom` kills runaway processes before hard lockups (Docker + IDEs).
- **Docker:** Daemon + Compose, weekly autoprune, user in `docker` group; not started at boot (`sudo systemctl start docker` when needed).
- **ADB:** `android-tools` (`adb`/`fastboot`); systemd 258 grants USB uaccess automatically (`modules/nixos/services/adb.nix`).
- **SSH:** openssh on port 22, key-only (no password, no root), `sshguard` rate-limits failures.
- **Polkit:** system polkit with setuid `pkexec` wrapper (`enablePkexecWrapper`) + Noctalia native authentication agent.
- **Fingerprint:** `fprintd` + lockscreen-only PAM (`noctalia-lock`); greeter/login/sudo stay password-only (`modules/nixos/services/fprintd.nix`).
- **Gaming:** Steam with Remote Play / Dedicated Server / LAN Game Transfer firewall ports open.
- **Phone pairing:** KDE Connect — `modules/nixos/services/kdeconnect.nix` (`kdeconnectd` autostart, `sshfs`, firewall `1714-1764`, Noctalia `kde-connect` plugin). Remote mouse/keyboard via `hypr-kdeconnect-portal` (RemoteDesktop portal bridge in `modules/nixos/desktop/niri.nix`).
- **GNOME Keyring:** auto-unlocks via PAM when logging in through greetd (so Chrome, SSH agent, Wi-Fi don't re-prompt).
- **Hardware:** Xbox controller support via `xpadneo` kernel module.

---

## Structure

```
nixos-dotfiles/
├── flake.nix                         # Inputs + outputs (one nixosSystem: "nixos")
├── flake.lock                        # Pinned revisions
├── lib/
│   ├── vars.example.nix              # Template: username, timezone, wallpaper, resumeDevice
│   └── vars.nix                      # Your copy (gitignored)
├── hosts/
│   └── nixos/                        # ThinkPad T14 host
│       ├── configuration.nix         # System config (boot, users, nix settings)
│       ├── hardware-configuration.example.nix  # Evaluates; will not boot
│       ├── hardware-configuration.nix          # Generated (gitignored)
│       └── home.nix                  # Home-manager entry: git, EDITOR (nvim)
├── wallpapers/                       # Stylix wallpaper + nixos-logo.png (Noctalia control center)
├── docs/
├── modules/
│   ├── nixos/                        # System-level modules
│   │   ├── default.nix               # Aggregates boot + desktop + hardware + services + stylix
│   │   ├── boot.nix                  # systemd-boot, Plymouth, quiet boot
│   │   ├── stylix.nix                # Theming (wallpaper, colors, fonts, cursor, icons)
│   │   ├── desktop/
│   │   │   ├── default.nix
│   │   │   ├── niri.nix              # Niri system options + XDG portals
│   │   │   ├── greetd.nix            # tuigreet + PAM keyring unlock
│   │   │   ├── steam.nix             # -system-composer + firewall rules
│   │   │   ├── brave-policy.nix      # AutoLaunchProtocolsFromOrigins (webapp-open)
│   │   │   └── thunar.nix            # + tumbler + ffmpegthumbnailer
│   │   ├── hardware/
│   │   │   ├── default.nix
│   │   │   ├── audio.nix             # PipeWire + rtkit
│   │   │   ├── graphics.nix          # Intel + VA-API
│   │   │   └── power.nix             # Bluetooth + power-profiles-daemon (TLP trial off) + zram + upower + logind
│   │   └── services/
│   │       ├── default.nix           # gnome-keyring + service imports
│   │       ├── docker.nix            # Docker + compose + autoprune
│   │       ├── earlyoom.nix          # OOM killer before hard lockup
│   │       ├── fprintd.nix           # fprintd + lockscreen-only PAM
│   │       ├── fwupd.nix             # BIOS / device firmware updates
│   │       ├── kdeconnect.nix        # KDE Connect + sshfs
│   │       ├── adb.nix               # android-tools (systemd 258 USB uaccess)
│   │       ├── networking.nix        # NetworkManager + Avahi
│   │       ├── polkit.nix            # polkit daemon
│   │       └── ssh.nix               # openssh (key-only) + sshguard
│   └── home/                         # Home Manager modules
│       ├── default.nix               # Aggregates desktop + shell + terminal
│       ├── desktop/
│       │   ├── default.nix
│       │   ├── niri.nix              # Niri KDL config + keybinds + helper scripts
│       │   ├── noctalia/             # Noctalia v5 module + config.toml
│       │   ├── browsers.nix          # Zen (default), Chrome, Brave + MIME associations
│       │   ├── web-apps.nix          # Brave --app windows (WhatsApp, Gemini)
│       │   ├── web-apps/             # launcher, xdg-open helper, link extension
│       │   ├── editors.nix           # Cursor IDE/CLI, Zed, micro
│       │   ├── zed/                  # Zed settings baseline (settings.json)
│       │   ├── opencode.nix          # OpenCode TUI/CLI (programs.opencode)
│       │   ├── apps.nix              # Vesktop, Spotify, OBS, Obsidian,
│       │   │                         # MongoDB Compass, wl-mirror, wlr-randr, etc.
│       │   ├── disk-usage.nix         # ncdu + Baobab + Thunar right-click actions
│       │   ├── windows-vm.nix         # dockurr/windows compose + winvm wrapper
│       │   ├── android.nix           # Android Studio + SDK env / PATH
│       │   ├── utilities.nix         # wl-clipboard, brightnessctl, archives
│       │   ├── wayland-env.nix       # Wayland env vars (NIXOS_OZONE_WL etc.)
│       │   └── xwayland.nix          # xwayland-satellite package
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
│       │   ├── flutter.nix           # Nix-patched Flutter SDK (Dart bundled)
│       │   ├── python.nix            # micromamba + conda/mamba aliases + zsh hook
│       │   └── yazi.nix              # Terminal file manager
│       └── terminal/
│           ├── default.nix
│           ├── alacritty.nix         # Kept installed as fallback (not the default)
│           ├── default-terminal.nix  # Which terminal is "the" default + xdg-terminal-exec wiring
│           ├── foot.nix              # Default terminal (trial); themed by Stylix
│           ├── neovim.nix            # Neovim + LazyVim (config in nvim/)
│           ├── nvim/                 # Vendored LazyVim starter (init.lua, lua/…)
│           └── tmux.nix              # Ctrl+A prefix, vi keys, Omarchy-style chords
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
| `noctalia` | Noctalia shell + home module (tag-pinned **v5.2.0**; v4 archived on `noctalia-v4-snapshot`) | no (hits `noctalia.cachix.org`) |

Most inputs follow the root `nixpkgs` so a single lock entry feeds the tree.
**Noctalia does not** — following nixpkgs would miss their Cachix (a second nixpkgs
copy in the store is cheaper than compiling on this laptop). Substituters:
`cache.nixos.org`, `noctalia.cachix.org`, `nix-community.cachix.org`.
The lock file only moves when you run `nix flake update …` (not on every rebuild).

**Branches:** Active config pins Noctalia **v5.2.0**. `noctalia-v4-snapshot` is a frozen rollback reference for v4.7.7 — do not develop there.

---

## Pinned unstable workflow

`nixpkgs` tracks `nixos-unstable`, but **`flake.lock` holds the pin**. Day-to-day:

```bash
# One app from its own flake (Zen, Noctalia, …)
nix flake update zen-browser
nh os build path:~/nixos-dotfiles#nixos
nh os switch path:~/nixos-dotfiles#nixos

# Everything from nixpkgs (Cursor, browsers, Steam, Android Studio, …)
nix flake update nixpkgs home-manager stylix nixos-hardware
nh os build path:~/nixos-dotfiles#nixos   # test first
nh os switch path:~/nixos-dotfiles#nixos
```

Avoid `nix flake update` with no arguments — it bumps every input and causes large,
surprise rebuilds. The `nfu` alias is disabled (prints the preferred commands).
After a nixpkgs bump, Hydra may still be building that rev; if many packages
compile from source, wait a day and rebuild.

Try a newer nixpkgs package without changing the system:

```bash
nix shell nixpkgs/nixos-unstable#code-cursor
```

---

## Language runtimes

- **Python / conda:** micromamba, envs in `~/micromamba/…` (`modules/home/shell/python.nix`). `uv` for fast package/tool installs.
- **Node.js:** fnm + `nix-ld` (`modules/home/shell/fnm.nix`).
- **Java:** JDK 17 default, `JAVA_HOME` set (`modules/home/shell/java.nix`).
- **Flutter:** `pkgs.flutter` (`modules/home/shell/flutter.nix`); Android SDK via Android Studio (`modules/home/desktop/android.nix`); `adb` via `android-tools` (`modules/nixos/services/adb.nix`).

See [`docs/NIXOS_GUIDE.md`](docs/NIXOS_GUIDE.md#language-runtimes) for env workflows and examples.

---

## Displays / monitors

Niri uses the **wlr-output-management** protocol: `wdisplays` (GUI), **Kanshi** for persistent profiles (`modules/home/desktop/kanshi.nix`), `wl-mirror` for duplicate/clone, and `wlr-randr` / `niri msg outputs` on the CLI. `nwg-displays` is not used (Sway/Hyprland-only IPC).

Full walkthrough in [`docs/NIXOS_GUIDE.md`](docs/NIXOS_GUIDE.md#displays--monitors).

---

## KDE Connect

[`modules/nixos/services/kdeconnect.nix`](modules/nixos/services/kdeconnect.nix):

- Installs `kdeconnect-kde` and opens firewall TCP/UDP `1714–1764`.
- `sshfs` for Noctalia kde-connect plugin file browsing.
- `kdeconnectd` runs as a systemd user service bound to `graphical-session.target` (`modules/nixos/services/kdeconnect.nix`).
- mDNS discovery via Avahi (`modules/nixos/services/networking.nix`).
- Noctalia `noctalia/kde-connect` plugin enabled in `config.toml` — add the bar widget in Settings if needed.
- **Remote input (phone mouse/keyboard):** Niri has no native RemoteDesktop portal, so [`pkgs/hypr-kdeconnect-portal.nix`](pkgs/hypr-kdeconnect-portal.nix) is wired as `org.freedesktop.impl.portal.RemoteDesktop` in [`modules/nixos/desktop/niri.nix`](modules/nixos/desktop/niri.nix).

Pair your phone (same WLAN) via `kdeconnect-app` or Noctalia's launcher (`Super+Space`).

```bash
kdeconnect-cli -l    # list paired devices
# After switch, if remote input was already broken this session:
systemctl --user restart xdg-desktop-portal
# Optional pointer self-test:
hypr-kdeconnect-portal --self-test-motion 120 0
```

Then open **Remote Input** / touchpad on the phone for this device.
---

## Electron IDE Wayland note

The `cursor` and `curs` aliases unset `NIXOS_OZONE_WL` before launching **Cursor** from the shell, which silences Chromium-flag CLI warnings from the Nix Electron wrapper. The app launcher still uses the stock `code-cursor` binary (harmless warnings if you only launch from the GUI). Wayland is still requested via `ELECTRON_OZONE_PLATFORM_HINT` in `modules/home/desktop/wayland-env.nix`.

**Cursor Agent CLI** (`cursor-cli` from nixpkgs) is separate from the IDE — use `agent` or `cursor-agent` in the terminal. Authenticate once with `cursor-agent` after install (see [Cursor CLI docs](https://cursor.com/docs/cli/installation)).

**OpenCode** is a terminal AI coding agent (`opencode`). Enable via `programs.opencode` (`modules/home/desktop/opencode.nix`); config and skills stay writable under `~/.config/opencode`. First run: `opencode` then `/connect` (or `opencode auth login`). Skills: `npx skills add … -g -a opencode`. Do not `opencode upgrade` — bump nixpkgs instead. See [`docs/NIXOS_GUIDE.md`](docs/NIXOS_GUIDE.md#opencode).

---

## Module pattern

Every module directory has a `default.nix` that imports the siblings inside it.
The host config just imports the top-level aggregators (`modules/nixos` and `modules/home`),
keeping host files short. To disable a module, remove it from the nearest `default.nix`.

Adding packages, modules, services, hosts, and rollback/debugging steps are all covered in [`docs/NIXOS_GUIDE.md`](docs/NIXOS_GUIDE.md).

---

## Quality-of-life tweaks baked in

- `auto-optimise-store` is **off** (it slows every rebuild). Replaced with a weekly timer.
- Nix garbage collection runs weekly, deletes generations older than 14 days. systemd-boot `configurationLimit` is 8. Do not leave `result` symlinks after `nh os build`.
- `nh` is available as a nicer wrapper around `nixos-rebuild` and `home-manager` (`nh os switch`, `nh clean all`).
- Double-Esc in zsh adds `sudo` to the current line.
- `reload` alias re-sources `~/.zshrc`.

---

## Keeping docs current

When the config changes, update the affected docs in the same commit: this README ("What's in the box" / "Flake inputs"), [`docs/NIXOS_GUIDE.md`](docs/NIXOS_GUIDE.md), and [`AGENTS.md`](AGENTS.md). Agents are instructed to do this automatically.
