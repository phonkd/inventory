{ self, inputs, ... }:
let
  shared = import ../../modules/_lib.nix { inherit inputs; };
in
{
  flake.darwinConfigurations."mac" = inputs.nix-darwin.lib.darwinSystem {
    modules = [
      ./configuration.nix
      #inputs.dev.darwinModules.my-microvm
      inputs.home-manager.darwinModules.home-manager
      (
        { config, pkgs, ... }:
        {
          nixpkgs.overlays = [ shared.overlay-unstable ];
          environment.systemPackages = [
            inputs.microvm.packages.aarch64-darwin.microvm
          ];
        }
      )
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.phonkd = {
          imports = [ ./home.nix ] ++ shared.workSetupHomeModules;
        };
        home-manager.sharedModules = [
          inputs.nix-index-database.homeModules.default
        ];
      }
    ]
    ++ shared.workSetupDarwinModules;
  };
}
