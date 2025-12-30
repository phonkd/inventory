{
  traefik = [
    { name = "pve"; host = "pve.segglaecloud.phonkd.net"; serviceUrl = "https://192.168.1.46:8006"; icon = "si:proxmox"; category = "Private"; title = "Proxmox"; }
    { name = "oldblac-pve"; host = "oldblac.int.phonkd.net"; serviceUrl = "https://192.168.1.47:8006"; category = "Private"; }
    { name = "vaultwarden"; host = "vw.w.phonkd.net"; serviceUrl = "http://192.168.1.121:8000"; icon = "si:vaultwarden"; category = "Public"; title = "Bitwarden"; }
    { name = "immich"; host = "immich.w.phonkd.net"; serviceUrl = "http://192.168.1.121:2283"; icon = "si:immich"; category = "Public"; title = "Photos"; }
    { name = "auth"; host = "auth.segglaecloud.phonkd.net"; serviceUrl = "http://192.168.1.123:8123"; category = "Private"; }
    { name = "filestash"; host = "filestash.w.phonkd.net"; serviceUrl = "http://localhost:8334"; category = "Public"; }
    { name = "collabora"; host = "collabora.int.phonkd.net"; serviceUrl = "http://localhost:9980"; category = "Public"; }
    { name = "s3"; host = "public.s3.w.phonkd.net"; serviceUrl = "http://127.0.0.1:3902"; category = "Public"; }
  ];
  teleport = [
    { name = "paperless"; uri = "http://localhost:28981"; publicHost = "paperless.teleport.phonkd.net"; icon = "si:paperlessngx"; category = "Private"; title = "Paperless"; }
    { name = "spawner-argo"; uri = "http://localhost:30080"; publicHost = "spawner-argo.teleport.phonkd.net"; icon = "si:argo"; category = "Private"; title = "ArgoCD"; }
    { name = "grafana"; uri = "http://localhost:3000"; publicHost = "grafana.teleport.phonkd.net"; icon = "si:grafana"; category = "Private"; title = "Grafana"; }
    { name = "syncthing"; uri = "http://localhost:8384"; publicHost = "syncthing.teleport.phonkd.net"; icon = "si:syncthing"; category = "Private"; title = "Syncthing"; }
    { name = "s3"; uri = "http://localhost:3909"; category = "Private"; }
    { name = "zyxel"; uri = "https://192.168.1.1"; category = "Private"; }
    { name = "oldblac"; uri = "https://192.168.1.47:8006"; category = "Private"; }
    { name = "kuma"; uri = "http://unknown-backend"; publicHost = "kuma.teleport.phonkd.net"; icon = "si:kuma"; category = "Private"; title = "Kuma"; }
  ];
  external = [
    { name = "Cloudflare"; url = "https://dash.cloudflare.com/"; icon = "si:cloudflare"; category = "Public"; }
    { name = "hetzner"; url = "https://accounts.hetzner.com/login/"; icon = "si:hetzner"; category = "Public"; }
    { name = "Clips"; url = "https://share.w.phonkd.net/"; icon = "si:airplayvideo"; category = "Public"; }
    { name = "OpenWrt"; url = "http://192.168.1.3"; icon = "si:openwrt"; category = "Private"; }
  ];
}
