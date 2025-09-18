{ config, pkgs, lib, ... }:
{
  environment.etc."keycloak-database-pass".text = "PWD";
  services.keycloak = {
    enable = true;
    settings = {
      hostname = "auth.segglaecloud.phonkd.net";
      http-enabled = true;
      hostname-strict-https = false;
      proxy-headers = "xforwarded";
      proxy-trusted-addresses = "192.168.1.123";
      http-port = 8123;
    };
    initialAdminPassword = "sml12345";
    database.passwordFile = "/etc/keycloak-database-pass";
    realmFiles = [
      ./segglaecloud.json
    ];
  };
}
