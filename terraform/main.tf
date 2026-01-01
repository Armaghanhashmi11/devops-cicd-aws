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

# 2. EC2 Instance (Using the AMI from your screenshot)
resource "aws_instance" "devops_server" {
  ami           = "ami-0ecb62995f68bb549" # The Free Tier AMI you found
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

# 3. Output the IP (Required for the GitHub Action to work)
output "server_public_ip" {
  value = aws_instance.devops_server.public_ip
}