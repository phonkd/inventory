{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Use declarative networking with secondary IP
  networking.useDHCP = true;
  networking.interfaces.enp5s0 = {
    useDHCP = true;
    ipv4.addresses = [
      {
        address = "10.10.10.200";
        prefixLength = 24;
      }
    ];
  };

  networking.hostName = "blac";
  #networking.nameservers = [ "10.0.0.1" ];
}
