output "traffic-host1_ip" {
  value     = proxmox_vm_qemu.traffic-host1.ssh_host
  sensitive = true
}

output "traffic-host1_name" {
  value     = proxmox_vm_qemu.traffic-host1.name
  sensitive = true
}

output "traffic-host2_ip" {
  value     = proxmox_vm_qemu.traffic-host2.ssh_host
  sensitive = true
}

output "traffic-host2_name" {
  value     = proxmox_vm_qemu.traffic-host2.name
  sensitive = true
}

output "k3s_ip" {
  value     = proxmox_vm_qemu.k3s.ssh_host
  sensitive = true
}

output "k3s_name" {
  value     = proxmox_vm_qemu.k3s.name
  sensitive = true
}
