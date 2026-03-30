{ self, inputs, ... }:
let
  shared = import ../_lib.nix { inherit inputs; };
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations."203-spot" = inputs.nixpkgs-unstable.lib.nixosSystem {
    inherit system;
    modules = [
      (
        { config, pkgs, ... }:
        {
          nixpkgs.overlays = [ shared.overlay-unstable ];
        }
      )
      ../../203-spot/configuration.nix
      inputs.sops-nix.nixosModules.sops
      ../../options.nix
      { label.labels = [ "vm" ]; }
    ];
  };
}
