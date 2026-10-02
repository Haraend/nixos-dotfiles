# Windows VM - dockurr/windows (QEMU/KVM in Docker) driven over RDP.
# Approach borrowed wholesale from Omarchy's bin/omarchy-windows-vm, including
# its FreeRDP Kerberos bypass and log-anchored readiness check; packaged here
# declaratively instead of via interactive prompts.
#
# First launch: ~10 GB image download, watch progress at http://localhost:8006
# Resources live in ~/.config/windows/docker-compose.yml (RAM/CPU freely
# editable; DISK_SIZE only grows).
{ osConfig ? null, vars, pkgs, ... }:

let
  containerName = "windows-vm";
  homeDir = "/home/${vars.username}";
  tz =
    if (osConfig.time.timeZone or null) != null then
      osConfig.time.timeZone
    else
      "UTC";

  winvm = pkgs.writeShellApplication {
    name = "winvm";
    runtimeInputs = with pkgs; [
      coreutils
      docker
      docker-compose
      freerdp
      gnugrep
      gnused
      jq
      niri
    ];
    text = ''
      set -euo pipefail

      COMPOSE="$HOME/.config/windows/docker-compose.yml"
      KRB5_CONF="$HOME/.config/windows/krb5.conf"
      CONTAINER="${containerName}"

      usage() {
        cat <<'EOF'
      winvm - control the Windows VM (dockurr/windows in Docker)

        winvm                       start if needed, wait for boot, connect via RDP;
                                    VM stops when the RDP window closes
        winvm connect [-k]          -k/--keep-alive leaves it running after disconnect
        winvm setup                 first-time install: waits through the ~10 GB
                                    download + Windows setup (watch http://localhost:8006)
        winvm start                 start the container without connecting
        winvm stop                  shut the VM down
        winvm status                show state + endpoints
        winvm logs                  follow container logs
      EOF
      }

      need_compose() {
        if [[ ! -f $COMPOSE ]]; then
          echo "winvm: $COMPOSE missing - rebuild the flake to deploy it." >&2
          exit 1
        fi
      }

      ensure_docker() {
        if ! docker info >/dev/null 2>&1; then
          echo "winvm: docker daemon unreachable. Start it first:" >&2
          echo "  sudo systemctl start docker" >&2
          exit 1
        fi
      }

      is_running() {
        [[ $(docker inspect --format='{{.State.Status}}' "$CONTAINER" 2>/dev/null || true) == "running" ]]
      }

      is_installing() {
        local started_at
        started_at=$(docker inspect --format='{{.State.StartedAt}}' "$CONTAINER" 2>/dev/null || true)
        [[ -n $started_at ]] || return 1
        docker logs --since "$started_at" "$CONTAINER" 2>&1 \
          | grep -qiE "downloading|installing|getting files ready"
      }

      # wait_ready [max-tries]: poll until Windows reports booted (2 s per try;
      # defaults to 90 tries = 3 min, setup passes 900 = 30 min)
      wait_ready() {
        local max=''${1:-90} tries=0 started_at
        while (( tries < max )); do
          # Anchor the log scan to this container start: docker logs survives
          # restarts, so an unanchored grep matches stale boots instantly.
          started_at=$(docker inspect --format='{{.State.StartedAt}}' "$CONTAINER" 2>/dev/null || true)
          if [[ -n $started_at ]] \
            && docker logs --since "$started_at" "$CONTAINER" 2>&1 | grep -qi "windows started successfully"; then
            return 0
          fi
          sleep 2
          tries=$((tries + 1))
        done
        if is_installing; then
          echo "winvm: still installing - watch progress at http://localhost:8006," >&2
          echo "  then rerun this command once it finishes (or use: winvm setup)" >&2
        else
          echo "winvm: timed out waiting for Windows (see 'winvm logs')." >&2
        fi
        return 1
      }

      cmd_setup() {
        need_compose
        ensure_docker
        if ! is_running; then
          echo "Starting Windows VM..."
          docker-compose -f "$COMPOSE" up -d
        fi
        echo "Waiting for first-time install (~10 GB download + Windows setup;"
        echo "watch http://localhost:8006). This can take 15-30 minutes..."
        wait_ready 900
        echo "Windows is installed. Connect with: winvm"
      }

      cmd_connect() {
        local keep_alive=false
        if [[ $# -ge 1 ]]; then
          case $1 in
            -k | --keep-alive) keep_alive=true ;;
            *) usage; exit 1 ;;
          esac
        fi
        need_compose
        ensure_docker

        if ! is_running; then
          echo "Starting Windows VM..."
          docker-compose -f "$COMPOSE" up -d
        fi
        wait_ready

        local win_user win_pass
        win_user=$(sed -n 's/.*USERNAME: "\(.*\)"/\1/p' "$COMPOSE")
        win_pass=$(sed -n 's/.*PASSWORD: "\(.*\)"/\1/p' "$COMPOSE")
        if [[ -z $win_user ]]; then win_user="docker"; fi
        if [[ -z $win_pass ]]; then win_pass="admin"; fi

        # FreeRDP3 probes Kerberos before NTLM and blocks ~23 s per attempt
        # offline looking for a KDC; a realm-less config skips straight to NTLM.
        [[ -f $KRB5_CONF ]] && export KRB5_CONFIG="$KRB5_CONF"

        # HiDPI passthrough from the largest Niri output scale. Compare x100
        # in plain bash: bash arithmetic rejects floats, and jq emitting
        # `true`/`false` into `(())` trips set -u as an unset-name lookup.
        local scale scale_flag=""
        scale=$(niri msg --json outputs 2>/dev/null | jq '[.[] | .scale] | max // 0 | .*100 | round' 2>/dev/null) || true
        scale=''${scale:-0}
        if (( scale >= 170 )); then
          scale_flag="/scale:180"
        elif (( scale >= 130 )); then
          scale_flag="/scale:140"
        fi

        local rdp="" candidate
        for candidate in xfreerdp3 xfreerdp sdl-freerdp; do
          if command -v "$candidate" >/dev/null 2>&1; then rdp=$candidate; break; fi
        done
        if [[ -z $rdp ]]; then
          echo "winvm: no FreeRDP client found in PATH" >&2
          exit 1
        fi

        local args=(
          "/u:$win_user"
          "/p:$win_pass"
          "/v:127.0.0.1:3389"
          -grab-keyboard
          /sound /microphone /clipboard /cert:ignore
          /dynamic-resolution /gfx:AVC444
          "/floatbar:sticky:off,default:visible,show:fullscreen"
        )
        [[ -n $scale_flag ]] && args+=("$scale_flag")

        "$rdp" "''${args[@]}"

        if [[ $keep_alive == true ]]; then
          echo "VM still running. Stop it later with: winvm stop"
        else
          echo "RDP closed - stopping VM..."
          docker-compose -f "$COMPOSE" down
        fi
      }

      cmd_start() {
        need_compose
        ensure_docker
        docker-compose -f "$COMPOSE" up -d
        echo "VM starting. Connect with: winvm"
      }

      cmd_stop() {
        need_compose
        ensure_docker
        docker-compose -f "$COMPOSE" down
        echo "Windows VM stopped."
      }

      cmd_status() {
        need_compose
        if is_running; then
          echo "RUNNING   web UI: http://localhost:8006   RDP: 127.0.0.1:3389"
          echo "connect: winvm     stop: winvm stop     keep-alive: winvm connect -k"
        else
          local status
          status=$(docker inspect --format='{{.State.Status}}' "$CONTAINER" 2>/dev/null || true)
          if [[ -z $status ]]; then
            echo "Not created yet. Start with: winvm start"
          else
            echo "Stopped (state: $status). Start with: winvm"
          fi
        fi
      }

      case ''${1:-connect} in
        connect) shift 2>/dev/null || true; cmd_connect "$@" ;;
        -k | --keep-alive) shift; cmd_connect -k "$@" ;;
        setup | install) cmd_setup ;;
        start | up) cmd_start ;;
        stop | down) cmd_stop ;;
        status) cmd_status ;;
        logs) docker logs -f "$CONTAINER" ;;
        help | -h | --help) usage ;;
        *)
          echo "winvm: unknown command '$1'" >&2
          usage >&2
          exit 1
          ;;
      esac
    '';
  };
