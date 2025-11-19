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
  networking.firewall.allowedUDPPorts = [
    # 8472 # k3s, flannel: required if using multi-node for inter-node networking
  ];
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
        values = {
          server = {
            service = {
              type = "NodePort";
              nodePortHttp = 30080;
            };
            insecure = true;
          };
          # configs = {
          #   cm = {
          #     url = "https://spawner-argo.teleport.phonkd.net";
          #   };
          # };
        };
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
