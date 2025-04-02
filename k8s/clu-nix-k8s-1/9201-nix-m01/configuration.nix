# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib,... }:

{
  k8s.kubeMasterIP = "192.168.90.201";
  #k8s.kubeMasterHostname = "mykube.local";
  #k8s.kubeMasterAPIServerPort = 6443;

  imports =
    [ # Include the results of the hardware scan.
      ../../../base/base.nix
      ../base-k8s-master.nix
      ../../../base/base-hardware-configuration.nix
      ./network.nix
    ];
}
