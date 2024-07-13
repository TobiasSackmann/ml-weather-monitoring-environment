#!/bin/bash

wait_for_dpkg_lock() {
    local lock_file="/var/lib/dpkg/lock-frontend"
    echo "Waiting for dpkg lock to be released..."

    # Loop until the lock file is not found
    while [ -e "$lock_file" ]; do
        # Optionally, check if the lock file is held by a process that no longer exists
        if [ -f "$lock_file" ]; then
            pid=$(lsof -t "$lock_file")
            if [ -z "$pid" ] || ! ps -p "$pid" > /dev/null 2>&1; then
                echo "Stale lock file found, removing it..."
                sudo rm -f "$lock_file"
            fi
        fi
        echo "Lock file is present. Waiting..."
        sleep 2
    done

    echo "dpkg lock released. Continuing..."
}

# prepare new setup
rm -f host_ip.csv

# start testbed creation by creating VMs with terraform
terraform -chdir=../terraform/ init
terraform -chdir=../terraform/ apply -auto-approve

# Use terraform outputs to generate Anisble inventory
traffichost1_ip=$(terraform output -state=../terraform/terraform.tfstate traffic-host1_ip)
traffichost2_ip=$(terraform output -state=../terraform/terraform.tfstate traffic-host2_ip)
k3s_ip=$(terraform output -state=../terraform/terraform.tfstate k3s_ip)

traffichost1_name=$(terraform output -state=../terraform/terraform.tfstate traffic-host1_name)
traffichost2_name=$(terraform output -state=../terraform/terraform.tfstate traffic-host2_name)
k3s_name=$(terraform output -state=../terraform/terraform.tfstate k3s_name)

echo "${traffichost1_name},${traffichost1_ip}" >> host_ip.csv
echo "${traffichost2_name},${traffichost2_ip}" >> host_ip.csv
echo "${k3s_name},${k3s_ip}" >> host_ip.csv

# Create Inventory from Terraform Output
echo 'Create Inventory'
python3 parse_inventory.py

# Slepp for 30 seconds to be sure that host is up. k3s Playbook may fail otherwise
#echo 'Sleep for 100 seconds to ensure k3s host is ready'
#sleep 100s

echo 'Waiting Until k3s machine is ready'
wait_for_dpkg_lock()

# install k3s on the k3s host
echo 'Install k3s'
pushd ../k3s-ansible/
ansible-playbook ./playbook/site.yml -i ../setup/inventory.yml
popd

# Put Software on k3s Cluster and configure it
echo 'Deploy and Configure Software'
ansible-playbook deploy-tig-stack.yml -i ./inventory.yml