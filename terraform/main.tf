provider "aws" {
  region = "us-east-1" # You can change this to your closest region
}

# 1. Create a Security Group to allow Web Traffic
resource "aws_security_group" "docker_sg" {
  name        = "docker-server-sg"
  description = "Allow HTTP and SSH"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # SSH access
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Web access
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 2. Create the EC2 Instance
resource "aws_instance" "devops_server" {
  ami           = "ami-0c7217cdde317cfec" # Standard Ubuntu 22.04 AMI (verify for your region)
  instance_type = "t2.micro"
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