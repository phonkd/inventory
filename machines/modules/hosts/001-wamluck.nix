{ self, inputs, ... }:
let
  shared = import ../_lib.nix { inherit inputs; };
  system = "x86_64-linux";
in
{
  flake.nixosConfigurations."001-wamluck" = inputs.nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      inputs.proxmox-nixos.nixosModules.proxmox-ve
      ({ pkgs, lib, ... }: {
        services.proxmox-ve = {
          enable = true;
          ipAddress = "192.168.1.46";
        };
        nixpkgs.overlays = [
          inputs.proxmox-nixos.overlays.${system}
        ];
      })
      (
        { config, pkgs, ... }:
        {
          nixpkgs.overlays = [ shared.overlay-unstable ];
        }
      )
      ../../001-wamluck/configuration.nix
      inputs.sops-nix.nixosModules.sops
      ../../options.nix
    ];
  };
}
