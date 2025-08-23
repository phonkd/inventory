{ config, pkgs, lib, ... }:
{
  services.teleport.enable = true;
  sops.secrets.teleport_authkey = {
      owner = "root";
      key = "teleport_authkey";
  };
  services.teleport.settings = {
    version = "v3";
    teleport = {
      nodename = config.networking.hostName;
      # advertise_ip = "192.168.90.187";
      #
      auth_token = if builtins.pathExists config.sops.secrets.teleport_authkey.path then
                       builtins.readFile config.sops.secrets.teleport_authkey.path
                     else
                       "default_auth_token_placeholder";
      #auth_servers = [ "freakedyproxy.teleport.phonkd.net" ];
      proxy_server = "teleport.phonkd.net:443";
    };
    ssh_service = {
      enabled = true;
      labels = {
        #role = "client";
        type = "node";
      };
    };
    proxy_service.enabled = false;
    auth_service.enabled = false;
    ## sops key cant  be used with remote build atm
  };
}
