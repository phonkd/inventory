{
  description = "Flake for some vms and more";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    rofi-zed-recent.url = "github:phonkd/rofi-zed-editor-projects";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";

      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #work-setup.url = "git+file:///home/phonkd/git/bedag-setup";
    ambxst = {
      url = "git+https://github.com/Axenide/Ambxst/";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      sops-nix,
      home-manager,
      rofi-zed-recent,
      lanzaboote,
      ambxst,
      #work-setup,
      ...
    }:
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
    in
    {
      homeConfigurations = {
        "phonkd@blac" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [
            ./blac/home.nix
          ];
        };
        "phonkd@g14" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs-unstable {
            inherit system;
            config.allowUnfree = true;
          };
          modules = [
            ./g14/home.nix
          ];
        };
      };

      nixosConfigurations = {
        blac = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./blac/configuration.nix
            sops-nix.nixosModules.sops
            (
              { config, pkgs, ... }:
              {
                environment.systemPackages = [
                  rofi-zed-recent.packages.x86_64-linux.default
                ];
              }
            )
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ overlay-unstable ];
              }
            )
            #work-setup.nixosModules.default
            #            lanzaboote.nixosModules.lanzaboote
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
        g14 = nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          modules = [
            ./g14/configuration.nix
            sops-nix.nixosModules.sops
            #work-setup.nixosModules.default
            ambxst.nixosModules.default
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ overlay-unstable ];
              }
            )
          ];
        };
        ext-mail = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ overlay-unstable ];
              }
            )
            ./ext-mail/configuration.nix
            ./options.nix
            { label.labels = [ "vm" ]; }
          ];
        };

        "200-root" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ overlay-unstable ];
              }
            )
            ./200-root/configuration.nix
            sops-nix.nixosModules.sops
            ./options.nix
            { label.labels = [ "vm" ]; }
          ];
        };
        "201-mono" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ overlay-unstable ];
              }
            )
            ./201-mono/configuration.nix
            sops-nix.nixosModules.sops
            ./options.nix
            { label.labels = [ "vm" ]; }
          ];
        };
        "203-spot" = nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          modules = [
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ overlay-unstable ];
              }
            )
            ./203-spot/configuration.nix
            sops-nix.nixosModules.sops
            ./options.nix
            { label.labels = [ "vm" ]; }
          ];
        };
        "000-qcow" = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ overlay-unstable ];
              }
            )
            ./000-qcow/configuration.nix
            sops-nix.nixosModules.sops
            ./options.nix
            { label.labels = [ "vm" ]; }
          ];
        };
      };
    };
}
