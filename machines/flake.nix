{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rofi-zed-recent.url = "github:phonkd/rofi-zed-editor-projects";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, sops-nix, home-manager, rofi-zed-recent,... }:
    let
      system = "x86_64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      nixosConfigurations = {
        nixos-int = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
            ./122-nix-int/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };

        nixos-services = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
            ./121-nix-services/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };

        dev-vm = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
            ./10112-dev-vm/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
        "123-segglaecloud" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
            ./123-segglaecloud/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };

        blac = nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          modules = [
                      ./blac/configuration.nix
                      sops-nix.nixosModules.sops
                      ({ config, pkgs, ... }: {
                        environment.systemPackages = [
                          rofi-zed-recent.packages.x86_64-linux.default
                        ];
                      })
                    ];
        };
        hp = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ({ config, pkgs, ... }: { nixpkgs.overlays = [ overlay-unstable ]; })
            ./hp/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
