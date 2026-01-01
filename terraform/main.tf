provider "aws" {
  region = "us-east-1"
}

# 1. Create a Security Group
resource "aws_security_group" "docker_sg" {
  name        = "docker-server-sg"
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

# 2. Create the EC2 Instance (Using t3.micro for 2026 Free Tier)
resource "aws_instance" "devops_server" {
  ami           = "ami-0e2c8ccd4e1ffc351" # Ubuntu 24.04 LTS for us-east-1
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.docker_sg.id]

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

# 3. Output the Public IP so we can find it easily
output "server_public_ip" {
  value = aws_instance.devops_server.public_ip
}