# Auto-generated using compose2nix v0.3.1.
{ pkgs, lib, ... }:

{
  services.technitium-dns-server = {
    enable = true;
    openfirewall = true;
  };
}
