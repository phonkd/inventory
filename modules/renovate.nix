{ config, pkgs, ... }:

{
  sops.secrets.gh-renovate-token = {
    sopsFile = ./global-secrets/secret.yaml;
  };
  services.renovate = {
    enable = true;
    settings = {
      repositories = [
        "phonkd/inventory"
      ];

      gitAuthor = "Renovate Bot <renovate@localhost>";
      onboarding = true;
      requireConfig = false; # allows default config without renovate.json
      enabledManagers = [ "npm" "github-actions" ];
    };
    credentials = {
      RENOVATE_TOKEN = config.sops.secrets.gh-renovate-token.path;
    };
    runtimePackages = [
      pkgs.nodejs
      pkgs.git
    ];
  };
}
