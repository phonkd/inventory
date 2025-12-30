{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops.secrets.CF_DNS_API_TOKEN = {
    sopsFile = ../../modules/global-secrets/traefik-secret.txt;
    format = "binary";
    owner = "traefik";
  };

  services.traefik = {
    enable = true;
    environmentFiles = [ "${config.sops.secrets.CF_DNS_API_TOKEN.path}" ];
    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          # GLOBAL REDIRECT: Redirect everything on :80 to websecure (:443)
          http = {
            redirections = {
              entryPoint = {
                to = "websecure";
                scheme = "https";
              };
            };
          };
        };
        websecure = {
          address = ":443";
          # We keep TLS generic here; router will say which certResolver to use
          http = {
            tls = { };
          };
        };
      };

      log = {
        level = "DEBUG";
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
              resolvers = [
                "1.1.1.1:53"
                "1.0.0.1:53"
              ];
              # your "propagation" thing will just be ignored anyway,
              # so I’m leaving it out for clarity
            };
          };
        };
      };

      api = {
        dashboard = true;
        insecure = true; # turn off once it's all working
      };
    };

    dynamicConfigOptions = {
      http = {
        routers = {
          # Optional HTTP -> HTTPS redirect for pve
          oldblac-pve-router = {
            rule = "Host(`oldblac.int.phonkd.net`)";
            service = "oldblac-pve-service";
            entryPoints = [ "websecure" ];
            middlewares = [
              "pve-headers"
              "ip-filter"
            ];
            tls = {
              certResolver = "cloudflare";
              domains = [
                {
                  main = "oldblac.int.phonkd.net";
                }
              ];
            };
          };
          vaultwarden-https = {
            rule = "Host(`vw.w.phonkd.net`)";
            entryPoints = [ "websecure" ];
            service = "vaultwarden";
            tls = {
              certResolver = "cloudflare";
              domains = [
                {
                  main = "vw.w.phonkd.net";
                }
              ];
            };
          };
          immich-https = {
            rule = "Host(`immich.w.phonkd.net`)";
            tls.certResolver = "cloudflare";
            entryPoints = [ "websecure" ];
            service = "immich-service";
            middlewares = [
              "ip-filter"
            ];
          };
          auth = {
            rule = "Host(`auth.w.phonkd.net`)";
            entryPoints = [ "websecure" ];
            service = "keycloak-service";
            tls = {
              certResolver = "cloudflare";
              domains = [
                {
                  main = "auth.w.phonkd.net";
                }
              ];
            };
            middlewares = [
              "ip-filter"
            ];
          };

          s3 = {
            rule = "Host(`public.s3.w.phonkd.net`)";
            tls.certResolver = "cloudflare";
            entryPoints = [
              "websecure"
              "web"
            ];
            service = "s3-service";
          };
          s3-priv = {
            rule = "Host(`priv.s3.w.phonkd.net`)";
            tls.certResolver = "cloudflare";
            entryPoints = [
              "websecure"
              "web"
            ];
            service = "s3-service";
          };
          s3-api = {
            rule = "Host(`api.s3.w.phonkd.net`)";
            tls.certResolver = "cloudflare";
            entryPoints = [
              "websecure"
              "web"
            ];
            middlewares = [
              "ip-filter"
            ];
            service = "s3-api";
          };
        };

        serversTransports = {
          insecureTransport = {
            insecureSkipVerify = true;
          };
        };

        services = {
          oldblac-pve-service = {
            loadBalancer = {
              serversTransport = "insecureTransport";
              servers = [
                { url = "https://192.168.1.47:8006"; }
              ];
              passHostHeader = true;
            };
          };
          vaultwarden = {
            loadBalancer = {
              servers = [
                { url = "http://192.168.1.121:8000"; }
              ];
            };
          };
          immich-service = {
            loadBalancer = {
              servers = [
                { url = "http://192.168.1.121:2283"; }
              ];
            };
          };
          keycloak-service = {
            loadBalancer = {
              servers = [
                { url = "http://192.168.1.123:8123"; }
              ];
            };
          };
          s3-service = {
            loadBalancer = {
              servers = [
                { url = "http://127.0.0.1:3902"; }
              ];
            };
          };
          s3-api = {
            loadBalancer = {
              passHostHeader = true;
              servers = [
                { url = "http://127.0.0.1:3900"; }
              ];
            };
          };
        };

        # Middlewares live HERE, not at top level
        middlewares = {
          pve-headers = {
            headers = {
              customRequestHeaders = {
                "X-Forwarded-Proto" = "https";
              };
            };
          };
          ip-filter = {
            ipAllowList.sourceRange = [
              "192.168.1.0/24"
            ];
          };
        };
      };
    };
  };

  # systemd: load CF token env file correctly
  systemd.services.traefik.serviceConfig = {
    # the secret file itself must contain lines like:
    # CF_DNS_API_TOKEN=supersecrettoken
    EnvironmentFile = [ config.sops.secrets.CF_DNS_API_TOKEN.path ];
  };
}
