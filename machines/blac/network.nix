{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Use declarative networking with secondary IP
  networking.useDHCP = true;
  networking.hostName = "blac";
  networking.nameservers = [
    "192.168.1.122"
    "1.1.1.1"
  ];

  # Disable IPv6
  networking.enableIPv6 = false;
}
