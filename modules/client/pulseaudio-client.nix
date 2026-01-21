{
  config,
  pkgs,
  lib,
  ...
}:

{
  systemd.user.services.pipewire-network-sink = {
    description = "Load PipeWire Network Sink for 203-spot";
    after = [ "pipewire-pulse.service" ];
    bindsTo = [ "pipewire-pulse.service" ];
    wants = [ "pipewire-pulse.service" ];
    wantedBy = [ "default.target" ];
    script = ''
      ${pkgs.pulseaudio}/bin/pactl load-module module-tunnel-sink server=tcp:192.168.1.203:4713 sink_name=spot-203
    '';
    serviceConfig = {
      Restart = "on-failure";
      RestartSec = "10s";
      RemainAfterExit = true;
    };
  };
}
