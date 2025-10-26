{ config, pkgs, ... }:
{
  services.adguardhome = {
    enable = true;
    settings = {
      http = {
        # You can select any ip and port, just make sure to open firewalls where needed
        address = "127.0.0.1:4040";
      };
      dns = {
        upstream_dns = [
          # Example config with quad9
          "9.9.9.9#dns.quad9.net"
          "149.112.112.112#dns.quad9.net"
          # Uncomment the following to use a local DNS service (e.g. Unbound)
          # Additionally replace the address & port as needed
          # "127.0.0.1:5335"
        ];
      };
      filtering = {
        protection_enabled = true;
        filtering_enabled = true;

        parental_enabled = false;  # Parental control-based DNS requests filtering.
        safe_search = {
          enabled = false;  # Enforcing "Safe search" option for search engines, when possible.
        };
      };
      # The following notation uses map
      # to not have to manually create {enabled = true; url = "";} for every filter
      # This is, however, fully optional
      filters = map(url: { enabled = true; url = url; }) [
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_9.txt"  # The Big List of Hacked Malware Web Sites
        "https://adguardteam.github.io/HostlistsRegistry/assets/filter_11.txt"  # malicious url blocklist
      ];
    };
  };
  services.teleport.settings = {
    app_service = {
      enabled = true;
      apps = [
        {
          name = "adguard";
          uri = "http://localhost:4040";
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
