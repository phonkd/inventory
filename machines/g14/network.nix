{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Use declarative networking with secondary IP
  networking.useDHCP = true;
  networking.hostName = "g14";
  networking.nameservers = [
    "192.168.1.122"
  ];

  # Disable IPv6
  networking.enableIPv6 = false;
}
