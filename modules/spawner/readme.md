# at the moment requires some manual work...
Manual parts:
- setup capmox provider in k3s cluster (automacharts in k3s nixos broken imo)
- Create clusterctl.yaml file (`sops --config .sops.yaml decrypt clusterctl.enc.yaml`)
- `clusterctl init --infrastructure proxmox --ipam in-cluster`
- `clusterctl generate cluster phonkd-test-01 --kubernetes-version 1.34.2 > generated-cluster.yaml`
- `kubectl apply -f generated-cluster.yaml`


## fix memory 0b error
add the followig to kind ProxmoxCluster

```
spec:
  schedulerHints:
    memoryAdjustment: 0
```

## DHCP Reservations for Talos VMs

After cluster creation, get MAC addresses of the VMs and create DHCP reservations:
- Find control plane VM ID: `kubectl get proxmoxmachines -n kube-system -o jsonpath='{.items[0].spec.virtualMachineID}'`
- Get MAC address: `curl -k -H "Authorization: PVEAPIToken=<token>" "https://pve.../api2/json/nodes/<node>/qemu/<vmid>/config" | jq -r '.data.net0'`
- Extract MAC from output (e.g., `BC:24:11:3D:0D:D5`)
- Create DHCP reservation matching the IPAM-allocated IP (check `kubectl get ipaddresses -n kube-system`) and the vms mac
- Repeat for all control plane nodes
