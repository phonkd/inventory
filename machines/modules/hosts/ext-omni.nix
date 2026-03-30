{ self, inputs, ... }:
let
  shared = import ../_lib.nix { inherit inputs; };
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations.ext-omni = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      (
        { config, pkgs, ... }:
        {
          nixpkgs.overlays = [ shared.overlay-unstable ];
        }
      )
      ../../ext-omni/configuration.nix
      inputs.sops-nix.nixosModules.sops
      inputs.omni-nix.nixosModules.omni
      ../../options.nix
      { label.labels = [ "vm" ]; }
    ];
  };
}
