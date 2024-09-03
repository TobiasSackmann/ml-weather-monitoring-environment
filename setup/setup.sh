#!/bin/bash

# Put Software on k3s Cluster and configure it
echo 'Deploy and Configure Software'
ansible-playbook install.yml -i ./inventory.yml