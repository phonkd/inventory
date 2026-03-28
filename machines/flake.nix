{
  description = "Flake for some vms and more";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    rofi-zed-recent.url = "github:phonkd/rofi-zed-editor-projects";
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";

      # Optional but recommended to limit the size of your system closure.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ambxst = {
      url = "git+https://github.com/Axenide/Ambxst/";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    #kubierend = {
     # url = "path:/home/phonkd/git/kubierend";
      #inputs.nixpkgs.follows = "nixpkgs-unstable";
    #};
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # dev = {
    #   url = "git+file:///Users/phonkd/git/dev";
    # };
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
      nix-darwin,
      #kubierend,
      microvm,
      #dev,
      ...
    }:
    let
      system = "x86_64-linux";
      aarch64-system = "aarch64-linux";
      overlay-unstable = final: prev: {
        unstable = import nixpkgs-unstable {
          system = prev.stdenv.hostPlatform.system;
          config.allowUnfree = true;
        };
      };
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      # Path to the local work-setup repo — only loaded on machines that opt in.
      # Requires `--impure` when rebuilding (e.g. darwin-rebuild switch --flake .# --impure)
      work-setup-path =
        if builtins.pathExists /Users/phonkd/git/bedag-setup then
          /Users/phonkd/git/bedag-setup
        else if builtins.pathExists /home/phonkd/git/bedag-setup then
          /home/phonkd/git/bedag-setup
        else
          null;
      hasWorkSetup = work-setup-path != null;
      # System-level modules (options + nixos-specific config)
      workSetupSystemModules =
        if hasWorkSetup then
          [
            "${work-setup-path}/options.nix"
            "${work-setup-path}/nixos/nixos-config.nix"
          ]
        else
          [ ];
      # Home-manager modules (tools, gitconfig, hm-level options)
      workSetupHomeModules =
        if hasWorkSetup then
          [
            "${work-setup-path}/home-manager/home-manager.nix"
          ]
        else
          [ ];
      workSetupDarwinModules =
        if hasWorkSetup then
          [
            "${work-setup-path}/darwin/nix-darwin-config.nix"
          ]
        else
          [ ];
    in
    {
      darwinConfigurations = {
        "Eliss-MacBook-Pro" = nix-darwin.lib.darwinSystem {
          modules = [
            ./mac/configuration.nix
            #dev.darwinModules.my-microvm
            home-manager.darwinModules.home-manager
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ overlay-unstable ];
                environment.systemPackages = [
                  microvm.packages.aarch64-darwin.microvm
                ];
              }
            )
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.phonkd = {
                imports = [ ./mac/home.nix ] ++ workSetupHomeModules;
              };
            }
          ]
          ++ workSetupDarwinModules;
        };
      };

      nixosConfigurations = {
        blac = nixpkgs-unstable.lib.nixosSystem {
          inherit system;
          modules = [
            ./blac/configuration.nix
            #kubierend.nixosModules.host
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
              home-manager.users.phonkd = import ./blac/home.nix;
            }
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
            ambxst.nixosModules.default
            home-manager.nixosModules.home-manager
            #kubierend.nixosModules.host
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "bak";
              home-manager.users.phonkd = import ./g14/home.nix;
              home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
            }
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

        "microvm-hypr" = nixpkgs-unstable.lib.nixosSystem {
          system = aarch64-system;
          modules = [
            microvm.nixosModules.microvm
            ./microvm-hypr/configuration.nix
            sops-nix.nixosModules.sops
            home-manager.nixosModules.home-manager
            {
              # Build runner tools (QEMU, etc.) for macOS, not linux
              microvm.vmHostPackages = nixpkgs-unstable.legacyPackages.aarch64-darwin;
            }
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.sharedModules = [ sops-nix.homeManagerModules.sops ];
              home-manager.users.phonkd = import ./microvm-hypr/home.nix;
            }
            (
              { config, pkgs, ... }:
              {
                nixpkgs.overlays = [ overlay-unstable ];
              }
            )
          ];
        };
      };

      # Run with: nix run .#microvm-hypr
      # Wrap the runner to inject SSH port forwarding into the microvm netdev
      packages.aarch64-darwin.microvm-hypr =
        let
          runner = self.nixosConfigurations."microvm-hypr".config.microvm.declaredRunner;
          darwinPkgs = nixpkgs-unstable.legacyPackages.aarch64-darwin;
        in
        darwinPkgs.writeShellScriptBin "microvm-qemu-microvm-hypr" ''
          exec ${darwinPkgs.bash}/bin/bash <(${darwinPkgs.gnused}/bin/sed 's|user,id=usernet|user,id=usernet,hostfwd=tcp::2222-:22|' ${runner}/bin/microvm-run) "$@"
        '';
    };
}
