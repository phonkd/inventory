{ config, lib, ... }:

let
  inherit (lib) mkAfter;

  authelia = "authelia-phonkd";
  domain = "phonkd.net"
in
{
  services = {
    authelia.instances.phonkd = {
      enable = true;
      settings = {
        theme = "auto";
        authentication_backend.ldap = {
          address = "ldap://localhost:3890";
          base_dn = "dc=phonkd,dc=net";
          users_filter = "(&({username_attribute}={input})(objectClass=person))";
          groups_filter = "(member={dn})";
          user = "uid=authelia,ou=people,dc=phonkd,dc=net";
        };
        access_control = {
          default_policy = "deny";
          # We want this rule to be low priority so it doesn't override the others
          rules = mkAfter [
            {
              domain = "*.${domain}";
              policy = "one_factor";
            }
          ];
        };
        storage.postgres = {
          address = "unix:///run/postgresql";
          database = authelia;
          username = authelia;
        };
        session = {
          redis.host = "/var/run/redis-haddock/redis.sock";
          cookies = [
            {
              domain = "${domain}";
              authelia_url = "https://auth.${domain}";
              # The period of time the user can be inactive for before the session is destroyed
              inactivity = "1M";
              # The period of time before the cookie expires and the session is destroyed
              expiration = "3M";
              # The period of time before the cookie expires and the session is destroyed
              # when the remember me box is checked
              remember_me = "1y";
            }
          ];
        };
        # notifier.smtp = {
        #   address = "smtp://smtp.mailbox.org:587";
        #   username = "poperigby@mailbox.org";
        #   sender = "haddock@mailbox.org";
        # };
        log.level = "info";
        identity_providers.oidc = {
          # https://www.authelia.com/integration/openid-connect/openid-connect-1.0-claims/#restore-functionality-prior-to-claims-parameter
          claims_policies = {
            karakeep.id_token = [ "email" ];
            opkssh.id_token = [ "email" ];

          };
          cors = {
            endpoints = [ "token" ];
            allowed_origins_from_client_redirect_uris = true;
          };
          authorization_policies.default = {
            default_policy = "one_factor";
            rules = [
              {
                policy = "deny";
                subject = "group:lldap_strict_readonly";
              }
            ];
          };
        };
        webauthn = {
          enable_passkey_login = true;
        };
        # Necessary for Caddy integration
        # See https://www.authelia.com/integration/proxies/caddy/#implementation
        server.endpoints.authz.forward-auth.implementation = "ForwardAuth";
      };
      # Templates don't work correctly when parsed from Nix, so our OIDC clients are defined here
      settingsFiles = [ ./oidc_clients.yaml ];
      secrets = with config.sops; {
        jwtSecretFile = secrets."authelia/jwt_secret".path; # podman run --rm authelia/authelia:latest authelia crypto rand --length 64 --charset alphanumeric
        # oidcIssuerPrivateKeyFile = secrets."authelia/jwks".path;
        # oidcHmacSecretFile = secrets."authelia/hmac_secret".path;
        # sessionSecretFile = secrets."authelia/session_secret".path;
        # storageEncryptionKeyFile = secrets."authelia/storage_encryption_key".path;
      };
      environmentVariables = with config.sops; {
        AUTHELIA_AUTHENTICATION_BACKEND_LDAP_PASSWORD_FILE =
          secrets."authelia/lldap_authelia_password".path;
        AUTHELIA_NOTIFIER_SMTP_PASSWORD_FILE = secrets.smtp-password_authelia.path;
      };
    };
    caddy = {
      virtualHosts."auth.haddock.cc".extraConfig = ''
        reverse_proxy :9091
      '';
      # A Caddy snippet that can be imported to enable Authelia in front of a service
      # Taken from https://www.authelia.com/integration/proxies/caddy/#subdomain
      extraConfig = ''
        (auth) {
            forward_auth :9091 {
                uri /api/authz/forward-auth
                copy_headers Remote-User Remote-Groups Remote-Email Remote-Name
            }
        }
      '';
    };
  };

  # Give Authelia access to the Redis socket
  users.users.${authelia}.extraGroups = [ "redis-haddock" ];

  systemd.services.${authelia} =
    let
      dependencies = [
        "lldap.service"
        "postgresql.service"
        "redis-haddock.service"
      ];

    in
    {
      # Authelia requires LLDAP, PostgreSQL, and Redis to be running
      after = dependencies;
      requires = dependencies;
      # Required for templating
      serviceConfig.Environment = "X_AUTHELIA_CONFIG_FILTERS=template";
    };

  sops.secrets = {
    "haddock/authelia/hmac_secret".owner = authelia;
    "haddock/authelia/jwks".owner = authelia;
    "haddock/authelia/jwt_secret".owner = authelia;
    "haddock/authelia/session_secret".owner = authelia;
    "haddock/authelia/storage_encryption_key".owner = authelia;
    # The password for the `authelia` LLDAP user
    "haddock/authelia/lldap_authelia_password".owner = authelia;
    smtp-password_authelia = {
      owner = authelia;
      key = "common/users/cassidy/email/password";
    };
  };
}
