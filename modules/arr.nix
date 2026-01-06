{ config, pkgs, ... }:

{
  services.jellyfin.enable = true;
  boot.kernelParams = [ "i915.enable_guc=2" ];

  # Ensure the i915 driver is loaded early
  boot.initrd.kernelModules = [ "i915" ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD (The QSV Driver)
      intel-compute-runtime # OpenCL (Required for HDR Tone Mapping)
      vpl-gpu-rt # New VPL runtime for 12th Gen+
    ];
  };
  # FIX: Grant the Jellyfin user access to the GPU
  users.users.jellyfin = {
    extraGroups = [
      "render"
      "video"
      "phonkd"
    ];
  };
  # 4. ENVIRONMENT VARIABLES
  # ------------------------
  # Force the correct driver (iHD) instead of the legacy one (i965)
  environment.sessionVariables = {
    LIBVA_DRIVER_NAME = "iHD";
  };
}
