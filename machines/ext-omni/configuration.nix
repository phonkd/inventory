{ lib, config, ... }:
{
  imports = [
    #/etc/nixos/configuration.nix
    ./sops.nix
    ./hardware-configuration.nix
    ../../modules/auto-update.nix
  ];

  users.users."phonkd".openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDg0PjpVeFevKuUq7ZVAhL0fySgOomRT/SZ6jWFxfv0q06KgwLSInwXFZDIUNN9c2Uz6qgJvh/xZ9UQfuoYwBMwUDt89hhplZDeFG+0kTxPRyjKrtcOXefM2ne4eI93kvJfU5+SaxXs3GF5oChoml4Wwub74CVLWIlKTvA7YLEKzBffEJ4ypO97YTR734Cd1vHsIOVFylftIpe0n/oA7o3Bu+GSRwfW4cM9nbYcumydwyrA9osrQ6dLNFCJ6DSvBY65j9eU/wGEObmch645f+hAm1ROZxoUYtVBQjSNheYNIUAxjXDbHd/eA3TjG6qGfUSbFu1gitQBLY4M+YUmT+r/IjD3XBFwFCED3G/TKKBjKubCMk0yxegCa+JZt+HzSbRTILgFv0eC+DvZBgMHMx0RjefvOJY6mCWtwwYRULp+2ulls6RTX2F3aEEKO0+/9YxTfzvwE1zFLAVxNpCg25f35eWuBdIJD/2K42Krbe2xrGDJdFhRtpT1uoq0qGHreIk= phonkd@Eliss-MacBook-Pro.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF5N1CEZp7YnD7m4Jy4+KKH1rVChi+0dNhnxBVjRGX1o phonkd@blac"
    # content of authorized_keys file
    # note: ssh-copy-id will add user@your-machine after the public key
    # but we can remove the "@your-machine" part
  ];
  services.openssh = {
    enable = true;
    ports = [ 5432 ];
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
      AllowUsers = [ "phonkd" ];
    };
  };
  time.timeZone = lib.mkDefault "Europe/Zurich";
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  services.xserver.xkb = lib.mkDefault {
    layout = "ch";
    variant = "";
  };
  console.keyMap = lib.mkDefault "sg";
  users.users.phonkd = {
    isNormalUser = true;
    description = "phonkd";
    extraGroups = [
      "networkmanager"
      "wheel"
      "docker"
    ];
  };
  security.sudo.wheelNeedsPassword = false;
  sops.age.keyFile = "/home/phonkd/.config/sops/age/keys.txt";
  sops.defaultSopsFile = ./secrets/secret.yaml;
  virtualisation.docker.enable = true;
  system.stateVersion = lib.mkForce "25.11";
  system.autoUpgrade = {
    flake = lib.mkForce "github:phonkd/inventory?dir=machines#ext-omni";
    dates = lib.mkForce "weekly";
  };
  sops.secrets.discord_webhook_url = lib.mkForce {
    sopsFile = ./secrets/secret.yaml;
  };

  # --- Sops secrets for Omni ---
  sops.secrets.cloudflare_api_key = {
    sopsFile = ./secrets/secret.yaml;
    # ACME needs the file in KEY=VALUE format
    # The sops secret should contain just the token value.
    # We use a script to write it in the format ACME expects.
  };

  sops.secrets.omni_etcd_encryption_key = {
    sopsFile = ./secrets/secret.yaml;
    owner = "omni";
    group = "omni";
    path = "/var/lib/omni/omni.asc";
  };

  # Write the Cloudflare env file for ACME from the sops secret
  systemd.services.omni-acme-env = {
    description = "Generate ACME Cloudflare env file from sops secret";
    wantedBy = [ "multi-user.target" ];
    before = [ "acme-${config.services.omni.domain}.service" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      mkdir -p /run/omni
      echo "CF_DNS_API_TOKEN=$(cat ${config.sops.secrets.cloudflare_api_key.path})" > /run/omni/cloudflare-env
      chmod 600 /run/omni/cloudflare-env
    '';
  };

  # --- Omni service ---
  services.omni = {
    enable = true;

    # TODO: generate a stable UUID for this instance and put it here
    accountId = "95374b5c-6d9e-46d7-8987-5ce233d77fdc";

    domain = "omni.phonkd.net";

    tls.acme = {
      enable = true;
      email = "bhonk123@gmail.com";
      cloudflareApiKeyFile = "/run/omni/cloudflare-env";
    };

    privateKeySource = "file:///var/lib/omni/omni.asc";

    # TODO: set to the public IP of this machine
    wireguard.advertisedAddr = "168.119.153.133:50180";

    initialUsers = [ "phonkd@phonkd.net" ];

    # Choose one auth provider:
    auth.auth0 = {
      enable = true;
      url = "https://dev-fm5efw0ycjja53tl.eu.auth0.com";
      clientId = "jM0SPMUgG2MMTNjlnWvZsoi7mFc9Wfdu";
      clientSecret = "";
    };

    storage = {
      kind = "etcd";
      etcd.embedded = true;
    };
  };

}
