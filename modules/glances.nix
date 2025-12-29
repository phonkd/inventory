# Auto-generated using compose2nix v0.3.1.
{ config, pkgs, lib, ... }:
let
  servicesList = import ./services-list.nix;

  toSite = svc: {
    title = svc.title or svc.name;
    url = if svc ? host then "https://${svc.host}" else (if svc ? publicHost then "https://${svc.publicHost}" else svc.uri);
    icon = svc.icon or "si:server";
  };

  publicSites = map toSite (lib.filter (s: s.category == "Public") (servicesList.traefik ++ servicesList.teleport ++ servicesList.external));
  privateSites = map toSite (lib.filter (s: s.category == "Private") (servicesList.traefik ++ servicesList.teleport ++ servicesList.external));
in
{
  services.glance = {
    enable = true;
    settings = {
        # This expects the YAML structure directly in Nix—see next step
        server.port = 61208;
        pages = [
          {
            name = "Startpage";
            width = "slim";
            "hide-desktop-navigation" = true;
            "center-vertically" = true;
            columns = [
              {
                size = "full";
                widgets = [
                  { type = "search"; autofocus = true; }
                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Public";
                    sites = publicSites;
                  }
                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Private";
                    sites = privateSites;
                  }
                  {
                    type = "bookmarks";
                    groups = [
                      {
                        title = "General";
                        links = [
                          { title = "Nixos"; url = "https://search.nixos.org/options?channel=unstable&size=50&sort=relevance&type=packages&query="; }
                          { title = "Chatgpt"; url = "https://chatgpt.com/"; }
                          { title = "GitHub"; url = "https://github.com/phonkd/"; }
                        ];
                      }
                      {
                        title = "Entertainment";
                        links = [
                          { title = "YouTube";      url = "https://www.youtube.com/"; }
                          { title = "News";         url = "https://news.ycombinator.com/"; }
                          { title = "Monkeytype";   url = "https://monkeytype.com/"; }
                        ];
                      }
                      {
                        title = "Social";
                        links = [
                          { title = "Reddit";       url = "https://www.reddit.com/"; }
                          { title = "Twitter";      url = "https://twitter.com/"; }
                          { title = "Instagram";    url = "https://www.instagram.com/"; }
                        ];
                      }
                    ];
                  }
                ];
              }
            ];
          }
        ];
      };
  };
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "dashboard";
          uri = "http://localhost:61208";
          # insecure_skip_verify = true;
          # rewrite = {
          #   headers = [
          #     "Host: paperless.teleport.phonkd.net"
          #   ];
          # };
        }
      ];
    };
  };
}
