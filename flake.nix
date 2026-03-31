{
  description = "Flake for some vms and more";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
    import-tree.url = "github:vic/import-tree";

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
    omni-nix = {
      url = "github:phonkd/omni.nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    # dev = {
    #   url = "git+file:///Users/phonkd/git/dev";
    # };
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs-unstable";
    proxmox-nixos.url = "github:SaumonNet/proxmox-nixos";
  };

  outputs =
    inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } (
      inputs.import-tree.filter (
        path:
        let
          isHostSubfile = builtins.match ".*hosts/[^/]+/.+" path != null;
          isDefaultNix = builtins.match ".*default\\.nix" path != null;
        in
        !isHostSubfile || isDefaultNix
      ) ./modules
    );
}
