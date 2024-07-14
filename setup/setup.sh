#!/bin/bash

wait_for_remote_dpkg_lock() {
    local remote_user="$1"
    local remote_host="$2"
    local lock_file="/var/lib/dpkg/lock-frontend"
    local stale_lock_removal_attempts=3
    local attempt=1

    echo "Waiting for dpkg lock to be released on ${remote_host}..."

    while ssh "${remote_user}@${remote_host}" "sudo fuser ${lock_file}" >/dev/null 2>&1; do
        echo "Lock file is present on ${remote_host}. Waiting..."
        sleep 2

        if [ "$attempt" -ge "$stale_lock_removal_attempts" ]; then
            echo "Checking for stale lock on ${remote_host}..."

            pid=$(ssh "${remote_user}@${remote_host}" "sudo fuser -u ${lock_file} 2>/dev/null")
            if [ -n "$pid" ]; then
                if ! ssh "${remote_user}@${remote_host}" "ps -p ${pid} > /dev/null 2>&1"; then
                    echo "Stale lock found on ${remote_host}. Removing..."
                    ssh "${remote_user}@${remote_host}" "sudo rm -f ${lock_file}"
                    break
                fi
            fi

            attempt=0 # Reset attempts after checking for stale lock
        fi

        attempt=$((attempt + 1))
    done

    echo "dpkg lock released on ${remote_host}. Continuing..."
}

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

# Slepp for 30 seconds to be sure that host is up. k3s Playbook may fail otherwise
#echo 'Sleep for 100 seconds to ensure k3s host is ready'
#sleep 100s

#echo 'Waiting Until k3s machine is ready'
#wait_for_remote_dpkg_lock "tobias" $k3s_ip # TODO: get from vault

# install k3s on the k3s host
echo 'Install k3s'
pushd ../k3s-ansible/
ansible-playbook ./playbook/site.yml -i ../setup/inventory.yml
popd

# Put Software on k3s Cluster and configure it
echo 'Deploy and Configure Software'
ansible-playbook deploy-tig-stack.yml -i ./inventory.yml