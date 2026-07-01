# Home-Manager audio rules (PipeWire-Pulse drop-in).
# Counterpart to the system-level modules/nixos/hardware/audio.nix, which
# enables PipeWire + WirePlumber. This file only ships user-scope tweaks.
#
# Current rule: stop Electron-based voice apps from lowering the mic level.
#
# Root cause: Electron apps (Vesktop, Discord, Slack, Element, etc.) run
# WebRTC's audio service in a utility subprocess that always reports its
# `application.process.binary` as `electron`. WebRTC's AGC drives the
# hardware-backed PipeWire source volume down even when the app's in-UI
# "Automatic Gain Control" toggle is off (Vencord/Vesktop#161 — closed
# without an upstream fix). Symptom in `wpctl status`: capture node drifts
# to e.g. 0.30 during calls, with a "Chromium input" client owned by
# /nix/store/...-electron-unwrapped-*/libexec/electron/electron.
#
# Surgical fix: pipewire-pulse `block-source-volume` quirk on every
# `electron` client. It blocks ONLY source-volume mutations; capture
# itself, device selection, and sink (output) volume keep working.
# Other clients (Noctalia / Quickshell, pavucontrol, wpctl, etc.) are
# unaffected — they are not Electron and do not match.
#
# Note: this does not cover voice in the Chrome/Chromium browser itself
# (binaries `chrome` / `chromium`). Add them here if a browser tab ever
# starts doing the same thing.
#
# Reload after switching: `systemctl --user restart pipewire-pulse`.
{ ... }:

{
  xdg.configFile."pipewire/pipewire-pulse.conf.d/51-block-source-volume.conf".text = ''
    pulse.rules = [
      {
        matches = [
          { application.process.binary = "electron" }
        ]
        actions = {
          quirks = [ block-source-volume ]
        }
      }
    ]
  '';
}
