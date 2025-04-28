# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).s

{ ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./network.nix
      ./vm.nix
      ../../machine-base/base.nix
      ../../machine-base/ssh.nix
      ../../machine-base/base-hardware-configuration.nix
      ../apps/teleport.nix
    ];
  sops.secrets.teleport_authkey = {};
  users.users."phonkd".openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICC9CNRY2Taox2Trbsj7nBf52V73gGmJLM20+b2w1n5z phonkd@DESKTOP-F5QQLIG"
    # content of authorized_keys file
    # note: ssh-copy-id will add user@your-machine after the public key
    # but we can remove the "@your-machine" part
  ];
}
