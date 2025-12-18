This is a monorepo containing about 95% of all my configs (from macbook to talos cluster on proxmox). I do almost everything declaritively for fun while being fully aware that its overkill for a homelab...

The 5% consist of my phone, a nothing phone with docker on it and windows for gaming.

# stuff i use here
- Proxmox (as hypervisor)
- hetzner (for teleport)
- Nixos for VM's and Desktop pc
- Macbook (my love&hate relationship) some things are configured with nix-darwin
- Terraform to create the nixos vms and the talos template
- Talos (for non long standing k8s clusters)
- k8s:
  - k3s nixos module that creates:
    - argocd to create the root cluster
    - an argo app which will create the child clusters nodes as well as its cni (clusterresourceset)
  - Capi: used to create talos cluster declaratively
  - Teleport to access my stuff which is deployed manually on a hetzner vm. (for now)
- see the modules directory, i have many services that are on vms, i plan to create a list of things i use automatically by something scanning this repo.

## why not proxmox nixos
i have seen the project and do find it very cool however dont want to build my infrastructure around it.
I believe that the terraform provider is more future proof / similar to other methods of creating vms declaratively. I know that the capi k8s setup might not be very reliable or maintainable as the image has to be manually downloaded, converted to qcow and so on. I use k8s primarily for tinkering with stuff i find on github trends. The things i actually use on a day to day basis are on my nixos vms.


# personal opinions of things i use:
- nice:
  - teleport
  - vaultwarden
  - syncthing
  - paperless
- annoying but has to be:
  - nix-sops
  - ddns.nix (had to write this myself because all other solutions are genuine ragebait)
- shit but nothing better
  - traefik (used caddy but has no keycloak middleware)
  - keycloak (absolute horrible configuration) want a working setup but dont want to put in the effort
  - talos + proxmox (let me explain): nocloud image from talos is only available as .raw.xz therefore cant be imported directly into proxmox via terraform so for each update of talos we must manually pull image, convert it and upload it to some s3... just give us nocloud qcow2 like for everything but nocloud talos ????
# jürgen löscher

```bash
k delete taloscontrolplanes,clusters,proxmoxclusters,machinedeployments,machinesets,proxmoxmachines --all
```
