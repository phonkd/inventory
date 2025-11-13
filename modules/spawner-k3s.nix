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
      # "--debug" # Optionally add additional args to k3s
    ];
  };
  services.k3s.autoDeployCharts = {
    cluster-api-operator = {
      name = "cluster-api-operator";
      repo = "https://kubernetes-sigs.github.io/cluster-api-operator";
      version = "0.24.0";
      hash = "sha256-0000000000000000000000000";
      createNamespace = true;
      targetNamespace = "capi-operator-system";
      values = {
        configSecret = {
          name = "cluster-api-operator-config";
          namespace = "capi-operator-system";
        };
      };
      # extraDeploy = [
      #   ../k8s-capi-pve-provider.yaml
      # ];
    };
    cert-manager = {
      name = "cert-manager";
      repo = "oci://quay.io/jetstack/charts/cert-manager";
      version = "v1.19.1";
      hash = "sha256-0000000000000000000000000";
      values = {
        installCRDs = true;
      };
      createNamespace = true;
      targetNamespace = "cert-manager";
    };
  };
}
