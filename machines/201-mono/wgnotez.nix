{ config, pkgs, ... }:

{
  networking.wireguard.interfaces = {
    wg0 = {
      # Server private key (generate with: wg genkey)
      # # 1. Move into the directory
      # cd /etc/wireguard/

      # # 2. Set umask to 077 (makes files readable only by the owner)
      # # and generate the key in one go
      # (umask 077; wg genkey > private.key)

      # # 3. Generate the public key from that private key
      # wg pubkey < private.key > public.key
      privateKeyFile = "/etc/wireguard/private.key";
      listenPort = 51820;

      ips = [ "10.8.0.1/24" ];

      # Add peers here (clients)
      peers = [
        {
          publicKey = "9xiKWRgAU3vE17FpOsKhgzeoCH/UmLtlSg/ZSG2q6n0=";
          # The internal IP assigned to this specific client
          allowedIPs = [ "10.8.0.2/32" ];
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
