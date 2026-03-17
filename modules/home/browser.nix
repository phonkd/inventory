{ config, pkgs, ... }:

{
  programs.librewolf = {
    enable = true;
    settings = {
      "webgl.disabled" = false;
      "privacy.resistFingerprinting" = false;
    };
  };
}
