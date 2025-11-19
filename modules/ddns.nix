{ config, pkgs, ... }:

let
  ddnsScript = ''
    #!/usr/bin/env bash
    set -euo pipefail

    CF_EMAIL="bhonk123@gmail.com"
    CF_GLOBAL_API_KEY="$(cat ${config.sops.secrets.cfapikey.path})"
    CF_ZONE_NAME="phonkd.net"
    CF_RECORD_NAME="ddns.phonkd.net"

    # Get current public IPv4
    IP=$(curl -s https://ipinfo.io/ip)

    echo "Detected IP: ${"$"}IP"

    # --- 1. Get zone ID ---
    ZONE_ID=$(curl -s -X GET \
      "https://api.cloudflare.com/client/v4/zones?name=${"$"}{CF_ZONE_NAME}" \
      -H "X-Auth-Email: ${"$"}{CF_EMAIL}" \
      -H "X-Auth-Key: ${"$"}{CF_GLOBAL_API_KEY}" \
      -H "Content-Type: application/json" | jq -r '.result[0].id')

    if [[ "${"$"}ZONE_ID" == "null" ]]; then
      echo "ERROR: Unable to retrieve Zone ID."
      exit 1
    fi

    echo "Zone ID: ${"$"}ZONE_ID"

    # --- 2. Get DNS record ---
    RECORD_RESPONSE=$(curl -s -X GET \
      "https://api.cloudflare.com/client/v4/zones/${"$"}ZONE_ID/dns_records?name=${"$"}{CF_RECORD_NAME}" \
      -H "X-Auth-Email: ${"$"}{CF_EMAIL}" \
      -H "X-Auth-Key: ${"$"}{CF_GLOBAL_API_KEY}" \
      -H "Content-Type: application/json")

    RECORD_ID=$(echo "${"$"}RECORD_RESPONSE" | jq -r '.result[0].id')
    CURRENT_IP=$(echo "${"$"}RECORD_RESPONSE" | jq -r '.result[0].content')

    if [[ "${"$"}RECORD_ID" == "null" ]]; then
      echo "ERROR: DNS record ${"$"}CF_RECORD_NAME not found!"
      exit 1
    fi

    echo "Cloudflare has: ${"$"}CURRENT_IP"

    # --- 3. Update only when needed ---
    if [[ "${"$"}CURRENT_IP" == "${"$"}IP" ]]; then
      echo "IP unchanged. No update."
      exit 0
    fi

    echo "Updating ${"$"}CF_RECORD_NAME → ${"$"}IP"

    UPDATE=$(curl -s -X PUT \
      "https://api.cloudflare.com/client/v4/zones/${"$"}ZONE_ID/dns_records/${"$"}RECORD_ID" \
      -H "X-Auth-Email: ${"$"}{CF_EMAIL}" \
      -H "X-Auth-Key: ${"$"}{CF_GLOBAL_API_KEY}" \
      -H "Content-Type: application/json" \
      --data "{ \"type\": \"A\", \"name\": \"${"$"}CF_RECORD_NAME\", \"content\": \"${"$"}IP\", \"ttl\": 120, \"proxied\": false }")

    if echo "${"$"}UPDATE" | jq -e '.success' >/dev/null; then
      echo "SUCCESS: DNS updated to ${"$"}IP"
    else
      echo "FAILED updating DNS!"
      echo "${"$"}UPDATE"
      exit 1
    fi
  '';
in
{
  # Install dependencies
  environment.systemPackages = with pkgs; [
    curl
    jq
  ];

  # Install the script
  environment.etc."local/bin/cloudflare-ddns.sh" = {
    text = ddnsScript;
    mode = "0755";
  };

  # Cron job every 15 minutes
  services.cron = {
    enable = true;
    systemCronJobs = [
      "*/15 * * * * root /etc/local/bin/cloudflare-ddns.sh >/dev/null 2>&1"
    ];
  };

  # Your existing SOPS secret
  sops.secrets.cfapikey = { };
}
