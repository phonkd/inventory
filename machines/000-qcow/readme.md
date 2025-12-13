this is used to build the qcow image which is then uploaded to your s3 of choice and downloaded in the terraform files.

Build using:
```bash
cd ~/git/inventory/machines
nix run github:nix-community/nixos-generators -- --format qcow --flake .#000-qcow
```
