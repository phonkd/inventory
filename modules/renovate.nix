{ config, pkgs, ... }:

{
  sops.secrets.gh-renovate-token = {
    sopsFile = ./global-secrets/secret.yaml;
  };
  services.renovate = {
    enable = true;
    settings = {
      endpoint = "https://github.com";
      platform = "github";
    };
    credentials = {
      RENOVATE_TOKEN = config.sops.secrets.gh-renovate-token.path;
    };
  };
}
