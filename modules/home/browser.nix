{ config, pkgs, ... }:

{
  programs.librewolf = {
    enable = true;
    settings = {
      "webgl.disabled" = false;
      "privacy.resistFingerprinting" = false;
    };
    profiles.private.path = "~/browser-profiles/work";
  };
}
