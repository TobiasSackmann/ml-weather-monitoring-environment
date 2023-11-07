#!/bin/bash
terraform -chdir=./terraform/ apply -auto-approve
traffichost1_ip=$(terraform output -state=./terraform/terraform.tfstate traffic-host1_ip)
traffichost2_ip=$(terraform output -state=./terraform/terraform.tfstate traffic-host2_ip)
k3s_ip=$(terraform output -state=./terraform/terraform.tfstate k3s_ip)

echo "traffic-host1,${traffichost1_ip}" >> host_ip.csv
echo "traffic-host2,${traffichost2_ip}" >> host_ip.csv
echo "k3s,${k3s_ip}" >> host_ip.csv
