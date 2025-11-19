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

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
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
          pve-http = {
            rule = "Host(`pve.segglaecloud.phonkd.net`)";
            entryPoints = [ "web" ];
            middlewares = [ "pve-redirect-https" ];
            service = "pve-service";
          };

          # Main HTTPS router for PVE
          pve-router = {
            rule = "Host(`pve.segglaecloud.phonkd.net`)";
            service = "pve-service";
            entryPoints = [ "websecure" ];
            middlewares = [ "pve-headers" ];

            # <-- This makes Traefik actually use the ACME certs for this host
            tls = {
              certResolver = "cloudflare";
              domains = [
                {
                  main = "pve.segglaecloud.phonkd.net";
                }
              ];
            };
          };
        };

        serversTransports = {
          insecureTransport = {
            insecureSkipVerify = true;
          };
        };

        services = {
          pve-service = {
            loadBalancer = {
              serversTransport = "insecureTransport";
              servers = [
                { url = "https://192.168.1.46:8006"; }
              ];

              # Keep the original Host header (pve.segglaecloud.phonkd.net)
              passHostHeader = true;
            };
          };
        };

        # Middlewares live HERE, not at top level
        middlewares = {
          pve-redirect-https = {
            redirectScheme = {
              scheme = "https";
              permanent = true;
            };
          };

          pve-headers = {
            headers = {
              customRequestHeaders = {
                "X-Forwarded-Proto" = "https";
              };
            };
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
