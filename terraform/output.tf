output "k3s_ip" {
  value     = proxmox_vm_qemu.k3s.ssh_host
  sensitive = true
}

output "k3s_name" {
  value     = proxmox_vm_qemu.k3s.name
  sensitive = true
}
