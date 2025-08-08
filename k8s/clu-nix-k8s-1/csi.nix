# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
   # Proxmox CSI
  services.kubernetes = {
    kubelet.extraOpts = "--fail-swap-on=false --node-labels=topology.kubernetes.io/region=idk --node-labels=topology.kubernetes.io/zone=wamluck";
  };
  # packages for administration tasks
  environment.systemPackages = with pkgs; [
    kompose
    kubectl
    kubernetes
    openiscsi
  ];
  services.kubernetes.proxy.enable = false;
  #networking.usePredictableInterfaceNames = false;
  # systemd.tmpfiles.rules = [
  #     "D /opt/cni/bin 0755 root root -"
  #   ];
}
