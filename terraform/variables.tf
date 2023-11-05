variable "proxmox_api_url" {
  description = "URL to the Proxmox Host API"
  type        = string
  default     = "https://1.2.3.4:8006/api2/json"
}

variable "proxmox_api_token_id" {
  description = "API Token ID"
  type        = string
  sensitive   = true
  default     = "example@pam!terraform"
}

variable "proxmox_api_token_secret" {
  description = "Proxmox API Token Secret"
  type        = string
  sensitive   = true
  default     = "somereall-ygoo-dsec-ret0-foofoofoofoo"
}

variable "public_ssh_key" {
  description = "SSH Key to be copied to the created virtual machines"
  type        = string
}

variable "ubuntu_cloudinit_template" {
  description = "Template from an Cloud image"
  type        = string
  sensitive   = true
  default     = "ubuntu2204-ci"
}

variable "proxmox_node_name" {
  description = "The target node of your Proxmox Cluster"
  type        = string
  sensitive   = true
  default     = "proxmox"
}

variable "ovs_bridge" {
  description = "The target OVS bridge"
  type        = string
  sensitive   = true
  default     = "vmbr10"
}

variable "user" {
  description = "The user that will be created on the VMS"
  type        = string
  sensitive   = true
  default     = "user"
}

variable "password" {
  description = "The Password for the created VM user"
  type        = string
  sensitive   = true
  default     = "password"
}

variable "nameserver" {
  description = "The name server for the new VMs"
  type        = string
  sensitive   = true
  default     = "8.8.8.8"
}
