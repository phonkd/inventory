{ config, pkgs, lib, ... }:
{
  services.minecraft-server.declarative = true;
  minecraft-server.serverProperties = {
    levelName = "world";
    maxPlayers = 20;
    motd = "Nu uh";
    difficulty = "Hard";
    gamemode = "survival";
    white-list = true;
    enable-rcon = true;
    "rcon.password" = "hunter2";
  };
  services.minecraft-server.eula = true;
  services.minecraft-server.openFirewall = true;
  services.minecraft-server.jvmOpts = "-Xmx16384M -Xms2048M";
}
