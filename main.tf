terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "me-central-1"
}

# VPC
resource "aws_vpc" "myapp_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.env_prefix}-vpc"
  }
}

# Subnet Module
module "myapp-subnet" {
  source                 = "./modules/subnet"
  vpc_id                 = aws_vpc.myapp_vpc.id
  subnet_cidr_block      = var.subnet_cidr_block
  availability_zone      = var.availability_zone
  env_prefix             = var.env_prefix
  default_route_table_id = aws_vpc.myapp_vpc.default_route_table_id
}

# Security Group
resource "aws_security_group" "myapp_sg" {
  name        = "${var.env_prefix}-sg"
  description = "Security group for frontend and backend servers"
  vpc_id      = aws_vpc.myapp_vpc.id

  # SSH from your IP only
  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [local.my_ip]
  }

  # HTTP from anywhere (for nginx frontend and backend testing)
  ingress {
    description = "HTTP from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # All outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env_prefix}-sg"
  }
}

# SSH Key Pair
resource "aws_key_pair" "myapp_key" {
  key_name   = "${var.env_prefix}-key"
  public_key = file(var.public_key)

  tags = {
    Name = "${var.env_prefix}-key"
  }
}
# Frontend EC2 Instance (Nginx)
resource "aws_instance" "frontend" {
  ami                    = "ami-07aca7a231992279f" 
  instance_type          = var.instance_type
  subnet_id              = module.myapp-subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.myapp_sg.id]
  availability_zone      = var.availability_zone
  key_name               = aws_key_pair.myapp_key.key_name

  associate_public_ip_address = true

  tags = {
    Name = "${var.env_prefix}-frontend"
    Type = "frontend"
    Role = "nginx"
  }
}

# Backend EC2 Instances (HTTPD) - 3 instances
resource "aws_instance" "backend" {
  count                  = 3
  ami                    = "ami-07aca7a231992279f"  
  instance_type          = var.instance_type
  subnet_id              = module.myapp-subnet.subnet.id
  vpc_security_group_ids = [aws_security_group.myapp_sg.id]
  availability_zone      = var.availability_zone
  key_name               = aws_key_pair.myapp_key.key_name

  associate_public_ip_address = true

  tags = {
    Name = "${var.env_prefix}-backend-${count.index + 1}"
    Type = "backend"
    Role = "httpd"
  }
}

# Null Resource to Trigger Ansible Configuration
resource "null_resource" "configure_servers" {
  # Triggers - re-run if any instance IP changes
  triggers = {
    frontend_ip  = aws_instance.frontend.public_ip
    backend_ips  = join(",", [for instance in aws_instance.backend : instance.public_ip])
    always_run   = timestamp()
  }

  # Dependencies - wait for all instances to be ready
  depends_on = [
    aws_instance.frontend,
    aws_instance.backend
  ]

   provisioner "local-exec" {
    command = <<-EOT
      #!/bin/bash
      set -e
      
      echo "Generating Ansible inventory..."
      FRONTEND_IP="${aws_instance.frontend.public_ip}"
      BACKEND1_IP="${aws_instance.backend[0].public_ip}"
      BACKEND2_IP="${aws_instance.backend[1].public_ip}"
      BACKEND3_IP="${aws_instance.backend[2].public_ip}"
      
      cat > ansible/inventory/hosts << EOF
[frontend]
$FRONTEND_IP

[backends]
$BACKEND1_IP
$BACKEND2_IP
$BACKEND3_IP

[all:vars]
ansible_user=ec2-user
ansible_ssh_private_key_file=~/.ssh/id_ed25519
ansible_python_interpreter=/usr/bin/python3
EOF
      
      echo "Waiting for instances to be fully ready..."
      sleep 60
      
      echo "Running Ansible playbook..."
      cd ansible
      ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook playbooks/site.yaml
    EOT
  }
}
