provider "proxmox" {
  pm_api_url          = var.proxmox_api_url
  pm_api_token_id     = var.proxmox_api_token_id
  pm_api_token_secret = var.proxmox_api_token_secret
  pm_tls_insecure     = true
}

resource "proxmox_vm_qemu" "traffic-host1" {
  name        = "traffic-host1"
  desc        = "Ubuntu-Server"
  target_node = var.proxmox_node_name
  sshkeys     = var.public_ssh_key
  agent       = 1
  clone       = var.ubuntu_cloudinit_template
  qemu_os     = "l26"
  # this l26 is a small l like linux
  cores   = 2
  sockets = 1
  cpu     = "host"
  memory  = 8096
  scsihw  = "virtio-scsi-pci"
  vga {
    type = "std"
  }
  disk {
    storage = "local-lvm"
    type    = "scsi"
    size    = "83212M"
    discard = "on"
    ssd     = "1"
  }
  network {
    bridge = var.ovs_bridge
    model  = "virtio"
  }
  ## muss dem Template matchen
  os_type    = "cloud-init"
  ipconfig0  = "ip=dhcp"
  nameserver = var.nameserver
  ciuser     = var.user
  cipassword = var.password
}

resource "proxmox_vm_qemu" "traffic-host2" {
  name        = "traffic-host2"
  desc        = "Ubuntu-Server"
  target_node = var.proxmox_node_name
  sshkeys     = var.public_ssh_key
  agent       = 1
  clone       = var.ubuntu_cloudinit_template
  qemu_os     = "l26"
  # this l26 is a small l like linux
  cores   = 2
  sockets = 1
  cpu     = "host"
  memory  = 8096
  scsihw  = "virtio-scsi-pci"
  vga {
    type = "std"
  }
  disk {
    storage = "local-lvm"
    type    = "scsi"
    size    = "83212M"
    discard = "on"
    ssd     = "1"
  }
  network {
    bridge = var.ovs_bridge
    model  = "virtio"
  }
  ## muss dem Template matchen
  os_type    = "cloud-init"
  ipconfig0  = "ip=dhcp"
  nameserver = var.nameserver
  ciuser     = var.user
  cipassword = var.password
}
