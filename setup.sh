#!/bin/bash
terraform -chdir=./terraform/ apply -auto-approve
terraform output -state=./terraform/terraform.tfstate traffic-host1_ip >> ip.log
terraform output -state=./terraform/terraform.tfstate traffic-host2_ip >> ip.log
terraform output -state=./terraform/terraform.tfstate k3s_ip >> ip.log
