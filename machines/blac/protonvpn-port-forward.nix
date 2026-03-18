{ config, lib, pkgs, ... }:

# Dynamically opens the ProtonVPN-assigned forwarded port in the firewall.
# A systemd service retrieves the port via the Local Agent after proton0 comes
# up, inserts an iptables allow rule, and removes it when the VPN disconnects.
#
# Requires ~/.local/bin/proton-port (queries ProtonVPN Local Agent for the port).

let
  protonPortScript = "/home/phonkd/.local/bin/proton-port";

  portOpenScript = pkgs.writeShellScript "protonvpn-open-port" ''
    set -euo pipefail

    # Expose the user session bus so secretstorage works
    XDGRT="/run/user/$(id -u phonkd)"
    export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDGRT/bus"

    # Wait up to 30s for proton0 to appear
    for i in $(seq 1 30); do
      ${pkgs.iproute2}/bin/ip link show proton0 &>/dev/null && break
      sleep 1
    done
    ${pkgs.iproute2}/bin/ip link show proton0 &>/dev/null \
      || { echo "proton0 not up after 30s, giving up"; exit 1; }

    # Retrieve the forwarded port from the Local Agent
    PORT=$(sudo -u phonkd ${protonPortScript} 2>/dev/null)
    if ! echo "$PORT" | grep -qE '^[0-9]+$'; then
      echo "Failed to get forwarded port (got: '$PORT')"
      exit 1
    fi
    echo "ProtonVPN forwarded port: $PORT"

    # Remove any rules we previously inserted (tagged with protonvpn-pf)
    ${pkgs.iptables}/sbin/iptables -L nixos-fw --line-numbers -n 2>/dev/null \
      | awk '/protonvpn-pf/{print $1}' | sort -rn \
      | xargs -I{} ${pkgs.iptables}/sbin/iptables -D nixos-fw {} 2>/dev/null || true

    # Insert new allow rules on the VPN interface
    ${pkgs.iptables}/sbin/iptables -I nixos-fw \
      -i proton0 -p tcp --dport "$PORT" \
      -m comment --comment "protonvpn-pf" -j nixos-fw-accept
    ${pkgs.iptables}/sbin/iptables -I nixos-fw \
      -i proton0 -p udp --dport "$PORT" \
      -m comment --comment "protonvpn-pf" -j nixos-fw-accept

    echo "$PORT" > /run/protonvpn-forwarded-port
    echo "Opened $PORT/tcp and $PORT/udp on proton0"
  '';

  portCloseScript = pkgs.writeShellScript "protonvpn-close-port" ''
    ${pkgs.iptables}/sbin/iptables -L nixos-fw --line-numbers -n 2>/dev/null \
      | awk '/protonvpn-pf/{print $1}' | sort -rn \
      | xargs -I{} ${pkgs.iptables}/sbin/iptables -D nixos-fw {} 2>/dev/null || true
    rm -f /run/protonvpn-forwarded-port
    echo "Removed ProtonVPN port forwarding firewall rules"
  '';

in {
  systemd.services.protonvpn-port-forward = {
    description = "Open ProtonVPN forwarded port in firewall";
    after = [ "network.target" "NetworkManager.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = portOpenScript;
      ExecStop = portCloseScript;
      Restart = "on-failure";
      RestartSec = "5s";
    };
  };

  # Re-run whenever the proton0 interface comes up or goes down
  networking.networkmanager.dispatcherScripts = [
    {
      source = pkgs.writeShellScript "99-protonvpn-pf" ''
        IFACE="$1"
        ACTION="$2"
        case "$IFACE:$ACTION" in
          proton0:up|proton0:vpn-up)
            systemctl restart protonvpn-port-forward ;;
          proton0:down|proton0:vpn-down|proton0:pre-down)
            systemctl stop protonvpn-port-forward ;;
        esac
      '';
      type = "basic";
    }
  ];
}
