{ lib, ... }:
{
  imports = [
    #/etc/nixos/configuration.nix
    ./sops.nix
    ./mail.nix
    ./hardware-configuration.nix
    ../../modules/auto-update.nix
  ];

  users.users."phonkd".openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDg0PjpVeFevKuUq7ZVAhL0fySgOomRT/SZ6jWFxfv0q06KgwLSInwXFZDIUNN9c2Uz6qgJvh/xZ9UQfuoYwBMwUDt89hhplZDeFG+0kTxPRyjKrtcOXefM2ne4eI93kvJfU5+SaxXs3GF5oChoml4Wwub74CVLWIlKTvA7YLEKzBffEJ4ypO97YTR734Cd1vHsIOVFylftIpe0n/oA7o3Bu+GSRwfW4cM9nbYcumydwyrA9osrQ6dLNFCJ6DSvBY65j9eU/wGEObmch645f+hAm1ROZxoUYtVBQjSNheYNIUAxjXDbHd/eA3TjG6qGfUSbFu1gitQBLY4M+YUmT+r/IjD3XBFwFCED3G/TKKBjKubCMk0yxegCa+JZt+HzSbRTILgFv0eC+DvZBgMHMx0RjefvOJY6mCWtwwYRULp+2ulls6RTX2F3aEEKO0+/9YxTfzvwE1zFLAVxNpCg25f35eWuBdIJD/2K42Krbe2xrGDJdFhRtpT1uoq0qGHreIk= phonkd@Eliss-MacBook-Pro.local"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFrYSWQbmJ2oL4nORm6U0qiJAmrgE2dNQVKlV36i5uiF phonkd@blac"
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
    flake = lib.mkForce "github:phonkd/inventory?dir=machines#ext-mail";
    dates = "weekly";
  };
  sops.secrets.discord_webhook_url = {
    sopsFile = ./secrets/secret.yaml;
  };

}
