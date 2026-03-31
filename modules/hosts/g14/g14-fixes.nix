{
  lib,
  pkgs,
  config,
  ...
}:
{
  hardware.nvidia.open = false;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.prime = {
    offload.enable = lib.mkForce false;
    reverseSync.enable = true;
    allowExternalGpu = true;
  };
  programs.rog-control-center.enable = true;
  environment.systemPackages = with pkgs; [
    displaylink
  ];
  boot = {
    extraModulePackages = [ config.boot.kernelPackages.evdi ];
    initrd.kernelModules = [ "evdi" ];
    extraModprobeConfig = ''
      options nvidia NVreg_EnableGpuFirmware=0
    '';
  };
  # Disable AMD Precision Boost to prevent the 10s spike → 95°C → throttle cycle
  # Caps CPU at base 3.3 GHz for cooler, more consistent sustained performance
  systemd.tmpfiles.rules = [
    "w /sys/devices/system/cpu/cpufreq/boost - - - - 0"
  ];

  systemd.services.displaylink-server = {
    enable = true;
    requires = [ "systemd-udevd.service" ];
    after = [ "systemd-udevd.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.displaylink}/bin/DisplayLinkManager";
      User = "root";
      Group = "root";
      Restart = "on-failure";
      RestartSec = 5; # Wait 5 seconds before restarting
    };
  };
}
