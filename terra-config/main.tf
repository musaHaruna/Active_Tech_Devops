# provider block unchanged
provider "aws" {
  region = "eu-north-1"
}

data "aws_vpc" "default" {
  default = true
}

# Choose Canonical (Ubuntu) AMIs reliably
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "web_sg" {
  name        = "nginx-web-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
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

resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  # make sure it receives a public IP for reliability
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash -xe
              # update and install docker and git
              apt-get update -y
              apt-get install -y docker.io docker-compose git
              systemctl start docker
              systemctl enable docker

              # clone and start app
              cd /home
              git clone https://github.com/musaHaruna/Active_Tech_Devops.git || true
              cd Active_Tech_Devops || { echo "clone failed or repo missing"; journalctl -u docker.service --no-pager; exit 1; }
              docker-compose up -d --build || { echo "docker-compose up failed"; docker-compose logs --no-color --tail=200; exit 1; }

              # wait until containerized app is listening on 80 (10 attempts)
              for i in $(seq 1 20); do
                if ss -ltn | grep -q ':80' ; then
                  echo "Port 80 is open"
                  exit 0
                fi
                sleep 10
              done
              echo "Timeout waiting for port 80" && docker-compose logs --no-color --tail=200
              EOF

  tags = {
    Name = "nginx-docker-instance"
  }
}

output "public_ip" {
  value = aws_instance.web.public_ip
}
