# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:
let
  traefikcfapikeytemp = if builtins.pathExists config.sops.secrets."CF_DNS_API_TOKEN".path then
                    config.sops.secrets."CF_DNS_API_TOKEN".path
                  else
                    "/tmp/default_auth_token_placeholder";
in
{
  sops.secrets.CF_DNS_API_TOKEN = {
    sopsFile = ../../modules/global-secrets/traefik-secret.txt;
    format = "binary";
    owner = "traefik";
  };
  services.traefik = {
    enable = true;

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
        };
        websecure = {
          address = ":443";
          http.tls = {
            certResolver = "cloudflare";
            # domains = "*.segglaecloud.phonkd.net";
          };
        };
      };

      log = {
        level = "INFO";
        filePath = "${config.services.traefik.dataDir}/traefik.log";
        format = "json";
      };

      certificatesResolvers = {
        cloudflare = {
          acme = {
            email = "bhonk123@gmail.com";
            storage = "/var/lib/traefik/acme.json";
            dnsChallenge = {
              provider = "cloudflare";
              resolvers = [ "1.1.1.1:53" "1.0.0.1:53" ];
              propagation.delayBeforeChecks = 60;
            };
          };
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
            servers = [{url = "https://127.0.0.1:443";}];
          };
        };
      };
    };
  };
  systemd.services.traefik.serviceConfig = {
    EnvironmentFile = ["${traefikcfapikeytemp}"];
  };
}
