{ self, inputs, ... }:
let
  shared = import ../_lib.nix { inherit inputs; };
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations.blac = inputs.nixpkgs-unstable.lib.nixosSystem {
    inherit system;
    modules = [
      ../../blac/configuration.nix
      #inputs.kubierend.nixosModules.host
      inputs.sops-nix.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.sharedModules = [
          inputs.sops-nix.homeManagerModules.sops
          inputs.nix-index-database.homeModules.default
        ];
        #home-manager.users.phonkd = import ../../blac/home.nix;
        home-manager.users.phonkd = {
          imports = [ ../../blac/home.nix ] ++ shared.workSetupHomeModules;
        };
      }

      (
        { config, pkgs, ... }:
        {
          environment.systemPackages = [
            inputs.rofi-zed-recent.packages.x86_64-linux.default
          ];
        }
      )
      (
        { config, pkgs, ... }:
        {
          nixpkgs.overlays = [ shared.overlay-unstable ];
        }
      )
      #            inputs.lanzaboote.nixosModules.lanzaboote
      #            (
      #              { pkgs, lib, ... }:
      #              {
      #                environment.systemPackages = [
      #                  # For debugging and troubleshooting Secure Boot.
      #                  pkgs.sbctl
      #                ];
      #
      #                # Lanzaboote currently replaces the systemd-boot module.
      #                # This setting is usually set to true in configuration.nix
      #                # generated at installation time. So we force it to false
      #                # for now.
      #                boot.loader.systemd-boot.enable = lib.mkForce false;
      #
      #                boot.lanzaboote = {
      #                  enable = true;
      #                  pkiBundle = "/var/lib/sbctl";
      #                };
      #              }
      #            )
    ];
  };
}
