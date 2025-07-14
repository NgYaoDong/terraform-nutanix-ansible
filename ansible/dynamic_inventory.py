#!/usr/bin/env python3

import json
import sys
import os

# Path to the Terraform outputs JSON file
tf_outputs_file = 'tf_outputs.json'

# Check if the outputs file exists
if not os.path.exists(tf_outputs_file):
    print(f"Error: {tf_outputs_file} not found. Run 'terraform output -json > tf_outputs.json' first.", file=sys.stderr)
    sys.exit(1)

# Load Terraform outputs
try:
    with open(tf_outputs_file) as f:
        tf_out = json.load(f)
except json.JSONDecodeError as e:
    print(f"Error parsing JSON: {e}", file=sys.stderr)
    sys.exit(1)

# Extract IP addresses
clients = tf_out['client_ips']['value']
gateways = tf_out['gateway_ips']['value']

# Build Ansible inventory
inventory = {
    'client': {
        'hosts': list(clients.keys()),  # Use VM names as inventory_hostname
        'vars': {
            'ansible_user': 'root',
            'ansible_password': 'password',
            'role': 'client'
        }
    },
    'gateway': {
        'hosts': list(gateways.keys()),  # Use VM names as inventory_hostname
        'vars': {
            'ansible_user': 'root',
            'ansible_password': 'password',
            'role': 'gateway'
        }
    },
    '_meta': {
        'hostvars': {}
    }
}

# Add host-specific variables
for name, ip in clients.items():
    inventory['_meta']['hostvars'][name] = {
        'vm_name': name,
        'role': 'client',
        'ansible_host': ip
    }

for name, ip in gateways.items():
    inventory['_meta']['hostvars'][name] = {
        'vm_name': name,
        'role': 'gateway',
        'ansible_host': ip
    }

# Output inventory as JSON
print(json.dumps(inventory, indent=2))
