{ lib, pkgs, inputs, vars, config, ... }:

let
  zenBrowser = inputs.zen-browser.packages."${pkgs.stdenv.hostPlatform.system}".beta;
  zenAppIdRegex = "^zen(-beta)?$";
  # IDE is "cursor"; Wayland sometimes uses cursor-url-handler. Agents View is the same app_id.
  cursorAppIdRegex = "(?i)^cursor([-].*)?$";
  # Fallback if app_id is empty: Agents View title vs classic IDE suffix.
  cursorTitleRegex = "(?i)(^Cursor Agents$| - Cursor$)";
  # Electron 41+ reports md.Obsidian or md.obsidian.Obsidian (or electron).
  # [.] not \. — KDL quoted strings reject \. as an escape.
  obsidianAppIdRegex = "(?i)^(obsidian|md[.]obsidian([.].*)?|electron)$";
  obsidianTitleRegex = "(?i)obsidian";
  # Brave --app: app_id is brave-<url with / as __>-Default (not brave-browser).
  geminiAppId = "brave-gemini.google.com__app-Default";
  whatsappAppId = "brave-web.whatsapp.com__-Default";
  inherit (import ./web-apps/launch.nix { inherit lib pkgs config; })
    braveWebapp
    geminiUrl
    whatsappUrl
    ;
  zenCommand = lib.getExe zenBrowser;
  noctaliaCommand = [ "noctalia" ];
  noctaliaSpawnSh = command: "spawn-sh \"noctalia msg ${command}\"";
  focusOrSpawn = pkgs.writeShellApplication {
    name = "niri-focus-or-spawn";
    runtimeInputs = with pkgs; [
      jq
      niri
    ];
    text = ''
      set -eu

      app_id=""
      app_id_regex=""
      title=""
      title_regex=""
      match_any=0
      usage="Usage: niri-focus-or-spawn [--any] [--app-id VALUE] [--app-id-regex REGEX] [--title VALUE] [--title-regex REGEX] -- <command> [args...]"

      while [ "$#" -gt 0 ]; do
        case "$1" in
          --app-id)
            app_id="$2"
            shift 2
            ;;
          --app-id-regex)
            app_id_regex="$2"
            shift 2
            ;;
          --title)
            title="$2"
            shift 2
            ;;
          --title-regex)
            title_regex="$2"
            shift 2
            ;;
          --any)
            match_any=1
            shift
            ;;
          --)
            shift
            break
            ;;
          *)
            echo "$usage" >&2
            exit 1
            ;;
        esac
      done

      if [ -z "$app_id$app_id_regex$title$title_regex" ] || [ "$#" -eq 0 ]; then
        echo "$usage" >&2
        exit 1
      fi

      window_id="$(
        niri msg --json windows 2>/dev/null \
          | jq -r \
              --arg app_id "$app_id" \
              --arg app_id_regex "$app_id_regex" \
              --arg title "$title" \
              --arg title_regex "$title_regex" \
              --argjson match_any "$match_any" \
              '
              def app_ok:
                ($app_id == "" or .app_id == $app_id)
                and ($app_id_regex == "" or ((.app_id // "") | test($app_id_regex)));
              def title_ok:
                ($title == "" or ((.title // "") == $title))
                and ($title_regex == "" or ((.title // "") | test($title_regex)));
              def has_app_filter: $app_id != "" or $app_id_regex != "";
              def has_title_filter: $title != "" or $title_regex != "";
              def matches:
                if $match_any == 1 then
                  (has_app_filter and app_ok) or (has_title_filter and title_ok)
                else
                  app_ok and title_ok
                end;

              [ .[] | select(matches) ] | sort_by(.id) as $m
              | if ($m | length) == 0 then
                  empty
                else
                  ($m | map(select(.is_focused) | .id) | first // null) as $focused
                  | ($m | map(.id)) as $ids
                  | if ($focused != null) then
                      $ids[(($ids | index($focused)) + 1) % ($ids | length)]
                    else
                      ($m | max_by(.focus_timestamp // 0) | .id)
                    end
                end
              '
      )"

      if [ -n "''${window_id}" ] && [ "''${window_id}" != "null" ]; then
        exec niri msg action focus-window --id "''${window_id}"
      fi

      exec "$@"
    '';
  };
  brightnessStepDown = pkgs.writeShellApplication {
    name = "niri-brightness-step-down";
    runtimeInputs = with pkgs; [
      brightnessctl
      coreutils
    ];
    text = ''
      set -eu

      info="$(brightnessctl -m)"
      percent="$(printf '%s' "$info" | cut -d, -f4)"
      percent="''${percent%%%}"

      if ! [ -n "$percent" ] || [ "$(printf '%s' "$percent" | tr -cd '0-9')" != "$percent" ]; then
        exit 1
      fi

      if [ "$percent" -le 1 ]; then
        target=0
      elif [ "$percent" -le 10 ]; then
        target=1
      else
        target=$(( ((percent - 1) / 10) * 10 ))
        if [ "$target" -lt 10 ]; then
          target=10
        fi
      fi

      exec brightnessctl set "$target%"
    '';
  };
  brightnessStepUp = pkgs.writeShellApplication {
    name = "niri-brightness-step-up";
    runtimeInputs = with pkgs; [
      brightnessctl
      coreutils
    ];
    text = ''
      set -eu

      info="$(brightnessctl -m)"
      percent="$(printf '%s' "$info" | cut -d, -f4)"
      percent="''${percent%%%}"

      if ! [ -n "$percent" ] || [ "$(printf '%s' "$percent" | tr -cd '0-9')" != "$percent" ]; then
        exit 1
      fi

      if [ "$percent" -le 0 ]; then
        target=1
      elif [ "$percent" -lt 10 ]; then
        target=10
      else
        target=$(( ((percent / 10) + 1) * 10 ))
        if [ "$target" -gt 100 ]; then
          target=100
        fi
      fi

      exec brightnessctl set "$target%"
    '';
  };
in
{
  # We manually configure Niri via KDL to avoid module compatibility issues
  xdg.configFile."niri/config.kdl".text = ''
    input {
      keyboard {
        xkb {
          layout "us"
        }
      }

      touchpad {
        ${if vars.touchpad.naturalScroll then "natural-scroll" else ""}
        ${if vars.touchpad.tap then "tap" else ""}
        ${if vars.touchpad.disableWhileTyping then "dwt" else ""}
      }

      // Hover fully visible windows only — avoids scroll-on-hover in scrollable tiling.
      focus-follows-mouse max-scroll-amount="0%"
    }

    layout {
      gaps 8
      center-focused-column "never"
      always-center-single-column
      empty-workspace-above-first

      preset-column-widths {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
      }

      default-column-width { proportion 0.66667; }

      focus-ring {

        width 4
        active-color "#cba6f7"
        inactive-color "#585b70"
      }
    }

    // Disable the top-left hot corner that auto-opens the overview.
    // Overview is still reachable via Mod+X.
    gestures {
      hot-corners {
        off
      }
    }

    // Request apps to omit their client-side decorations (close/minimize/maximize buttons)
    // Apps that support xdg-decoration will hide their titlebar buttons
    prefer-no-csd

    // kdeconnectd runs as a systemd user service (modules/nixos/services/kdeconnect.nix)
    spawn-at-startup ${lib.concatMapStringsSep " " (arg: "\"${arg}\"") noctaliaCommand}

    // Pre-sleep lock: modules/nixos/hardware/power.nix (noctalia msg session lock).
    // Idle timeouts (5m lock, 5m30s DPMS, 30m suspend) live in Noctalia config.toml.

    binds {
      // -- User Requested Binds --

      // Quit / Close Window
      Mod+Q { close-window; }
      
      // Force Quit
      Mod+Shift+Q { spawn "sh" "-c" "niri msg focused-window | jq -e .pid | xargs -r kill -9"; }

      // Exit Niri
      Mod+Shift+O { quit; }

      // Files
      Mod+E { spawn "thunar"; }

      // Browser
      Mod+B { spawn "${focusOrSpawn}/bin/niri-focus-or-spawn" "--app-id-regex" "${zenAppIdRegex}" "--" "${zenCommand}"; }
      // Vesktop
      Mod+D { spawn "vesktop"; }
      
      // Notes
      Mod+O { spawn "${focusOrSpawn}/bin/niri-focus-or-spawn" "--app-id-regex" "${obsidianAppIdRegex}" "--title-regex" "${obsidianTitleRegex}" "--" "obsidian"; }

      // Spotify
      Mod+S { spawn "${focusOrSpawn}/bin/niri-focus-or-spawn" "--app-id" "spotify" "--" "spotify"; }

      // Cursor (IDE + Agents View): focus/cycle existing windows, spawn only if none
      Mod+A { spawn "${focusOrSpawn}/bin/niri-focus-or-spawn" "--any" "--app-id-regex" "${cursorAppIdRegex}" "--title-regex" "${cursorTitleRegex}" "--" "env" "-u" "NIXOS_OZONE_WL" "${lib.getExe pkgs.code-cursor}"; }

      // Brave web apps (Omarchy-style --app windows; desktop entries in web-apps.nix)
      Mod+Shift+G { spawn "${focusOrSpawn}/bin/niri-focus-or-spawn" "--app-id" "${geminiAppId}" "--" "${lib.getExe braveWebapp}" "${geminiUrl}"; }
      Mod+Shift+W { spawn "${focusOrSpawn}/bin/niri-focus-or-spawn" "--app-id" "${whatsappAppId}" "--" "${lib.getExe braveWebapp}" "${whatsappUrl}"; }

      // -- Noctalia Controls --
      Mod+Space { ${noctaliaSpawnSh "panel-toggle launcher"}; }
      Mod+V { ${noctaliaSpawnSh "panel-toggle clipboard"}; }
      Mod+Alt+Comma { ${noctaliaSpawnSh "settings-toggle"}; }
      Mod+Shift+C { ${noctaliaSpawnSh "panel-toggle control-center"}; }
      Mod+Escape { ${noctaliaSpawnSh "panel-toggle session"}; }

      // -- Sane Defaults (from Niri Wiki) --

      // Terminal (follows default-terminal.nix via xdg-terminal-exec)
      Mod+Return { spawn "xdg-terminal-exec"; }
      Mod+T { spawn "xdg-terminal-exec"; }

      // Screen Locking (Noctalia lock; DPMS follows idle timer in config.toml)
      Super+Shift+L { ${noctaliaSpawnSh "session lock"}; }

      // Screenshots (Noctalia region/fullscreen; Alt+Print stays on Niri for window capture)
      Mod+Shift+S { ${noctaliaSpawnSh "screenshot-region"}; }
      Print { ${noctaliaSpawnSh "screenshot-region"}; }
      Ctrl+Print { ${noctaliaSpawnSh "screenshot-fullscreen"}; }
      Alt+Print { screenshot-window; }
      
      // Volume
      XF86AudioRaiseVolume { ${noctaliaSpawnSh "volume-up"}; }
      XF86AudioLowerVolume { ${noctaliaSpawnSh "volume-down"}; }
      XF86AudioMute { ${noctaliaSpawnSh "volume-mute"}; }
      XF86AudioMicMute { ${noctaliaSpawnSh "mic-mute"}; }

      // Brightness
      XF86MonBrightnessUp { spawn "${brightnessStepUp}/bin/niri-brightness-step-up"; }
      XF86MonBrightnessDown { spawn "${brightnessStepDown}/bin/niri-brightness-step-down"; }

      // Focus Navigation
      Mod+Left  { focus-column-left; }
      Mod+Down  { focus-window-down; }
      Mod+Up    { focus-window-up; }
      Mod+Right { focus-column-right; }
      Mod+H     { focus-column-left; }
      Mod+J     { focus-window-down; }
      Mod+K     { focus-window-up; }
      Mod+L     { focus-column-right; }

      // Move Columns/Windows
      Mod+Shift+Left  { move-column-left; }
      Mod+Shift+Down  { move-window-down; }
      Mod+Shift+Up    { move-window-up; }
      Mod+Shift+Right { move-column-right; }
      Mod+Shift+H     { move-column-left; }
      Mod+Shift+J     { move-window-down; }
      Mod+Shift+K     { move-window-up; }
      Mod+Shift+L     { move-column-right; }

      // Column Manipulation
      Mod+Home { focus-column-first; }
      Mod+End  { focus-column-last; }
      Mod+C { center-column; }
      Mod+F { maximize-column; }
      Mod+Shift+F { fullscreen-window; }
      Mod+R { switch-preset-column-width; }
      
      // Consumption / Expulsion (Wiki Defaults)
      Mod+BracketLeft { consume-or-expel-window-left; }
      Mod+BracketRight { consume-or-expel-window-right; }
      Mod+Comma { consume-window-into-column; }
      Mod+Period { expel-window-from-column; }

      // Sizing
      Mod+Minus { set-column-width "-10%"; }
      Mod+Equal { set-column-width "+10%"; }
      Mod+Shift+Minus { set-window-height "-10%"; }
      Mod+Shift+Equal { set-window-height "+10%"; }
      Mod+Shift+R { switch-preset-window-height; } // Correction to Wiki description if supported, or logic

      // ** Workspace Navigation **
      Mod+U { focus-workspace-down; }
      Mod+I { focus-workspace-up; }

      Mod+Ctrl+Down { focus-workspace-down; }
      Mod+Ctrl+Up { focus-workspace-up; }
      Mod+Page_Down { focus-workspace-down; }
      Mod+Page_Up { focus-workspace-up; }

      // ** Move Workspaces **
      Mod+Shift+Page_Down { move-workspace-down; }
      Mod+Shift+Page_Up { move-workspace-up; }
      Mod+Shift+U { move-workspace-down; }
      Mod+Shift+I { move-workspace-up; }
      
      // Monitor Navigation
      Mod+Ctrl+Left { focus-monitor-left; }
      Mod+Ctrl+Right { focus-monitor-right; }
      
      // Help
      Mod+Shift+Slash { show-hotkey-overlay; }

      // ** Overview **
      Mod+X { toggle-overview; }

      // ** Window Management **
      Mod+W { toggle-window-floating; }
      Mod+Ctrl+W { switch-focus-between-floating-and-tiling; }

      // ** Move Column to Workspace **
      Mod+Ctrl+Alt+Down { move-column-to-workspace-down; }
      Mod+Ctrl+Alt+Up { move-column-to-workspace-up; }

      // ** Numbered Workspaces **
      Mod+1 { focus-workspace 1; }
      Mod+2 { focus-workspace 2; }
      Mod+3 { focus-workspace 3; }
      Mod+4 { focus-workspace 4; }
      Mod+5 { focus-workspace 5; }
      Mod+6 { focus-workspace 6; }
      Mod+7 { focus-workspace 7; }
      Mod+8 { focus-workspace 8; }
      Mod+9 { focus-workspace 9; }

      // ** Move Column to Numbered Workspace **
      Mod+Shift+1 { move-column-to-workspace 1; }
      Mod+Shift+2 { move-column-to-workspace 2; }
      Mod+Shift+3 { move-column-to-workspace 3; }
      Mod+Shift+4 { move-column-to-workspace 4; }
      Mod+Shift+5 { move-column-to-workspace 5; }
      Mod+Shift+6 { move-column-to-workspace 6; }
      Mod+Shift+7 { move-column-to-workspace 7; }
      Mod+Shift+8 { move-column-to-workspace 8; }
      Mod+Shift+9 { move-column-to-workspace 9; }

      // ** Gestures (Touchpad) **   
      // 3-finger swipe customization is not fully supported in Niri config yet.
      // Using Mod+Swipe (2-finger) for column and workspace navigation.
      
      // Vertical = Workspaces
      Mod+TouchpadScrollDown cooldown-ms=100 { focus-workspace-down; }
      Mod+TouchpadScrollUp cooldown-ms=100 { focus-workspace-up; }
      Mod+WheelScrollDown cooldown-ms=50 { focus-workspace-down; }
      Mod+WheelScrollUp cooldown-ms=50 { focus-workspace-up; }

      // Horizontal = Columns (Apps)
      Mod+TouchpadScrollRight cooldown-ms=100 { focus-column-right; }
      Mod+TouchpadScrollLeft cooldown-ms=100 { focus-column-left; }
      Mod+WheelScrollRight cooldown-ms=50 { focus-column-right; }
      Mod+WheelScrollLeft cooldown-ms=50 { focus-column-left; }

      // Mod+Shift + vertical scroll = window stack (wraps to adjacent column at edges)
      Mod+Shift+TouchpadScrollDown cooldown-ms=100 { focus-window-down-or-column-right; }
      Mod+Shift+TouchpadScrollUp cooldown-ms=100 { focus-window-up-or-column-left; }
      Mod+Shift+WheelScrollDown cooldown-ms=50 { focus-window-down-or-column-right; }
      Mod+Shift+WheelScrollUp cooldown-ms=50 { focus-window-up-or-column-left; }
    }

    hotkey-overlay {
      skip-at-startup
    }

    // Noctalia: Rounded corners for a modern look
    window-rule {
      geometry-corner-radius 5
      clip-to-geometry true
      draw-border-with-background false
    }

    // Steam (X11 via xwayland-satellite): global clip-to-geometry breaks CEF UI
    window-rule {
      match app-id="steam"
      geometry-corner-radius 0
      clip-to-geometry false
    }

    // Noctalia: Allows notification actions and window activation
    debug {
      honor-xdg-activation-with-invalid-serial
    }

    // Noctalia: Floating settings window (proportions fit scaled outputs)
    window-rule {
      match app-id="dev.noctalia.Noctalia"
      open-floating true
      default-column-width { proportion 0.85; }
      default-window-height { proportion 0.9; }
    }

    // Spotify: tile by default; cap open size if it floats
    window-rule {
      match app-id="spotify"
      open-floating false
      default-column-width { proportion 0.75; }
      default-window-height { proportion 0.85; }
    }

    // Noctalia: Blurred overview backdrop
    layer-rule {
      match namespace="^noctalia-backdrop"
      place-within-backdrop true
    }
  '';

  home.packages = with pkgs; [
    libnotify
    jq # Required for force-quit script
    focusOrSpawn
    brightnessStepUp
    brightnessStepDown
  ];
}

