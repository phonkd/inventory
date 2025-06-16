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
                    title = "Public";
                    sites = [
                      { title = "Bitwarden"; url = "https://vw.w.phonkd.net/"; icon = "si:vaultwarden"; }
                      { title = "Grafana"; url = "https://teleport.phonkd.net/web/launch/kube-prom-stack-grafana-monit-nix-k8s.teleport.phonkd.net/teleport.phonkd.net/kube-prom-stack-grafana-monit-nix-k8s.teleport.phonkd.net"; icon = "si:grafana"; }
                      { title = "Cloudflare";url = "https://dash.cloudflare.com/"; icon = "si:cloudflare"; }
                      { title = "hetzner"; url = "https://accounts.hetzner.com/login/"; icon = "si:hetzner"; }
                      { title = "Clips";   url = "https://share.w.phonkd.net/"; icon = "si:airplayvideo"; }
                      { title = "Photos";   url = "https://immich.w.phonkd.net/"; icon = "si:immich"; }
                    ];
                  }
                  {
                    type = "monitor";
                    cache = "1m";
                    title = "Private";
                    sites = [
                      { title = "Proxmox";    url = "https://pve.int.phonkd.net/"; icon = "si:proxmox"; }
                      { title = "OpenWrt";       url = "http://192.168.1.3"; icon = "si:openwrt"; }
                      { title = "Paperless";      url = "https://paperless.teleport.phonkd.net"; icon = "si:paperlessngx"; }
                      { title = "ArgoCD"; url = "https://teleport.phonkd.net/web/launch/argocd-server-http-argocd-nix-k8s.teleport.phonkd.net/teleport.phonkd.net/argocd-server-http-argocd-nix-k8s.teleport.phonkd.net"; icon = "si:argo"; }
                      { title = "Grafana"; url = "https://teleport.phonkd.net/web/launch/kube-prom-stack-grafana-monit-nix-k8s.teleport.phonkd.net/teleport.phonkd.net/kube-prom-stack-grafana-monit-nix-k8s.teleport.phonkd.net"; icon = "si:grafana"; }
                      { title = "Syncthing"; url = "https://teleport.phonkd.net/web/launch/syncthing.teleport.phonkd.net/teleport.phonkd.net/syncthing.teleport.phonkd.net"; icon = "si:syncthing"; }
                    ];
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
