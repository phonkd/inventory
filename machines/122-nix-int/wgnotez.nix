{ config, pkgs, ... }:

{
  networking.wireguard.interfaces = {
    wg0 = {
      # Server private key (generate with: wg genkey)
      privateKeyFile = "/etc/wireguard/wg0.key";
      listenPort = 51820;

      ips = [ "10.8.0.1/24" ];

      # Add peers here (clients)
      peers = [
        {
          # 8a
          publicKey = "CMi3+fJbhPHWw3TDKwe6fxxIhE6XlWN1SIwi3HIBcEM=";
          allowedIPs = [ "10.8.0.2/32" ];
        }
        {
          # mac
          publicKey = "dyG0qeNVNZGZkENa14nWbazv7EHoybXO1IcgHVu6EzA=";
          allowedIPs = [ "10.8.0.3/32" ];
        }
      ];
    };
  };

  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  };

  # Optional: enable NAT if you want clients to reach the internet
  networking.nat = {
    enable = true;
    externalInterface = "ens18"; # replace with your public interface
    internalInterfaces = [ "wg0" ];
  };
}
