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
  ];
  sops.secrets = {
    # load the nix sops secret
    "data/keys.txt" = {
      sopsFile = ./ksops-secret.enc.yaml;
      format = "yaml";
      owner = "root";
      #key = "data";
    };
  };
  sops.templates = {
    # template exists as placeholder so secret is only decrypted after runtime
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
    ];

    autoDeployCharts = {
      # to apply changes here you need to restart k3s (ssh 192.168.1.123 sudo systemctl restart k3s)
      cluster-api-operator = {
        name = "cluster-api-operator";
        repo = "https://kubernetes-sigs.github.io/cluster-api-operator";
        version = "0.24.0";
        hash = "sha256-7pYY0Y/gaJH50YVdBU36uYCf0N0eOXKRyxsoFZdVp74";
        # hash = lib.fakeHash; # use this to optain hash
        createNamespace = true;
        targetNamespace = "capi-operator-system";

        values = {
          configSecret = {
            name = "cluster-api-operator-config";
            namespace = "capi-operator-system2"; # # dont know how it works with this
          };
        };
      };
      kubemox = {
        name = "kubemox";
        repo = "https://alperencelik.github.io/helm-charts";
        version = "0.4.1";
        #hash = "sha256-3f6f6cfb2f3e4e1e4b1e4c8e4f6f7e8e9e0f1f2f3f4f5f6f7f8f9fa0b1c2d3e4";
        hash = lib.fakeHash;

        createNamespace = true;
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
              type = "NodePort"; # node port is used for a consistent backend for the teleport agent (outside k8s). The management cluster is only accessible via teleport or directly via the vm...
              nodePortHttp = 30080;
            };
            insecure = true;
          };

          configs = {
            cm = {
              url = "https://spawner-argo.teleport.phonkd.net"; # set teleport url
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
      };
    };
    manifests = {
      ksops-secret-manifest = {
        # populates the template responsible for creating the kubernetes secret for ksops. has to be done with above template so that the secret is accessed after build time.
        enable = true;
        source = config.sops.templates."juan".path;
      };
      cluster-01-app = {
        # deploy argo app which will create the cluster under "./sel-001/" (including ugly cilium clusterresourceset job)
        enable = true;
        source = ./sel-001/argoapp.yaml;
      };
    };
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
