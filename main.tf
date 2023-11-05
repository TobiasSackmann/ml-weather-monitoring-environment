provider "libvirt" {
  uri = "qemu:///system" # Verbindung zur lokalen QEMU-Instanz
}

resource "libvirt_pool" "debian" {
  name = "debian"
  type = "dir"
  path = "/tmp/terraform-provider-libvirt-pool-debian"
}


resource "libvirt_volume" "debian_image" {
  name = "debian.qcow2"
  pool = "default" # Name des Speicherpools
  source = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
  format = "qcow2"
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud_init.cfg")
}

data "template_file" "network_config" {
  template = file("${path.module}/network_config.cfg")
}

resource "libvirt_cloudinit_disk" "commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.user_data.rendered
  network_config = data.template_file.network_config.rendered
  pool           = libvirt_pool.debian.name
}

resource "libvirt_network" "testbed_network" {
  # the name used by libvirt
  name = "testbed_network"

  # mode can be: "nat" (default), "none", "route", "open", "bridge"
  mode = "nat"

  #  the domain used by the DNS server in this network
  # domain = libvirt_domain.debian_vm.name
  # domain = "debian-vm"

  #  list of subnets the addresses allowed for domains connected
  # also derived to define the host addresses
  # also derived to define the addresses served by the DHCP server
  addresses = ["192.168.0.0/20"]

  # (optional) the bridge device defines the name of a bridge device
  # which will be used to construct the virtual network.
  # (only necessary in "bridge" mode)
  # bridge = "br7"

  # (optional) the MTU for the network. If not supplied, the underlying device's
  # default is used (usually 1500)
  # mtu = 9000
}

# TODO: Debug Domain Creation
resource "libvirt_domain" "debian_vm" {
  name   = "debian-vm"
  memory = "2048"
  vcpu   = 2

  cloudinit = libvirt_cloudinit_disk.commoninit.id

  disk {
    volume_id = libvirt_volume.debian_image.id
  }

  network_interface {
    #network_name = "testbed_network" # Name des virtuellen Netzwerks
    #network_id     = libvirt_network.testbed_network.id
    network_name = "default"
  }
}
