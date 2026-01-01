provider "aws" {
  region = "us-east-1"
}

# 1. Security Group (Name changed to v3 to avoid the 'Duplicate' error)
resource "aws_security_group" "docker_sg" {
  name        = "docker-server-sg-v3" 
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2a. Generate an SSH keypair and register it with AWS
resource "random_id" "suffix" {
  byte_length = 4
}

resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer-key-${random_id.suffix.hex}"
  public_key = tls_private_key.deployer.public_key_openssh
}

# 2b. EC2 Instance (Using the AMI from your screenshot)
resource "aws_instance" "devops_server" {
  ami           = "ami-0ecb62995f68bb549" # The Free Tier AMI you found
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.docker_sg.id]
  key_name = aws_key_pair.deployer.key_name

  user_data = <<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              EOF

  tags = {
    Name = "DevOps-Docker-Server"
  }
}

# Sensitive output: private key for adding to GitHub Secrets (keep secure!)
output "private_ssh_key_pem" {
  value     = tls_private_key.deployer.private_key_pem
  sensitive = true
}

# 3. Output the IP (Required for the GitHub Action to work)
output "server_public_ip" {
  value = aws_instance.devops_server.public_ip
}