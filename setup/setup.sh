#!/bin/bash

# prepare new setup
rm -f host_ip.csv

# start testbed creation by creating VMs with terraform
terraform -chdir=../terraform/ init
terraform -chdir=../terraform/ apply -auto-approve > /dev/null

# Use terraform outputs to generate Anisble inventory
k3s_ip=$(terraform output -state=../terraform/terraform.tfstate k3s_ip)
k3s_name=$(terraform output -state=../terraform/terraform.tfstate k3s_name)
echo "${k3s_name},${k3s_ip}" >> host_ip.csv

# Create Inventory from Terraform Output
echo 'Create Inventory'
python3 parse_inventory.py

# install k3s on the k3s host
echo 'Install k3s'
pushd ../k3s-ansible/
ansible-playbook ./playbook/site.yml -i ../setup/inventory.yml
popd

# Put Software on k3s Cluster and configure it
echo 'Deploy and Configure Software'
ansible-playbook deploy-tig-stack.yml -i ./inventory.yml