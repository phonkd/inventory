# modules/my-apps.nix
{ lib, ... }:
let
  t = lib.types;
in
{
  options.phonkds.modules = lib.mkOption {
    description = "Central definition for all my homelab apps";
    default = { };
    type = t.attrsOf (
      t.submodule (
        { config, ... }:
        {
          options = {
            # We group all traefik settings here
            ip = lib.mkOption { type = t.str; };
            port = lib.mkOption { type = t.int; };
            traefik = {
              enable = lib.mkOption {
                type = t.bool;
                default = false;
                description = "Enable Traefik Integration";
              };

              domain = lib.mkOption {
                type = t.nullOr t.str;
                default = null;
              };

              auth = lib.mkOption {
                type = t.bool;
                default = false;
              };

              ipfilter = lib.mkOption {
                type = t.bool;
                default = false;
              };
              extraMiddlewares = lib.mkOption {
                type = t.listOf t.str;
                default = [ ];
                description = "List of extra middleware names to attach to this router";
              };
              scheme = lib.mkOption {
                type = t.str;
                default = "http";
                description = "Protocol scheme (http, https, h2c)";
              };
              # NEW: Allow selecting a specific transport (e.g. "insecureTransport")
              transport = lib.mkOption {
                type = t.nullOr t.str;
                default = null;
                description = "Custom server transport to use";
              };
            };
            path = lib.mkOption {
              type = t.nullOr t.str;
              default = null;
              description = "Http path";
            };
            teleport = {
              enable = lib.mkOption {
                type = t.bool;
                default = false;
                description = "Enable teleport app service for this app";
              };
              name = lib.mkOption {
                type = t.nullOr t.str;
                default = null;
                description = "Name for the app that will spawn in teleport";
              };
              rewriteHeaders = lib.mkOption {
                type = t.listOf t.str;
                default = [ ];
                description = "List of rewrite headers for the teleport app (e.g. ['Host: myapp.teleport.phonkd.net'])";
              };
              insecure = lib.mkOption {
                type = t.bool;
                default = false;
                description = "Enables insecure";
              };
              scheme = lib.mkOption {
                type = t.str;
                default = "http";
                description = "Protocol scheme (http, https)";
              };
            };
            dashboard = {
              enable = lib.mkOption {
                type = t.bool;
                default = false;
                description = "Whether to show this service on the dashboard";
              };
              icon = lib.mkOption {
                type = t.nullOr t.str;
                default = null;
                description = "Custom icon for the dashboard (e.g. 'my-icon.png'). Defaults to '<app-name>.png' if null.";
              };
              link = lib.mkOption {
                type = t.nullOr t.str;
                default = null;
                description = "Custom link for the dashboard. Defaults to 'https://<traefik.domain>' if null.";
              };
            };
          };
        }
      )
    );
  };
}
