{
  config,
  pkgs,
  lib,
  ...
}:

let
  isVM = lib.elem "vm" config.label.labels;
in
{
  config = lib.mkIf isVM {
    system.autoUpgrade = {
      enable = true;
      flake = "github:phonkd/inventory?dir=machines#${config.networking.hostName}";
      dates = "daily";
      randomizedDelaySec = "1h";
      allowReboot = false;
      flags = [ "--refresh" ];
    };
  };
}
