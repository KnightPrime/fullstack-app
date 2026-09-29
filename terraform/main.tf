provider "aws" {
  region = var.aws_region
}

# Security Group allowing HTTP and SSH
resource "aws_security_group" "app_sg" {
  name        = "app-security-group"
  description = "Allow inbound traffic on port 80 and 22"

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
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

# Launch EC2 instance (Ubuntu 22.04 LTS Free Tier eligible)
resource "aws_instance" "app_server" {
  ami                    = "ami-0c7217cdde317cfec" # Update valid Ubuntu AMI for your region
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  user_data              = file("${path.module}/user-data.sh")

  tags = {
    Name = "NodeReactAppServer"
  }
}

