This is a monorepo containing about 95% of all my configs (from macbook to talos cluster on proxmox). I do almost everything declaritively for fun while being fully aware that its overkill for a homelab...

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



# jürgen löscher

```bash
k delete taloscontrolplanes,clusters,proxmoxclusters,machinedeployments,machinesets,proxmoxmachines --all
```
