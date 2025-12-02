{
  config,
  pkgs,
  lib,
  ...
}:
{
  sops.secrets."mail-secret" = {
    sopsFile = ./secrets/mail-secret.yaml;
  };

  imports = [
    (builtins.fetchTarball {
      # Pick a release version you are interested in and set its hash, e.g.
      url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/nixos-25.11/nixos-mailserver-nixos-25.11.tar.gz";
      # To get the sha256 of the nixos-mailserver tarball, we can use the nix-prefetch-url command:
      # release="nixos-25.11"; nix-prefetch-url "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver/-/archive/${release}/nixos-mailserver-${release}.tar.gz" --unpack
      sha256 = "sha256:16kanlk74xnj7xgmjsj7pahy31hlxqcbv76xnsg8qbh54b0hwxgq";
    })
  ];

  mailserver = {
    enable = true;
    fqdn = "mail.phonkd.net";
    domains = [ "phonkd.net" ];

    # New in 25.11: system configuration for automated reports
    systemName = "phonkd.net Mail Server";
    systemDomain = "phonkd.net";

    # Disable deprecated protocols (default in 25.11)
    # enableImap = false;  # Port 143 disabled, use 993 (implicit TLS) instead
    # enableSubmission = false;  # Port 587 STARTTLS disabled

    # Enable modern features
    tlsrpt.enable = true; # SMTP TLS connection reports (RFC 8460)
    systemContact = "spam1@phonkd.net";
    loginAccounts = {
      "phonkd@phonkd.net" = {
        # Use the secret directly - no builtins.readFile needed!
        hashedPasswordFile = config.sops.secrets."mail-secret".path;
        aliases = [
          "test@phonkd.net"
          "spam@phonkd.net"
          "spam1@phonkd.net"
          "elis@phonkd.net"
          "info@phonkd.net"
          "spam2@phonkd.net"
          "spam3@phonkd.net"
        ];
      };
    };
    certificateScheme = 3;
    stateVersion = 3;

  };

  security.acme.acceptTerms = true;
  security.acme.defaults.email = "bhonk123@gmail.com";

  # calendar config:
  services.radicale = {
    enable = true;
    settings = {
      auth = {
        type = "htpasswd";
        htpasswd_filename = "/run/radicale/htpasswd";
        htpasswd_encryption = "bcrypt";
      };
    };
  };

  # Create htpasswd file from secret at runtime
  systemd.services.radicale = {
    serviceConfig = {
      RuntimeDirectory = "radicale";
    };
  };

  # Create htpasswd file before radicale starts (runs as root)
  systemd.services.radicale-setup = {
    description = "Setup radicale htpasswd file";
    before = [ "radicale.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /run/radicale
      echo "phonkd@phonkd.net:$(cat ${config.sops.secrets."mail-secret".path})" > /run/radicale/htpasswd
      chmod 600 /run/radicale/htpasswd
      chown radicale:radicale /run/radicale/htpasswd
    '';
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

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];
}
