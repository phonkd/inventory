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
            traefik = {
              enable = lib.mkEnableOption "Traefik Integration"; # Good practice to have a toggle!

              ip = lib.mkOption { type = t.str; };
              port = lib.mkOption { type = t.int; };
              domain = lib.mkOption { type = t.str; };

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
          };
        }
      )
    );
  };
}
