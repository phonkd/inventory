{
  config,
  pkgs,
  lib,
  ...
}:

let
  pactl = "${pkgs.pulseaudio}/bin/pactl";
  pacat = "${pkgs.pulseaudio}/bin/pacat";
  pwLink = "${pkgs.pipewire}/bin/pw-link";

  cleanupCombined = pkgs.writeShellScript "combined-sink-cleanup" ''
    ${pactl} list short modules | awk '/combined-all/ {print $1}' \
      | while read mod; do ${pactl} unload-module "$mod" 2>/dev/null; done
  '';

  cleanupSpot = pkgs.writeShellScript "spot-sink-cleanup" ''
    ${pactl} list short modules | awk '/sink_name=spot-203/ {print $1}' \
      | while read mod; do ${pactl} unload-module "$mod" 2>/dev/null; done
  '';
in
{
  systemd.user.services.pipewire-network-sink = {
    description = "Load PipeWire Network Sink for 203-spot";
    after = [ "pipewire-pulse.service" ];
    bindsTo = [ "pipewire-pulse.service" ];
    wants = [ "pipewire-pulse.service" ];
    wantedBy = [ "default.target" ];
    script = ''
      ${cleanupSpot}
      ${pactl} load-module module-tunnel-sink server=tcp:192.168.1.203:4713 sink_name=spot-203
    '';
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "10s";
      RemainAfterExit = true;
      ExecStopPost = "${cleanupSpot}";
    };
  };

  systemd.user.services.pipewire-combined-sink = {
    description = "Combined sink: local speakers (auto-delayed) + WiFi spot-203";
    after = [
      "pipewire-pulse.service"
      "pipewire-network-sink.service"
    ];
    bindsTo = [ "pipewire-pulse.service" ];
    wants = [
      "pipewire-pulse.service"
      "pipewire-network-sink.service"
    ];
    wantedBy = [ "default.target" ];
    path = [
      pkgs.pulseaudio
      pkgs.pipewire
      pkgs.iputils
      pkgs.gawk
    ];
    script = ''
      LOCAL_SINK=$(${pactl} list sinks short \
        | awk '$2 !~ /spot-203|combined-all|hdmi/ && $2 ~ /alsa_output/ {print $2; exit}')

      if [ -z "$LOCAL_SINK" ]; then
        echo "ERROR: Could not find local ALSA sink" >&2
        exit 1
      fi
      echo "Local sink: $LOCAL_SINK"

      # Clean up leftovers from previous runs.
      ${cleanupCombined}

      # Create the combined null sink — apps send audio here.
      ${pactl} load-module module-null-sink \
        sink_name=combined-all \
        "sink_properties=device.description=Combined (Speakers + WiFi)"

      sleep 1

      # WiFi path: direct pw-link, WirePlumber can't touch this.
      ${pwLink} "combined-all:monitor_FL" "spot-203:send_FL" || true
      ${pwLink} "combined-all:monitor_FR" "spot-203:send_FR" || true

      # Estimate latency: ping RTT to remote host + 200ms for remote PA buffer.
      # PipeWire's PA compat layer reports 0 for tunnel sink latency, so we
      # can't query it directly. Ping RTT gives us the one-way network transit.
      echo "Measuring network latency to 192.168.1.203..."
      RTT_MS=$(ping -c 4 -W 2 192.168.1.203 2>/dev/null \
        | awk -F'/' '/avg/ {printf "%d", $5 + 0.5}')
      if [ -z "$RTT_MS" ] || [ "$RTT_MS" -lt 1 ]; then
        echo "Ping failed, using 200ms fallback"
        DELAY_MS=200
      else
        # RTT_MS is round-trip; one-way ~= RTT/2, plus 200ms remote PA buffer.
        DELAY_MS=$(( RTT_MS / 2 + 220 ))
        echo "Ping RTT: ''${RTT_MS}ms -> delay: ''${DELAY_MS}ms"
      fi

      # Local speaker path: pacat pipes bypass WirePlumber entirely.
      # --latency-msec on the record side creates the delay buffer.
      # This is the main foreground process — service stays alive while it runs.
      ${pacat} --record --device=combined-all.monitor \
        --format=float32le --rate=48000 --channels=2 \
        --channel-map=front-left,front-right \
        --latency-msec=$DELAY_MS \
      | ${pacat} --playback --device="$LOCAL_SINK" \
        --format=float32le --rate=48000 --channels=2 \
        --channel-map=front-left,front-right \
        --latency-msec=50
    '';
    serviceConfig = {
      Type = "simple";
      Restart = "on-failure";
      RestartSec = "15s";
      # Unload the null sink when service stops or restarts.
      ExecStopPost = "${cleanupCombined}";
      # Don't treat SIGTERM exit (143) as failure needing restart.
      SuccessExitStatus = [
        0
        143
      ];
    };
  };
}
