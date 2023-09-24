# terraform-network-testbed
Terraform Repository for creating a kvm/qemu based virtual network

Requirements
------------
* Terraform is installed on your target host
* qemu-kvm is installed on your target host
* libvirt is installed on you target host
    * libvirt-daemon-system
    * libvirt-clients
* virt-manager is installed on you target host
* optional: cockpit is installed on you target host (makes it easy to verify the result on the web overlay on Port 9090)
* Executing user is member of kvm and libvirt group on the targte host