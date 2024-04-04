#!/bin/bash

# prepare new setup
rm -f host_ip.csv

# start testbed creation by creating VMs with terraform
terraform -chdir=./terraform/ init
terraform -chdir=./terraform/ apply -auto-approve

# Use terraform outputs to generate Anisble inventory
traffichost1_ip=$(terraform output -state=./terraform/terraform.tfstate traffic-host1_ip)
traffichost2_ip=$(terraform output -state=./terraform/terraform.tfstate traffic-host2_ip)
k3s_ip=$(terraform output -state=./terraform/terraform.tfstate k3s_ip)

traffichost1_name=$(terraform output -state=./terraform/terraform.tfstate traffic-host1_name)
traffichost2_name=$(terraform output -state=./terraform/terraform.tfstate traffic-host2_name)
k3s_name=$(terraform output -state=./terraform/terraform.tfstate k3s_name)

echo "${traffichost1_name},${traffichost1_ip}" >> host_ip.csv
echo "${traffichost2_name},${traffichost2_ip}" >> host_ip.csv
echo "${k3s_name},${k3s_ip}" >> host_ip.csv

python3 parse_inventory.py

# Slepp for 30 seconds to be sure that host is up. k3s Playbook may fail otherwise
echo 'sleep for 100 seconds to ensure k3s host is ready'
sleep 100s
echo 'start installing k3s'

# install k3s on the k3s host
cd k3s-ansible 
ansible-playbook playbook/site.yml -i ../inventory.yml
cd ..
ansible-playbook deploy-tig-stack.yml -i inventory.yml