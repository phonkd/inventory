{
  config,
  inputs,
  pkgs,
  ...
}:
{
  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;
    package = pkgs.unstable.minecraft-server;
    serverProperties = {
      server-port = 25565;
      difficulty = 3;
      gamemode = 1;
      max-players = 20;
      motd = "Lanpartyfaggotry!";
      white-list = false;
      enable-rcon = true;
      "rcon.password" = "hunter2";
    };
    jvmOpts = "-Xmx12G -Xms1G";
  };
  networking.firewall.allowedTCPPorts = [ 25575 ];

}
