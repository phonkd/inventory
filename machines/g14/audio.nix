{
  config,
  pkgs,
  lib,
  ...
}:
{
  services.pipewire = {
    enable = true;
    extraConfig = ''
      load-module module-null-sink sink_name=master_sink sink_properties=device.description="MasterSink"
      load-module module-loopback sink=<real_sink_name> source=master_sink.monitor
    '';
  };
}
