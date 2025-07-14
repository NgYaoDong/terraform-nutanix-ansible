#!/bin/bash
# Simple wrapper script to generate Terraform outputs and run Ansible

export ANSIBLE_HOST_KEY_CHECKING=False

scripts_dir=scripts/entity
files_dir=ansible/files
if [ ! -d "$scripts_dir" ]; then
  echo "Scripts directory not found: $scripts_dir"
  exit 1
fi
if [ ! -d "$files_dir" ]; then
  echo "Files directory not found: $files_dir"
  echo "Creating $files_dir directory..."
  mkdir -p $files_dir
fi

echo "Copying setup scripts to the $files_dir directory..."
cp $scripts_dir/setup.sh $files_dir/setup.sh
cp $scripts_dir/env.sh $files_dir/env.sh
cp $scripts_dir/gencerts.sh $files_dir/gencerts.sh
cp -r misc/conf $files_dir/conf

echo "Generating Terraform outputs..."
terraform output -json > tf_outputs.json

echo "Making dynamic inventory script executable..."
chmod +x ansible/dynamic_inventory.py

echo "Running Ansible playbook with dynamic inventory..."
ansible-playbook -i ansible/dynamic_inventory.py ansible/provision.yml

echo "Cleaning up..."
rm -f tf_outputs.json