in
{
  home.packages = with pkgs; [
    freerdp # RDP client (xfreerdp / xfreerdp3)
    winvm
  ];

  xdg.configFile."windows/docker-compose.yml".text = ''
    services:
      windows:
        image: dockurr/windows
        container_name: ${containerName}
        environment:
          VERSION: "11"
          RAM_SIZE: "16G"
          CPU_CORES: "4"
          DISK_SIZE: "128G"
          USERNAME: "user"
          PASSWORD: "admin"
          TZ: "${tz}"
          ARGUMENTS: "-rtc base=localtime,clock=host,driftfix=slew"
        devices:
          - /dev/kvm
          - /dev/net/tun
        cap_add:
          - NET_ADMIN
        ports:
          - 127.0.0.1:8006:8006
          - 127.0.0.1:3389:3389/tcp
          - 127.0.0.1:3389:3389/udp
        volumes:
          - ${homeDir}/.windows:/storage
          - ${homeDir}/Windows:/shared
        restart: "no"
        stop_grace_period: 2m
  '';

  # Realm-less Kerberos config consumed by winvm via KRB5_CONFIG
  xdg.configFile."windows/krb5.conf".text = ''
    [libdefaults]
      dns_lookup_kdc = false
      dns_lookup_realm = false
  '';

  xdg.desktopEntries.windows-vm = {
    type = "Application";
    name = "Windows";
    comment = "Start the Windows VM (Docker) and connect over RDP";
    exec = "winvm connect";
    icon = "computer";
    categories = [ "System" ];
  };
}
