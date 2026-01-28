{
  config,
  pkgs,
  lib,
  ...
}:
let
  isVM = lib.elem "vm" config.label.labels;

  hostname = config.networking.hostName;

  # Discord notification script for failures
  notifyFailure = pkgs.writeShellScript "notify-upgrade-failure" ''
    WEBHOOK_URL=$(cat ${config.sops.secrets.discord_webhook_url.path})
    TIMESTAMP=$(${pkgs.coreutils}/bin/date '+%Y-%m-%d %H:%M:%S')

    ${pkgs.curl}/bin/curl -H "Content-Type: application/json" \
      -d "{\"embeds\":[{\"title\":\"❌ NixOS Update Failed\",\"description\":\"Auto-upgrade failed on **${hostname}**\",\"color\":15158332,\"fields\":[{\"name\":\"Hostname\",\"value\":\"${hostname}\",\"inline\":true},{\"name\":\"Time\",\"value\":\"$TIMESTAMP\",\"inline\":true}],\"footer\":{\"text\":\"NixOS Auto-Update\"}}]}" \
      "$WEBHOOK_URL"
  '';
in
{
  config = lib.mkIf isVM {
    # Sops secret for Discord webhook
    sops.secrets.discord_webhook_url = {
      sopsFile = ../modules/global-secrets/secret.yaml;
    };

    system.autoUpgrade = {
      enable = true;
      flake = "github:phonkd/inventory?dir=machines#${config.networking.hostName}";
      dates = "daily";
      randomizedDelaySec = "1h";
      allowReboot = false;
      flags = [
        "--refresh"
      ];
    };

    # Send notification only on failure
    systemd.services.nixos-upgrade = {
      serviceConfig = {
        ExecStopPost = pkgs.writeShellScript "check-upgrade-status" ''
          if [ "$SERVICE_RESULT" != "success" ]; then
            ${notifyFailure}
          fi
        '';
      };
    };
  };
}
