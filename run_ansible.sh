#!/bin/bash
# Simple wrapper script to generate Terraform outputs and run Ansible

echo "Generating Terraform outputs..."
terraform output -json > tf_outputs.json

echo "Making dynamic inventory script executable..."
chmod +x ansible/dynamic_inventory.py

echo "Running Ansible playbook with dynamic inventory..."
ansible-playbook -i ansible/dynamic_inventory.py ansible/provision.yml

echo "Cleaning up..."
rm -f tf_outputs.json
