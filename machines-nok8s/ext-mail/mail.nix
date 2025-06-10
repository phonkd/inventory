
{ config, pkgs, lib, ... }:
let
  hashpwtmp = if builtins.pathExists config.sops.secrets."mail-secret".path then
                    config.sops.secrets."mail-secret".path
                  else
                    "/dev/null";
in
{
  sops.secrets."mail-secret" = {
    sopsFile = secrets/mail-secret.yaml;
  };

  imports = [
    (builtins.fetchTarball {
      # Pick a release version you are interested in and set its hash, e.g.
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-24.11/nixos-mailserver-nixos-24.11.tar.gz";
      # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
      # release="nixos-23.05"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
      sha256 = "05k4nj2cqz1c5zgqa0c6b8sp3807ps385qca74fgs6cdc415y3qw";
    })
  ];
  mailserver = {
    enable = true;
    fqdn = "mail.phonkd.net";
    domains = [ "phonkd.net" ];
    loginAccounts = {
      "phonkd@phonkd.net" = {
        hashedPasswordFile = hashpwtmp;
        aliases = ["test@phonkd.net" "spam@phonkd.net" "elis@phonkd.net" "info@phonkd.net" "spam2@phonkd.net" "spam3@phonkd.net"];
      };
    };
    certificateScheme = 3;
  };
  security.acme.acceptTerms = true;
  security.acme.defaults.email = "bhonk123@gmail.com";

  # calendar config:
  services.radicale = {
    enable = true;
    settings = {
      auth = {
        type = "htpasswd";
        htpasswd_filename = "${htpasswd}";
        htpasswd_encryption = "bcrypt";
      };
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts = {
      "cal.phonkd.net" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://localhost:5232/";
          extraConfig = ''
            proxy_set_header  X-Script-Name /;
            proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass_header Authorization;
          '';
        };
      };
    };
  };
  networking.firewall.allowedTCPPorts = [ 80 443 ];
}
