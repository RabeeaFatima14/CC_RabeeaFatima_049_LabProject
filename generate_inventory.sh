#!/bin/bash

# Get IPs from Terraform
FRONTEND_IP=$(terraform output -raw frontend_public_ip)
BACKEND1_IP=$(terraform output -json backend_public_ips | jq -r '.[0]')
BACKEND2_IP=$(terraform output -json backend_public_ips | jq -r '.[1]')
BACKEND3_IP=$(terraform output -json backend_public_ips | jq -r '.[2]')

# Generate inventory file
cat > ansible/inventory/hosts << EOF
[frontend]
${FRONTEND_IP}

[backends]
${BACKEND1_IP}
${BACKEND2_IP}
${BACKEND3_IP}

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_python_interpreter=/usr/bin/python3
EOF

echo "Inventory file generated successfully!"
cat ansible/inventory/hosts

