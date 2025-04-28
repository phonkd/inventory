{ config, pkgs, lib, ... }:

let
  ntfytokentemp = if builtins.pathExists config.sops.secrets."ntfytoken".path then
                    builtins.readFile config.sops.secrets."ntfytoken".path
                  else
                    "default_auth_token_placeholder";
in
{
  imports = [
  ];

  services.cron.systemCronJobs = [
    "*/3 * * * * root nix-experiment -repopath /tmp/kek -useflakes true -nixconfig machines-nok8s/121-nix-services/flake.nix -repourl https://github.com/phonkd/inventory.git -ntfyurl https://notify.arnsi.ch/seltest -ntfytoken '${ntfytokentemp}'"
  ];

  # smore is necessary (it's in base)
}
