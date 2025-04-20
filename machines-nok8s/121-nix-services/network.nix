# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  networking.interfaces.ens18.ipv4.addresses = [ {
      address = "192.168.1.121";
      prefixLength = 24;
  } ];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [ "192.168.1.3" "192.168.1.1" ];
  networking.hostName = "nixos-services"; # Define your hostname.
  networking.networkmanager.dhcp = "internal";
  # Groups:
  #programs.ssh.startAgent = true; #ssh-agent
  networking.firewall.allowedTCPPorts = [80 443 8222];
  networking.firewall.allowedUDPPorts = [8222];
  networking.interfaces.ens18.ipv4.routes = [
    {
        address = "192.168.90.0";
        prefixLength = 24;
        via = "192.168.1.3";
    }
    ];
}
