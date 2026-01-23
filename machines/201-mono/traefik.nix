{
  config,
  pkgs,
  lib,
  ...
}:
let
  # apps are sourced across all nixos modules containing phonkds.modules configs
  # the definition of the module is in applist.nix
  # Filter apps that have traefik enabled and a domain configured
  traefikservices = lib.filterAttrs (
    name: app: app.traefik.enable && app.traefik.domain != null
  ) config.phonkds.modules;
  autoTraefikConfig = {
    http = {
      services = lib.mapAttrs (name: svc: {
        loadBalancer = {
          servers = [
            # Use svc.traefik.scheme instead of hardcoded "http"
            { url = "${svc.traefik.scheme}://${svc.ip}:${toString svc.port}${toString svc.path}"; }
          ];
          # Only add serversTransport if one is defined
          passHostHeader = true; # Generally safe to default to true
        }
        // (lib.optionalAttrs (svc.traefik.transport != null) {
          serversTransport = svc.traefik.transport;
        });
      }) traefikservices;

      # ERROR WAS HERE: "middlewares" removed from here.
      # You cannot assign a list here, and 'traefikservices' doesn't have an .auth property.

      routers = lib.mapAttrs (name: svc: {
        entryPoints = [ "websecure" ];
        rule = "Host(`${svc.traefik.domain}`)";
        service = name;
        tls.certResolver = "cloudflare";

        # CORRECT LOCATION: Apply middlewares dynamically to this specific router
        middlewares =
          [ ]
          ++ (lib.optionals (svc.traefik.auth or false) [ "forward-auth" ])
          ++ (lib.optionals (svc.traefik.ipfilter or false) [ "ip-filter" ])
          ++ svc.traefik.extraMiddlewares;

      }) traefikservices;
    };
  };

  # middleware
  manualTraefikConfig = {
    http = {
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
            "10.8.0.0/16"
          ];
        };
        forward-auth = {
          forwardAuth = {
            address = "http://127.0.0.1:9091/api/authz/forward-auth?rd=https://auth.w.phonkd.net/";
            trustForwardHeader = true;
            authResponseHeaders = [
              "Remote-User"
              "Remote-Groups"
              "Remote-Name"
              "Remote-Email"
            ];
          };
        };
        vnc-root-rewrite = {
          replacePathRegex = {
            regex = "^/$";
            replacement = "/vnc.html";
          };
        };
      };
      serversTransports = {
        insecureTransport = {
          insecureSkipVerify = true;
        };
      };
    };

  };
in
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
        websecure = {
          address = ":443";
          # We keep TLS generic here; router will say which certResolver to use
          http = {
            tls = { };
          };
          # Trust forwarded headers from local network
          forwardedHeaders = {
            trustedIPs = [
              "192.168.1.0/24"
              "127.0.0.1/32"
            ];
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
            };
          };
        };
      };
      api = {
        dashboard = true;
        insecure = true; # turn off once it's all working
      };
    };
    dynamicConfigOptions = lib.recursiveUpdate autoTraefikConfig manualTraefikConfig;
  };

  # systemd: load CF token env file correctly
  systemd.services.traefik.serviceConfig = {
    # the secret file itself must contain lines like:
    # CF_DNS_API_TOKEN=supersecrettoken
    EnvironmentFile = [ config.sops.secrets.CF_DNS_API_TOKEN.path ];
  };
}
