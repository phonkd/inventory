# Auto-generated using compose2nix v0.3.1.
{ config, pkgs, lib, ... }:
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
                    title = "Services";
                    sites = [
                      { title = "Proxmox";    url = "https://pve.int.phonkd.net/"; icon = "si:proxmox"; }
                      { title = "OpenWrt";       url = "http://192.168.1.3"; icon = "si:openwrt"; }
                      { title = "Bitwarden"; url = "https://vw.w.phonkd.net/"; icon = "si:vaultwarden"; }
                      { title = "Paperless";      url = "https://paperless.teleport.phonkd.net"; icon = "si:paperlessngx"; }
                      { title = "Cloudflare";url = "https://dash.cloudflare.com/"; icon = "si:cloudflare"; }
                      { title = "hetzner"; url = "https://accounts.hetzner.com/login/"; icon = "si:hetzner"; }
                    ];
                  }
                  {
                    type = "bookmarks";
                    groups = [
                      {
                        title = "General";
                        links = [
                          { title = "Gmail"; url = "https://mail.google.com/mail/u/0/"; }
                          { title = "Chatgpt"; url = "https://chatgpt.com/"; }
                          { title = "GitHub"; url = "https://github.com/phonkd/"; }
                        ];
                      }
                      {
                        title = "Entertainment";
                        links = [
                          { title = "YouTube";      url = "https://www.youtube.com/"; }
                          { title = "News";         url = "https://news.ycombinator.com/"; }
                          { title = "Disney+";      url = "https://www.disneyplus.com/"; }
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
          uri = "http://localhost:";
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
