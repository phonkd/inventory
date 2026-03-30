{ inputs }:
let
  overlay-unstable = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = prev.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };

  # Path to the local work-setup repo -- only loaded on machines that opt in.
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
  inherit
    overlay-unstable
    work-setup-path
    hasWorkSetup
    workSetupSystemModules
    workSetupHomeModules
    workSetupDarwinModules;
}
