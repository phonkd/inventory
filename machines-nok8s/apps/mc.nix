{ config, pkgs, lib, ... }:
{
  services.minecraft-server.declarative = {
    enable = true;
    package = pkgs.minecraft-server;
    serverJar = pkgs.minecraft-server.serverJar;
    serverProperties = {
      levelName = "world";
      maxPlayers = 20;
      motd = "Nu uh";
      difficulty = "Hard";
      gamemode = "survival";
      white-list = true;
      enable-rcon = true;
      "rcon.password" = "hunter2";
    };
  };
  services.minecraft-server.eula = true;
  services.minecraft-server.openFirewall = true;
}
