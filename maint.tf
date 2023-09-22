provider "libvirt" {
  uri = "qemu:///system"  # Verbindung zur lokalen QEMU-Instanz
}

resource "libvirt_volume" "debian_image" {
  name        = "debian.qcow2"
  pool        = "default"  # Name des Speicherpools
  #source      = "https://cdimage.debian.org/cdimage/openstack/current/debian-10-openstack-amd64.qcow2"
  source      = "https://cloud.debian.org/images/cloud/bullseye/20230912-1501/debian-11-nocloud-ppc64el-20230912-1501.qcow2"
  format      = "qcow2"
  content_type = "raw"
}

resource "libvirt_domain" "debian_vm" {
  name   = "debian-vm"
  memory = "2048"
  vcpu   = 2

  disk {
    volume_id = libvirt_volume.debian_image.id
  }

  network_interface {
    network_name = "default"  # Name des virtuellen Netzwerks
  }
}
