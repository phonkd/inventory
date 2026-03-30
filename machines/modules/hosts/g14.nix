{ self, inputs, ... }:
let
  shared = import ../_lib.nix { inherit inputs; };
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations.g14 = inputs.nixpkgs-unstable.lib.nixosSystem {
    inherit system;
    modules = [
      ../../g14/configuration.nix
      inputs.sops-nix.nixosModules.sops
      inputs.ambxst.nixosModules.default
      inputs.home-manager.nixosModules.home-manager
      #inputs.kubierend.nixosModules.host
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.backupFileExtension = "bak";
        home-manager.users.phonkd = import ../../g14/home.nix;
        home-manager.sharedModules = [
          inputs.sops-nix.homeManagerModules.sops
          inputs.nix-index-database.homeModules.default
        ];
      }
      (
        { config, pkgs, ... }:
        {
          nixpkgs.overlays = [ shared.overlay-unstable ];
        }
      )
    ];
  };
}
