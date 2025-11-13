# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  config,
  pkgs,
  lib,
  ...
}:

{
  networking.interfaces.ens18.ipv4.addresses = [
    {
      address = "192.168.1.123";
      prefixLength = 24;
    }
  ];
  networking.defaultGateway = "192.168.1.1";
  networking.nameservers = [
    "1.1.1.1"
  ];
  networking.hostName = "123-segglaecloud"; # Define your hostname.
  networking.networkmanager.dhcp = "internal";
  # Groups:
  #programs.ssh.startAgent = true; #ssh-agent
  networking.firewall.allowedTCPPorts = [
    80
    443
    22
  ];
}
