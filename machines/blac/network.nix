{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Use declarative networking with secondary IP
  networking.useDHCP = false;
  networking.interfaces.enp5s0 = {
    useDHCP = true;
    ipv4.addresses = [
      {
        address = "10.10.10.4";
        prefixLength = 24;
      }
    ];
  };

  networking.hostName = "blac";
  networking.nameservers = [ "192.168.1.122" ];

  # Disable IPv6
  networking.enableIPv6 = false;
}
