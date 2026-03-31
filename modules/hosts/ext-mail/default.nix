{ self, inputs, ... }:
let
  shared = import ../../modules/_lib.nix { inherit inputs; };
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations.ext-mail = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      (
        { config, pkgs, ... }:
        {
          nixpkgs.overlays = [ shared.overlay-unstable ];
        }
      )
      ./configuration.nix
      ../../../options.nix
      { label.labels = [ "vm" ]; }
    ];
  };
}
