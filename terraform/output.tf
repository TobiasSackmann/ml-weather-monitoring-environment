output "traffic-host1" {
  value     = proxmox_vm_qemu.traffic-host1.network
  sensitive = false
}

output "traffic-host2" {
  value     = proxmox_vm_qemu.traffic-host2.network
  sensitive = false
}

output "k3s" {
  value     = proxmox_vm_qemu.k3s.network
  sensitive = false
}