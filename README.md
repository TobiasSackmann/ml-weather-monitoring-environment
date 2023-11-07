# terraform-network-testbed
Terraform Repository for creating a Proxmox based virtual network with monitoring infrastructure.

Requirements
------------
* Terraform is installed on your target host
* Proxmox is installed on your target host
* Initial Proxmox configurations have been applied like creating an API Token
* An Cloud Init capable image is available (is called ubuntu2204-ci in the code of this repository)
* An OVS Bridge with name vmbr10 is available


Usage
-----
* Create your .tfvars file with the variables defined in the terraform/variables.tf
* Execute the setup.sh script