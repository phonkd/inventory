{ config, lib, pkgs, ... }:
{
  services.homepage-dashboard = {
    enable = true;
    services = [
      {
        "My First Group" = [
            {
            "My First Service" = {
                description = "Homepage is awesome";
                href = "http://localhost/";
            };
            }
        ];
      }
    ];
  };
}
