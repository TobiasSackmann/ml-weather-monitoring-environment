provider "libvirt" {
  uri = "qemu:///system" # Verbindung zur lokalen QEMU-Instanz
}

resource "libvirt_volume" "debian_image" {
  name = "debian.qcow2"
  pool = "default" # Name des Speicherpools
  source = "https://cloud.debian.org/images/cloud/bullseye/latest/debian-11-genericcloud-amd64.qcow2"
  #source = "/home/tobias/debian-11-nocloud-ppc64el-20230912-1501.qcow2"
  format = "qcow2"
  #content_type = "raw"
}


# TODO: Debug Domain Creation
resource "libvirt_domain" "debian_vm" {
  name   = "debian-vm"
  memory = "2048"
  vcpu   = 2

  disk {
    volume_id = libvirt_volume.debian_image.id
  }

  network_interface {
    #network_name = "testbed_network" # Name des virtuellen Netzwerks
    network_id     = libvirt_network.testbed_network.id
  }
}

resource "libvirt_network" "testbed_network" {
  # the name used by libvirt
  name = "testbed_network"

  # mode can be: "nat" (default), "none", "route", "open", "bridge"
  mode = "nat"

  #  the domain used by the DNS server in this network
  # domain = libvirt_domain.debian_vm.name
  domain = "debian-vm"

  #  list of subnets the addresses allowed for domains connected
  # also derived to define the host addresses
  # also derived to define the addresses served by the DHCP server
  addresses = ["192.168.0.0/24"]

  # (optional) the bridge device defines the name of a bridge device
  # which will be used to construct the virtual network.
  # (only necessary in "bridge" mode)
  # bridge = "br7"

  # (optional) the MTU for the network. If not supplied, the underlying device's
  # default is used (usually 1500)
  # mtu = 9000


}
