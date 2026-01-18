
---

## Completed Tasks Checklist

- [x] Task 0: Project setup and repository structure
- [x] Task 1: Terraform networking (VPC, subnet, IGW, security groups)
- [x] Task 2: Terraform EC2 instances (1 frontend + 3 backends)
- [x] Task 3: Ansible directory structure and inventory
- [x] Task 4: Backend Ansible role (HTTPD with distinct content)
- [x] Task 5: Frontend Ansible role (Nginx reverse proxy)
- [x] Task 6: Main playbook (site.yaml) with dynamic IP injection
- [x] Task 7: Terraform-Ansible automation (null_resource)
- [x] Task 8: Testing and verification
- [x] Cleanup: All resources destroyed

## Screenshots Included

All required screenshots are in the `screenshots/` directory (if applicable) or referenced in the README.

## Assumptions

- **Region:** me-central-1 (Middle East - UAE)
- **Instance Type:** t3.micro (eligible for free tier)
- **AMI:** Amazon Linux 2023
- **SSH Key:** Generated in Codespace (~/.ssh/id_ed25519)

## How to Run

1. Configure AWS credentials:
   ```bash
   aws configure
Deploy complete stack:
terraform init
terraform apply -auto-approve

Test:
terraform output frontend_public_ip
curl http://<frontend-ip>

Clean up:
terraform destroy -auto-approve

## Architecture
Internet → [Nginx Frontend] → Backend 1 (primary)
                            → Backend 2 (primary)
                            → Backend 3 (backup)
## Features

Load Balancing: Round-robin between 2 primary backends

High Availability: Automatic failover to backup backend

Automation: Single terraform apply deploys entire stack

Idempotency: Safe to re-run configurations

Infrastructure as Code: Fully version-controlled

## Project Structure

├── main.tf                    # Terraform main configuration
├── variables.tf               # Variable definitions
├── outputs.tf                 # Output definitions
├── locals.tf                  # Local values (IP detection)
├── modules/
│   └── subnet/                # VPC subnet module
├── ansible/
│   ├── ansible.cfg            # Ansible configuration
│   ├── inventory/
│   │   └── hosts              # Static inventory
│   ├── playbooks/
│   │   └── site.yaml          # Main playbook
│   └── roles/
│       ├── backend/           # HTTPD backend role
│       └── frontend/          # Nginx frontend role
└── README.md                  # This file

