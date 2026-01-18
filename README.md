# Lab Project: Nginx Frontend with 3 Backend HTTPD Servers

## Architecture

Internet
↓
[Nginx Frontend] - Public IP: <your-frontend-ip>
↓ (reverse proxy)
↓
├─→ [Backend 1] - Primary (httpd) - Private: 10.0.10.X
├─→ [Backend 2] - Primary (httpd) - Private: 10.0.10.Y
└─→ [Backend 3] - Backup (httpd) - Private: 10.0.10.Z


## Load Balancing Behavior

- **Normal Operation**: Requests alternate between Backend 1 and Backend 2 (round-robin)
- **Failover**: If both primaries fail, Backend 3 serves all requests
- **Recovery**: When primaries come back, traffic returns to Backend 1 and 2

## Deployment

```bash
cd ansible
ansible-playbook playbooks/site.yaml

# Test load balancing
curl http://<frontend-ip>

# Test in browser
http://<frontend-ip>

├── main.tf              # Terraform infrastructure
├── variables.tf         # Terraform variables
├── outputs.tf           # Terraform outputs
├── modules/
│   ├── subnet/         # VPC subnet module
│   └── webserver/      # (optional)
└── ansible/
    ├── ansible.cfg      # Ansible configuration
    ├── inventory/
    │   └── hosts        # Static inventory
    ├── playbooks/
    │   └── site.yaml    # Main playbook
    └── roles/
        ├── backend/     # HTTPD backend role
        └── frontend/    # Nginx frontend role
# Roles
Backend Role
Installs Apache HTTPD

Deploys distinct HTML content per backend

Enables and starts httpd service

Frontend Role
Installs Nginx

Configures reverse proxy with upstream

2 primary + 1 backup backend configuration
