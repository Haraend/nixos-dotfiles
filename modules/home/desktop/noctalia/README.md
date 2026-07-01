# Noctalia Shell Configuration

This module configures the Noctalia Shell (v4 — JSON settings, pinned to v4.7.7 in `flake.nix`).

## Path placeholders

Committed `settings.json` uses `@HOME@` and `@CONFIG@` placeholders. At rebuild, [`default.nix`](default.nix) substitutes them from `config.home.homeDirectory` and `vars.configPath` (set in `lib/vars.nix`).

## Workflow

The configuration is strictly declarative, sourced from `settings.json` in this directory.

### To Update Settings

**Option 1: Edit JSON directly**
1. Edit `modules/home/desktop/noctalia/settings.json` (keep `@HOME@` / `@CONFIG@` placeholders for user-specific paths).
2. Rebuild your system.

**Option 2: Use GUI and Sync**
1. Make changes in the Noctalia Settings GUI.
2. Run the sync script to copy those changes back to this repo:
   ```bash
   cd modules/home/desktop/noctalia
   python3 sync-from-gui.py
   ```
3. Restore `@HOME@` / `@CONFIG@` in synced paths if the GUI wrote absolute paths.
4. Rebuild your system.
