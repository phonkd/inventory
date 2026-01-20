{
  config,
  pkgs,
  lib,
  ...
}:
let
  isVM = lib.elem "vm" config.label.labels;
  
  # Discord notification script for failures
  notifyFailure = pkgs.writeShellScript "notify-upgrade-failure" ''
    HOSTNAME=$(hostname)
    WEBHOOK_URL=$(cat ${config.sops.secrets.discord_webhook_url.path})
    
    ${pkgs.curl}/bin/curl -H "Content-Type: application/json" \
      -d "{\"embeds\":[{\"title\":\"❌ NixOS Update Failed\",\"description\":\"Auto-upgrade failed on **$HOSTNAME**\",\"color\":15158332,\"fields\":[{\"name\":\"Hostname\",\"value\":\"$HOSTNAME\",\"inline\":true},{\"name\":\"Time\",\"value\":\"$(date '+%Y-%m-%d %H:%M:%S')\",\"inline\":true}],\"footer\":{\"text\":\"NixOS Auto-Update\"}}]}" \
      "$WEBHOOK_URL"
  '';