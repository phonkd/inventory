# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  traefikcfapikeytemp = if builtins.pathExists config.sops.secrets."traefikcfapikey".path then
                    config.sops.secrets."traefikcfapikey".path
                  else
                    "/tmp/default_auth_token_placeholder";
in
{
  sops.secrets.traefikcfapikey = {
    sopsFile = ../../modules/global-secrets/traefik-secret.txt;
    format = "binary";
  };
  services.traefik = {
    environmentFiles = ["${traefikcfapikeytemp}"];

    enable = true;

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
        };
        websecure = {
          address = ":443";
          http.tls.certResolver = "letsencrypt";
        };
      };

      log = {
        level = "INFO";
        filePath = "${config.services.traefik.dataDir}/traefik.log";
        format = "json";
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "bhonk123@gmail.com";
        storage = "${config.services.traefik.dataDir}/acme.json";
        # Use DNS challenge with Cloudflare
        dnsChallenge = {
          provider = "cloudflare";
          delayBeforeCheck = 0; # optional
        };
      };
      api.dashboard = true;
      # api.insecure = true; # Only enable if you want public access
    };
    dynamicConfigOptions = {
      http.routers = {
        rustfs-router = {
          rule = "Host(`s5.segglaecloud.phonkd.net`)";
          service = "rustfs-service";
          entryPoints = ["websecure"];
        };
        keycloak-router = {
          rule = "Host(`auth.segglaecloud.phonkd.net`)";
          service = "keycloak-service";
          entryPoints = ["websecure"];
        };
      };
      http.services = {
        rustfs-service = {
          loadBalancer = {
            servers = [{url = "http://127.0.0.1:9000";}];
          };
        };
        keycloak-service = {
          loadBalancer = {
            servers = [{url = "http://127.0.0.1:8123";}];
          };
        };
      };
    };
  };
}
