provider "proxmox" {
  pm_api_url          = "https://192.168.178.36:8006/api2/json"
  pm_api_token_id     = "root@pam!terraform"
  pm_api_token_secret = "3f6b2a12-a51d-43fd-a0e4-aea8c1d6e183"
  pm_tls_insecure     = true
}

resource "proxmox_vm_qemu" "srv_demo_1" {
  name        = "srv-demo-1"
  desc        = "Ubuntu-Server"
  target_node = "proxmox"
  sshkeys     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDnA0gYQ1FZUpkMclmv6Eb0fC98pImM51p68+3KwHCuL+zjjPkG4DYKenhkFWHG4esISi2HFKSCNMwwd6sGUaLnqbYFt2vIuFHgRo4IRcjqUy3lVAhnCNOMBqrCzjKs84P/a7j0BgIKVXUT6yELCVs/5ubHM3EP+NmYlLjpizSoBs1TVpWdlBhnQZPi9TLV6RNg8Tnhq8undyfRigU1rfl/XK73kECbyqnRD75GdLMdxOXw5s8QVof4TOi2exMBEQUvHWpEPPa3z8Mqw8a0JcCwTM5bW8YBNx6myp+th44LR4pOqP1nyHqBtGmAijAKV8gCEaQKAK5tYg9+T90oIVAUlRunVQCbtpqorg3E9PFBul6QR7vop8jwC0adhgomrlnYknYCIDHTzprOMEzUBZwtj5TkGVwGX2xFpjEvazHJOBhH9+Fv2bkO1A7u4zUqXq/JPoaESHOTwrxzF3GxoHVuGkMUtXQLTDk+71c1Do5TL7kuS2wQYYfeGUlmYQffhSU= tobias@tobias-endeavour-os"
  agent       = 1
  clone       = "ubuntu2204-ci"
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
    bridge = "vmbr0"
    model  = "virtio"
  }

  ## muss dem Template matchen

  os_type    = "cloud-init"
  ipconfig0  = "ip=dhcp"
  nameserver = "8.8.8.8"
  ciuser     = "tk"
}
