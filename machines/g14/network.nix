{
  config,
  lib,
  pkgs,
  ...
}:

{
  # Use declarative networking with secondary IP
  #networking.useDHCP = true;
  networking.hostName = "g14";
  networking.nameservers = [
    "127.0.0.1"
    "1.1.1.1"
  ];

  # Disable IPv6
  networking.enableIPv6 = false;
  environment.systemPackages = with pkgs; [
    iwd
    iwgtk
  ];
  # networking.wireless.iwd.enable = true;
  networking.nat.externalInterface = lib.mkForce "wlp2s0";
  programs.ssh.startAgent = lib.mkForce false; # ssh-agent
  #options.bedag.oath_accounts_string = lib.mkForce "LinOTP:LSGO05952AD7";
}
