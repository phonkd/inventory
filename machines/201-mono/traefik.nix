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

    # services.traefik.dynamicConfigOptions.http = {
    #   routers = {

    #   };
    #   services = { };
    # };

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
          authelia = {
            rule = "Host(`auth.w.phonkd.net`)";
            entryPoints = [ "websecure" ];
            service = "authelia-service";
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
          easyeffects-router = {
            rule = "Host(`easyeffects.w.phonkd.net`)";
            service = "easyeffects-service";
            entryPoints = [ "websecure" ];
            middlewares = [
              "ip-filter"
              "vnc-root-rewrite"
            ];
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
          easyeffects-service = {
            loadBalancer = {
              serversTransport = "insecureTransport";
              servers = [
                { url = "http://192.168.1.203:8085"; }
              ];
            };
          };

          authelia-service = {
            loadBalancer = {
              servers = [
                { url = "http://127.0.0.1:9091"; }
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
              "10.8.0.0/16"
            ];
          };
          forward-auth = {
            forwardAuth = {
              address = "http://127.0.0.1:9091/api/verify?rd=https://auth.w.phonkd.net/";
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
      };
    };
  };

  # systemd: load CF token env file correctly
  systemd.services.traefik.serviceConfig = {
    # the secret file itself must contain lines like:
    # CF_DNS_API_TOKEN=supersecrettoken
    EnvironmentFile = [ config.sops.secrets.CF_DNS_API_TOKEN.path ];
  };
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "traefik";
          uri = "http://localhost:8080/dashboard/";
          insecure_skip_verify = true;
        }
      ];
    };
  };
}
