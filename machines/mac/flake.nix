{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.11-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    #sops-nix.url = "github:Mic92/sops-nix";

  };
  outputs = {
    self,
    nix-darwin,
    nixpkgs,
    #sops-nix,
    ...
  }:

  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Eliss-MacBook-Pro
    darwinConfigurations."Eliss-MacBook-Pro" = nix-darwin.lib.darwinSystem {
      modules = [
        ./configuration.nix
        #sops-nix.darwinModules.sops
      ];
    };
  };
}
