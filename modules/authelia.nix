{
  config,
  pkgs,
  lib,
  ...
}:

{
  phonkds.modules.authelia = {
    ip = "127.0.0.1";
    port = 9091;
    dashboard.enable = true;
    traefik = {
      enable = true;
      domain = "auth.w.phonkd.net";
      ipfilter = false;
    };
  };
  sops.secrets.authelia_jwt_secret = {
    sopsFile = ./global-secrets/authelia-secret.yaml;
    owner = "authelia-main";
  };
  sops.secrets.authelia_session_secret = {
    sopsFile = ./global-secrets/authelia-secret.yaml;
    owner = "authelia-main";
  };
  sops.secrets.authelia_storage_encryption_key = {
    sopsFile = ./global-secrets/authelia-secret.yaml;
    owner = "authelia-main";
  };
  sops.secrets.authelia_users_database = {
    sopsFile = ./global-secrets/authelia-secret.yaml;
    owner = "authelia-main";
  };

  services.authelia.instances.main = {
    enable = true;
    secrets = {
      jwtSecretFile = config.sops.secrets.authelia_jwt_secret.path;
      sessionSecretFile = config.sops.secrets.authelia_session_secret.path;
      storageEncryptionKeyFile = config.sops.secrets.authelia_storage_encryption_key.path;
    };
    settings = {
      theme = "dark";
      default_2fa_method = "totp";
      server.address = "127.0.0.1:9091";
      # server = {
      #   host = "127.0.0.1";
      #   port = 9091;
      # };

      log = {
        level = "debug";
      };

      totp = {
        issuer = "auth.w.phonkd.net";
      };

      authentication_backend = {
        file = {
          path = config.sops.secrets.authelia_users_database.path;
        };
      };
      definitions.network.internal = [ "192.168.1.0/24" ];

      access_control = {
        default_policy = "deny";
        rules = [
          # Rules for the Authelia portal itself
          {
            domain = "auth.w.phonkd.net";
            policy = "bypass";
          }
          {
            domain = "*.int.w.phonkd.net";
            policy = "one_factor";
            networks = [ "internal" ];
          }
          {
            domain = "*.w.phonkd.net";
            policy = "bypass";
            networks = [ "internal" ];
          }
          # Example rule: Allow everyone (who is authenticated) to access everything else
          {
            domain = "*.w.phonkd.net";
            policy = "two_factor";
          }
        ];
      };

      session = {
        domain = "w.phonkd.net";
      };

      storage = {
        local = {
          path = "/var/lib/authelia-main/db.sqlite3";
        };
      };

      notifier = {
        filesystem = {
          filename = "/var/lib/authelia-main/notification.txt";
        };
      };
    };
  };
}
