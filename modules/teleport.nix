{
  config,
  pkgs,
  lib,
  ...
}:
let
  # Filter apps that have teleport enabled
  teleportApps = lib.filterAttrs (name: app: app.teleport.enable or false) config.phonkds.modules;

  # Generate teleport app configurations dynamically
  autoTeleportApps = lib.mapAttrsToList (
    name: app:
    {
      name = if app.teleport.name != null then app.teleport.name else name;
      uri = "${app.teleport.scheme}://${app.ip}:${toString app.port}${toString app.path}";
      insecure_skip_verify = app.teleport.insecure;
    }
    // (lib.optionalAttrs (app.teleport.rewriteHeaders != [ ]) {
      rewrite = {
        headers = app.teleport.rewriteHeaders;
      };
    })
  ) teleportApps;
in
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
      auth_token = config.sops.secrets.teleport_authkey.path;
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
    app_service = {
      enabled = true;
      apps = autoTeleportApps;
    };
  };

}
