{ config, pkgs, lib, ... }:
{
  services.minecraft-server = {
    enable = true;
    declarative = true;
    eula = true;
    openFirewall = true;
    jvmOpts = "-Xmx16384M -Xms2048M";
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


}
