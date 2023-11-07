output "traffic-host1_ip" {
  value     = proxmox_vm_qemu.traffic-host1.ssh_host
  sensitive = true
}

output "traffic-host2_ip" {
  value     = proxmox_vm_qemu.traffic-host2.ssh_host
  sensitive = true
}

output "k3s_ip" {
  value     = proxmox_vm_qemu.k3s.ssh_host
  sensitive = true
}
