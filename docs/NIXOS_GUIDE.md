# Using this configuration

A practical guide to working with this NixOS + Home Manager flake. For the high-level overview of what's installed and why, see the [README](../README.md). For agent conventions, see [AGENTS.md](../AGENTS.md).

> Keep this guide in sync: if you add/remove a tool, service, or workflow, update the relevant section here (and the README).

First switch: follow [Fork and customize](../README.md#fork-and-customize) in the README. Copy `lib/vars.example.nix` and generate `hardware-configuration.nix` before you switch. Rebuilds use `path:~/nixos-dotfiles#nixos` so Nix includes those gitignored files. The flake output stays `#nixos` even if you change `hostname`.

---

## Layout

```
nixos-dotfiles/
├── flake.nix            # Inputs + outputs (one host: "nixos")
├── flake.lock           # Pinned input revisions (never edit by hand)
├── lib/vars.example.nix # Template. Copy to lib/vars.nix (gitignored)
├── hosts/nixos/         # The ThinkPad T14 host
│   ├── configuration.nix        # System: boot, users, nix settings
│   ├── hardware-configuration.example.nix  # Evaluates; regenerate before switch
│   ├── hardware-configuration.nix          # Generated — gitignored, do not commit
│   └── home.nix                 # Home Manager entry: git, EDITOR
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
sudo nixos-rebuild build --flake path:~/nixos-dotfiles#nixos

# Apply it. path: includes gitignored vars.nix and hardware-configuration.nix.
# The flake output is always #nixos; vars.hostname is only the network name.
nh os switch path:~/nixos-dotfiles#nixos
sudo nixos-rebuild switch --flake path:~/nixos-dotfiles#nixos

# Aliases defined in modules/home/shell/aliases.nix
nrs   # = nh os switch path:$configPath#nixos
nrb   # = nh os build  path:$configPath#nixos
# nfu is disabled (used to bump every flake input)
```

After a build-only (`nh os build` / `nixos-rebuild build`), delete the `result` symlink so it is not a GC root:

```bash
rm -f ~/nixos-dotfiles/result ~/result
```

Garbage collection and store optimisation run on a weekly timer. systemd-boot keeps at most 8 generations. To clean manually:

```bash
rm -f ~/nixos-dotfiles/result ~/result
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
3. `sudo nixos-rebuild build --flake path:~/nixos-dotfiles#nixos` to verify.

### Brave web apps

Site-as-app windows live in [`modules/home/desktop/web-apps.nix`](../modules/home/desktop/web-apps.nix) (launcher `.desktop`) plus a `niri-focus-or-spawn` bind in [`modules/home/desktop/niri.nix`](../modules/home/desktop/niri.nix). Use Brave — Zen has no `--app`. Launch via `brave-webapp` (isolated profile `~/.local/share/brave-webapps`) so unpacked `--load-extension` is not swallowed by an already-running Brave.

Current binds: Super+Shift+G Gemini, Super+Shift+W WhatsApp. Both also appear in the Noctalia launcher (`Super+Space`).

**First-time login / setup** — `brave-webapp` always opens `--app` (no address bar). To sign into Gemini or scan the WhatsApp QR, open the same profile as a normal Brave window (omit `--app` and `--load-extension`). Close any existing WhatsApp/Gemini `--app` windows first, or this attaches to that process:

```bash
brave --user-data-dir="$HOME/.local/share/brave-webapps" --new-window
```

**Outbound links** go to Zen through the unpacked helper in [`modules/home/desktop/web-apps/open-in-default-browser/`](../modules/home/desktop/web-apps/open-in-default-browser/) and the `webapp-open` scheme (`xdg-open`). The helper fires that scheme **from the WhatsApp/Gemini page** (same click) so Brave’s scoped policy in [`modules/nixos/desktop/brave-policy.nix`](../modules/nixos/desktop/brave-policy.nix) can auto-allow it. You may see a brief flash, then Zen — no Cancel/Continue. After switch, quit WhatsApp/Gemini so the extension reloads; confirm the policy at `brave://policy`.

**Adding another site:** one `xdg.desktopEntries` row in `web-apps.nix`, URLs in [`web-apps/launch.nix`](../modules/home/desktop/web-apps/launch.nix), the site origin in the Brave policy JSON, extension `matches` in `open-in-default-browser/manifest.json`, and a `niri-focus-or-spawn` bind that matches Brave’s exact Wayland `app_id` (`brave-<url with / as __>-Default`, not `brave-browser`). Confirm after first launch:

```bash
niri msg --json windows | jq '.[] | {app_id, title}'
```

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
| One app flake (Zen, Noctalia) | `nix flake update <input>` |
| nixpkgs apps (Cursor IDE, cursor-cli, Chrome, Steam, …) | `nix flake update nixpkgs home-manager stylix nixos-hardware` |
| Everything at once (avoid) | `nix flake update` (`nfu` is disabled) |

Always `nh os build path:~/nixos-dotfiles#nixos` (or `sudo nixos-rebuild build --flake path:~/nixos-dotfiles#nixos`) before switching after a nixpkgs bump. Then `rm -f result` so the build is not pinned as a GC root.

Binary caches: `cache.nixos.org`, `noctalia.cachix.org`, `nix-community.cachix.org` (`nix.settings` in `hosts/nixos/configuration.nix`). Noctalia does **not** follow root nixpkgs so those binaries match Cachix. After a nixpkgs bump, Hydra may still be building that rev — if lots of packages compile from source, wait a day and rebuild.

```bash
nix flake update zen-browser         # fast — one flake input
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
- **Java** — JDK 17 default (`JAVA_HOME` set); required by React Native / Android / Flutter. Config: `modules/home/shell/java.nix`.
- **Flutter** — Nix-patched SDK (`pkgs.flutter`; Dart is bundled). Android builds use Android Studio’s SDK at `~/Android/Sdk` (`ANDROID_HOME`). Config: `modules/home/shell/flutter.nix`, `modules/home/desktop/android.nix`. USB devices: systemd 258 uaccess + `android-tools` (`modules/nixos/services/adb.nix`).

  After install / SDK Manager (Command-line Tools latest + an AVD or a USB phone):

  ```bash
  flutter doctor
  flutter doctor --android-licenses
  flutter create ~/tmp/flutter_hello && cd ~/tmp/flutter_hello && flutter run
  ```

  Chrome / Linux desktop / VS Code warnings from `flutter doctor` are expected; this host targets Android only.

---

## Editors

**Neovim** (LazyVim distribution) is the default for `$EDITOR`, `$VISUAL`, and `git commit`. The vendored config lives at `modules/home/terminal/nvim/` (deployed read-only via Home Manager); lazy.nvim keeps plugins + lockfile mutable under `~/.local/share/nvim`. Launch with `nvim` or `n` (opens the current directory). First start bootstraps plugins automatically. Config module: `modules/home/terminal/neovim.nix`.

**Vim** remains installed (system profile + `programs.vim`) for root/rescue shells where the LazyVim stack is unavailable.

**Zed** is the primary GUI coding editor — launch with `zed` (alias for `zeditor`). Declarative settings baseline: `modules/home/desktop/zed/settings.json` (copied to `~/.config/zed/settings.json` on first install; GUI edits persist across rebuilds).

**Cursor IDE** (`code-cursor`) and **Cursor Agent CLI** (`cursor-cli` → `cursor-agent`, aliased as `agent`) are also installed. Config: `modules/home/desktop/editors.nix`. Shell aliases `cursor` / `curs` unset `NIXOS_OZONE_WL` for the IDE (see README Electron note). Authenticate the agent CLI once after install — see [Cursor CLI docs](https://cursor.com/docs/cli/installation).

---

## OpenCode

[OpenCode](https://opencode.ai/docs/) is a terminal AI coding agent (`pkgs.opencode` via Home Manager `programs.opencode`). Config: [`modules/home/desktop/opencode.nix`](../modules/home/desktop/opencode.nix).

Settings, TUI prefs, and skills are **not** locked in Nix so `~/.config/opencode` stays writable. Auth is `~/.local/share/opencode/auth.json`.

```bash
cd /path/to/project
opencode                 # TUI
# /connect               # pick a provider (OpenCode Zen: https://opencode.ai/auth)
# /init                  # write AGENTS.md for this repo
# Tab                    # Plan (read-only) vs Build
opencode run "explain this"
opencode --continue      # resume last session
```

Do **not** run `opencode upgrade` — the Nix wrap sets `OPENCODE_DISABLE_AUTOUPDATE`. Newer version: `nix flake update nixpkgs home-manager stylix nixos-hardware` then build/switch.

### Skills

Skills are folders with `SKILL.md` (`name` + `description` frontmatter). Loaded at OpenCode start (quit and reopen after installing).

| Where | Path |
|---|---|
| Global | `~/.config/opencode/skills/<name>/SKILL.md` |
| Project | `.opencode/skills/<name>/SKILL.md` |
| Also scanned | `.claude/skills/`, `.agents/skills/` |

fnm provides `npx`:

```bash
npx skills add vercel-labs/agent-skills -l
npx skills add vercel-labs/agent-skills --skill frontend-design -g -a opencode -y
```

Do not set `programs.opencode.skills` in Nix unless you want a store-managed skills dir (that blocks `npx skills add -g`). Docs: [opencode.ai/docs/skills](https://opencode.ai/docs/skills/).

---

## Share a local project

[`cloudflared`](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/do-more-with-tunnels/trycloudflare/) is on `PATH` via Home Manager ([`modules/home/shell/dev-tools.nix`](../modules/home/shell/dev-tools.nix)). Quick Tunnels need **no Cloudflare account**. Start your app, then:

```bash
cloudflared tunnel --url http://localhost:3000
```

The CLI prints a `https://….trycloudflare.com` URL. Share that; Ctrl+C stops the tunnel and the URL dies. No inbound firewall ports — only outbound HTTPS to Cloudflare.

Named / persistent tunnels (custom hostname, stay up without the CLI in a terminal) need a Cloudflare account and are out of scope here.

---

## Boot / Plymouth

Plymouth + quiet boot live in [`modules/nixos/boot.nix`](../modules/nixos/boot.nix):

- **Theme:** built-in `spinner` (simple dots; avoid `fade-in` — it adds shimmering stars). Swap for `bgrt`, `text`, or an `adi1090x-plymouth-themes` theme like `rings` in `boot.nix`.
- **Intel laptop:** if Plymouth fails on boot, try adding `boot.plymouth.use-simpledrm` when your nixpkgs exposes it, or switch theme in `boot.nix`.
- **Boot menu:** `boot.loader.timeout = 1` — systemd-boot shows for 1 s each boot (interrupt with a key to stay longer).
- **ThinkPad OEM splash** at power-on is firmware; NixOS cannot remove it.

After reboot, boot should be mostly graphical. Press **Escape** during Plymouth to toggle text mode. Logs: `journalctl -b`.

**Pick a different generation:**

- **From a running system (easiest):** `sudo systemctl reboot --boot-loader-menu=30` — shows systemd-boot for 30 s on the *next* reboot only; pick an older NixOS entry.
- **At cold boot:** tap **Space** (or hold any key) right after the ThinkPad splash, before Plymouth finishes — systemd-boot should appear.
- **List generations from the shell:** `sudo nix-env -p /nix/var/nix/profiles/system --list-generations`

To change the countdown, edit `boot.loader.timeout` in `boot.nix`.

**Rollback:** `boot.plymouth.enable = false` and remove `"splash"` from `boot.kernelParams`.

**Recovery:** at the boot menu, edit the kernel line and add `plymouth.enable=0` to boot without Plymouth once.

**Boot speed** (this host): `systemd.services."NetworkManager-wait-online".enable = false` in [`networking.nix`](../modules/nixos/services/networking.nix) avoids blocking on Wi-Fi at boot; `virtualisation.docker.enableOnBoot = false` in [`docker.nix`](../modules/nixos/services/docker.nix) keeps Docker off the critical path. Measure with `systemd-analyze` / `systemd-analyze blame`.

---

## Login / greeter

[greetd](https://github.com/kennylevinsen/greetd) + [tuigreet](https://github.com/Apognu/tuigreet) (`modules/nixos/desktop/greetd.nix`):

```nix
command = lib.concatStringsSep " " [
  (lib.getExe pkgs.tuigreet)
  "--time"
  "--remember"
  "--remember-session"
  "--sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
  "--cmd ${config.programs.niri.package}/bin/niri-session"
];
```

`--remember` restores the last username. `--remember-session` restores the last picked session when that `.desktop` still exists. `--sessions` points at the NixOS-generated Wayland session dir (not `/usr/share/wayland-sessions`). `--cmd` is the fallback so login still starts `niri-session` after a store GC invalidates the remembered path.

Greeter auth is **password only** — fingerprint is disabled on `greetd` PAM even when `fprintd` is enabled (see Fingerprint below). Lock screen fingerprint still works via Noctalia (`noctalia-lock` PAM service).

---

## Screenshots

Noctalia handles region and fullscreen captures (`modules/home/desktop/noctalia/config.toml` → `[shell.screenshot]`). Keybinds in `modules/home/desktop/niri.nix`:

| Key | Action |
|-----|--------|
| Super+Shift+S | Region (`noctalia msg screenshot-region`) |
| Print | Region |
| Ctrl+Print | Full screen (`noctalia msg screenshot-fullscreen`) |
| Alt+Print | Window (Niri `screenshot-window` — Noctalia has no window mode) |

Files land in `~/Pictures/Screenshots` and are copied to the clipboard when `copy_to_clipboard = true`.

Alt+Tab and Alt+Shift+Tab are Niri's recent-windows switcher (next window / previous window). Letting go of Alt focuses the highlighted window. Mod+X toggles the overview.

---

## Fingerprint (lockscreen only)

[`modules/nixos/services/fprintd.nix`](../modules/nixos/services/fprintd.nix) enables `fprintd` and a dedicated PAM service `noctalia-lock` (fingerprint + password). Greeter, TTY `login`, `sudo`, and `su` explicitly disable fingerprint.

Noctalia reads `NOCTALIA_PAM_SERVICE=noctalia-lock` from [`wayland-env.nix`](../modules/home/desktop/wayland-env.nix).

**One-time enrollment** (after rebuild):

```bash
fprintd-enroll -f right-index-finger   # run again per finger, e.g. -f left-thumb
fprintd-list $USER
```

Lock with Super+Shift+L and verify fingerprint unlock; log out and confirm the greeter does **not** prompt for a fingerprint.

Optional UX toggles (if your Noctalia build supports them): Settings → Security → Lock Screen → auto-start auth / allow password with fprintd.

---

## Hibernate / power menu

Hibernate stays off until `resumeDevice` in `lib/vars.nix` points at a swap partition at least as large as RAM. Until then the lid and power key suspend. `boot.resumeDevice` is set from that variable in [`power.nix`](../modules/nixos/hardware/power.nix).

- **Power profiles:** `power-profiles-daemon` is enabled so Noctalia's power tab can switch profiles. TLP and `fullcharge` / `chargelimit` are commented out. On a ThinkPad, a boot oneshot calls UPower `EnableChargeThreshold` so an existing EC charge limit can become the Noctalia toggle. Turning it off charges to 100%. Uncomment TLP in [`power.nix`](../modules/nixos/hardware/power.nix) and [`battery.nix`](../modules/home/shell/battery.nix) to go back.
- **Session menu:** Noctalia's **Hibernate** entry locks via `noctalia msg session lock`, waits 1 s, then `systemctl hibernate` (`[[shell.session.actions]]` in [`config.toml`](../modules/home/desktop/noctalia/config.toml)). It needs `resumeDevice`.
- **Idle / lid / systemctl:** with `resumeDevice` set, logind uses `suspend-then-hibernate`; otherwise it suspends. Noctalia idle behaviors use native `action = "lock"` / `"screen_off"` / `"lock_and_suspend"` in [`config.toml`](../modules/home/desktop/noctalia/config.toml). `powerManagement.powerDownCommands` locks via `noctalia msg session lock` before every suspend/hibernate (`modules/nixos/hardware/power.nix`), targeting the session socket `noctalia-wayland-*.sock` (not `noctalia-dmenu-*.sock`). `loginctl lock-sessions` is not used — Noctalia's logind Lock-signal listener is inactive on this build.
- **Why pre-sleep lock:** hibernation restores RAM as-is; locking before sleep means you wake locked. `resumeCommands` only restarts `fprintd` for a fresh fingerprint PAM session.

Test once after a rebuild:

```bash
systemctl hibernate   # or use the Noctalia session menu
# wake machine; confirm session restored
```

---

## Firmware updates (fwupd)

[`modules/nixos/services/fwupd.nix`](../modules/nixos/services/fwupd.nix) enables `fwupd` for Lenovo BIOS, Thunderbolt, and device firmware.

```bash
fwupdmgr get-devices          # list updatable hardware
fwupdmgr refresh              # fetch metadata
fwupdmgr get-updates          # show available updates
sudo fwupdmgr update          # apply when ready
```

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
sudo nixos-rebuild switch --flake path:~/nixos-dotfiles#nixos -L --show-trace  # verbose failing build
nix why-depends /run/current-system /nix/store/<hash>-<name>
```

---

## Troubleshooting

- **Missing package**: confirm the name with `nix search nixpkgs <name>`.
- **Wrong option path**: check [search.nixos.org/options](https://search.nixos.org/options) and the [Home Manager options](https://nix-community.github.io/home-manager/options.html).
- **Changes not applying**: you ran `build`, not `switch`.
- **Many packages compiling from source after a nixpkgs bump**: Hydra may not have cached that `nixos-unstable` rev yet. Wait a day and rebuild. Noctalia should download from `noctalia.cachix.org` unless `inputs.nixpkgs.follows` was re-added.
- **Nix store still huge after weekly GC**: leftover `result` symlinks (and `/tmp/nh-os*/result`) pin old closures. `rm -f ~/nixos-dotfiles/result ~/result` then `nh clean all --keep 5 --keep-since 14d`.
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
