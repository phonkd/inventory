{ config, pkgs, ... }:
{
  sops.secrets."ocis.yaml" = {
      format = "yaml";
      sopsFile = secrets/ocis-secret.yaml;
      key = "";
      mode = "0660";
      group = "ocis";
      owner = "ocis";
  };
  ## above part is for loading config as secret
  services.ocis = {
    enable = true;
    #address = "127.0.0.1";
    url = "https://ocis.w.phonkd.net";
    configDir = "/run/secrets";
    environment = {
      OCIS_INSECURE = "true";
      CS3_ALLOW_INSECURE = "true";
      #TLS_SKIP_VERIFY_CLIENT_CERT = "true";
      OCIS_INSECURE_BACKENDS = "true";
      # IDP_ISS = "https://localhost:9200";
    };
  };
  #
  services.caddy = {
    virtualHosts."ocis.w.phonkd.net".extraConfig = ''
      reverse_proxy {
        to localhost:9200
        transport http {
          header_up Host {.reverse_proxy.upstream.host}
          tls
          tls_insecure_skip_verify
        }
      }
    '';
  };
}
