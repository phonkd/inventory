{ config, pkgs, lib, ... }:
{
  imports = [
    ../apps/rebuildah/rebuildah.nix
  ];
  services.cron.systemCronJobs = [
    "*/3 * * * * root nix-experiment -repopath /tmp/kek -useflakes true -nixconfig machines-nok8s/121-nix-services/flake.nix -repourl https://github.com/phonkd/inventory.git -ntfyurl https://notify.arnsi.ch/seltest -ntfytoken '${builtins.readFile config.sops.secrets."ntfytoken".path}'"
  ];
  # smore is necessarcy (its in base)
#
}
