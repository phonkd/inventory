{ self, inputs, ... }:
let
  shared = import ../../modules/_lib.nix { inherit inputs; };
  aarch64-system = "aarch64-linux";
in
{
  flake.nixosConfigurations."microvm-hypr" = inputs.nixpkgs-unstable.lib.nixosSystem {
    system = aarch64-system;
    modules = [
      inputs.microvm.nixosModules.microvm
      ./configuration.nix
      inputs.sops-nix.nixosModules.sops
      inputs.home-manager.nixosModules.home-manager
      {
        # Build runner tools (QEMU, etc.) for macOS, not linux
        microvm.vmHostPackages = inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin;
      }
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
        home-manager.users.phonkd = import ./home.nix;
      }
      (
        { config, pkgs, ... }:
        {
          nixpkgs.overlays = [ shared.overlay-unstable ];
        }
      )
    ];
  };

  # Run with: nix run .#microvm-hypr
  flake.packages.aarch64-darwin.microvm-hypr =
    let
      runner = self.nixosConfigurations."microvm-hypr".config.microvm.declaredRunner;
      darwinPkgs = inputs.nixpkgs-unstable.legacyPackages.aarch64-darwin;
    in
    darwinPkgs.writeShellScriptBin "microvm-vfkit-microvm-hypr" ''
      mkdir -p /tmp/microvm-waypipe
      exec ${darwinPkgs.bash}/bin/bash <(${darwinPkgs.gnused}/bin/sed \
        -e 's|--device virtio-serial,stdio ||' \
        -e 's|--restful-uri|--device virtio-vsock,port=22,socketURL=/tmp/microvm-waypipe/ssh.sock,connect --restful-uri|' \
        ${runner}/bin/microvm-run) "$@"
    '';
}
