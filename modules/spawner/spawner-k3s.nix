# Auto-generated using compose2nix v0.3.1.
{
  config,
  pkgs,
  lib,
  ...
}:
{
  networking.firewall.allowedTCPPorts = [
    6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
    # 2379 # k3s, etcd clients: required if using a "High Availability Embedded etcd" configuration
    # 2380 # k3s, etcd peers: required if using a "High Availability Embedded etcd" configuration
  ];
  sops.secrets."data/keys.txt" = {
    sopsFile = ./ksops-secret.enc.yaml;
    format = "yaml";
    owner = "root";
    #key = "data";
  };
  sops.templates = {
    "juan" = {
      content = ''
        apiVersion: v1
        kind: Secret
        metadata:
          name: argocd-sops-age-key
          namespace: argocd
        type: Opaque
        data:
          keys.txt: ${config.sops.placeholder."data/keys.txt"}
      '';
    };
  };

  services.k3s = {
    enable = true;
    role = "server";

    extraFlags = toString [
      "--disable=traefik" # Disable built-in Traefik to avoid conflicts with system Traefik
      # "--debug" # Optionally add additional args to k3s
    ];

    autoDeployCharts = {
      cluster-api-operator = {
        name = "cluster-api-operator";
        repo = "https://kubernetes-sigs.github.io/cluster-api-operator";
        version = "0.24.0";
        hash = "sha256-7pYY0Y/gaJH50YVdBU36uYCf0N0eOXKRyxsoFZdVp74";
        # hash = lib.fakeHash;
        createNamespace = true;
        targetNamespace = "capi-operator-system";

        values = {
          configSecret = {
            name = "cluster-api-operator-config";
            namespace = "capi-operator-system2";
          };
        };
      };

      cert-manager = {
        name = "cert-manager";
        repo = "oci://quay.io/jetstack/charts/cert-manager";
        version = "v1.19.1";
        hash = "sha256-9ypyexdJ3zUh56Za9fGFBfk7Vy11iEGJAnCxUDRLK0E=";
        # hash = lib.fakeHash;

        values = {
          installCRDs = true;
        };

        createNamespace = true;
        targetNamespace = "cert-manager";
      };

      argocd = {
        name = "argo-cd";
        repo = "https://argoproj.github.io/argo-helm";
        version = "9.1.3";
        hash = "sha256-OG74wEZuXyqT5S98lhj/E+t+KScJZycVWeLORPs8J7I=";
        createNamespace = true;
        targetNamespace = "argocd";

        values = {
          server = {
            service = {
              type = "NodePort";
              nodePortHttp = 30080;
            };
            insecure = true;
          };

          configs = {
            cm = {
              url = "https://spawner-argo.teleport.phonkd.net";
              "kustomize.buildOptions" = "--enable-alpha-plugins --enable-exec";
              "exec.enabled" = true;
            };
            params = {
              "server.insecure" = "true";
            };
          };

          repoServer = {
            volumes = [
              {
                name = "custom-tools";
                emptyDir = { };
              }
              {
                name = "sops-age";
                secret = {
                  secretName = "argocd-sops-age-key";
                };
              }
            ];

            env = [
              {
                name = "XDG_CONFIG_HOME";
                value = "/home/argocd/.config";
              }
              {
                name = "SOPS_AGE_KEY_FILE";
                value = "/home/argocd/.config/sops/age/keys.txt";
              }
            ];

            initContainers = [
              {
                name = "install-ksops";
                image = "viaductoss/ksops:v4.3.3";
                command = [
                  "/bin/sh"
                  "-c"
                ];
                args = [
                  ''
                    echo "Installing KSOPS...";
                    cp ksops /custom-tools/;
                    cp kustomize /custom-tools/;
                    echo "Done.";
                  ''
                ];
                volumeMounts = [
                  {
                    mountPath = "/custom-tools";
                    name = "custom-tools";
                  }
                ];
              }
            ];

            volumeMounts = [
              # Override kustomize binary
              {
                mountPath = "/usr/local/bin/kustomize";
                name = "custom-tools";
                subPath = "kustomize";
              }

              # KSOPS binary
              {
                mountPath = "/usr/local/bin/ksops";
                name = "custom-tools";
                subPath = "ksops";
              }

              # AGE keys
              {
                mountPath = "/home/argocd/.config/sops/age";
                name = "sops-age";
              }
            ];
          };
        };
        # extraDeploy = [
        #   config.sops.templates."sops-age-secret.yaml".path
        # ];
      };
    };
    manifests = {
      ksops-secret-manifest = {
        enable = true;
        source = config.sops.templates."juan".path;
      };
      cluster-01-app = {
        enable = true;
        source = ./sel-001/argoapp.yaml;
      };
    };

    # must rebuild twice for this to work
    # manifests =
    #   let
    #     secretPath = config.sops.secrets.ksops-secret.path;
    #   in
    #   if builtins.pathExists secretPath then {
    #     ksops-secret = {
    #       manifest = secretPath;
    #     };
    #   } else {};

  };

  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "spawner-argo";
          uri = "http://localhost:30080";
          insecure_skip_verify = true;
          rewrite = {
            headers = [
              "Host: spawner-argo.teleport.phonkd.net"
            ];
          };
        }
      ];
    };
  };
}
