{ self, inputs, ... }:
let
  shared = import ../../modules/_lib.nix { inherit inputs; };
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations."201-mono" = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      (
        { config, pkgs, ... }:
        {
          nixpkgs.overlays = [ shared.overlay-unstable ];
        }
      )
      ../../201-mono/configuration.nix
      inputs.sops-nix.nixosModules.sops
      ../../options.nix
      { label.labels = [ "vm" ]; }
    ];
  };
}
