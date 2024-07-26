provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "traefik_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "traefik-vpc"
  }
}

resource "aws_subnet" "traefik_subnet" {
  vpc_id            = aws_vpc.traefik_vpc.id
  cidr_block        = "10.0.1.0/24"
  map_public_ip_on_launch = true
  tags = {
    Name = "traefik-subnet"
  }
}

resource "aws_internet_gateway" "traefik_igw" {
  vpc_id = aws_vpc.traefik_vpc.id
  tags = {
    Name = "traefik-igw"
  }
}

resource "aws_route_table" "traefik_route_table" {
  vpc_id = aws_vpc.traefik_vpc.id
  tags = {
    Name = "traefik-route-table"
  }
}

resource "aws_route" "traefik_route" {
  route_table_id         = aws_route_table.traefik_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.traefik_igw.id
}

resource "aws_route_table_association" "traefik_route_table_assoc" {
  subnet_id      = aws_subnet.traefik_subnet.id
  route_table_id = aws_route_table.traefik_route_table.id
}

resource "aws_security_group" "traefik_sg" {
  vpc_id      = aws_vpc.traefik_vpc.id
  name        = "traefik-sg"
  description = "Traefik security group"

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

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "traefik-sg"
    Project = "traefik-demo"
    Environment = "dev"
  }
}

resource "aws_instance" "traefik_instance" {
  ami                         = "ami-0c3fd0f5d33134a76" # Replace with your desired AMI in ap-northeast-1
  instance_type               = "t2.large"
  key_name                    = "traefik-demo-key" # Replace with your key pair name
  subnet_id                   = aws_subnet.traefik_subnet.id
  vpc_security_group_ids      = [aws_security_group.traefik_sg.id]
  associate_public_ip_address = true
  iam_instance_profile        = "ECSInstanceEC2Role" # Replace with your IAM instance profile if needed

  provisioner "file" {
    source      = "requirements.txt"
    destination = "/home/ec2-user/requirements.txt"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/traefik-demo-key.pem") # Path to your private key
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "Dockerfile"
    destination = "/home/ec2-user/Dockerfile"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/traefik-demo-key.pem") # Path to your private key
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "stack.yml"
    destination = "/home/ec2-user/stack.yml"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/traefik-demo-key.pem") # Path to your private key
      host        = self.public_ip
    }
  }

  provisioner "file" {
    source      = "setup.sh"
    destination = "/home/ec2-user/setup.sh"

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/traefik-demo-key.pem") # Path to your private key
      host        = self.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/ec2-user/setup.sh",
      "/home/ec2-user/setup.sh"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/traefik-demo-key.pem") # Path to your private key
      host        = self.public_ip
    }
  }

  tags = {
    Name = "traefik-demo-instance"
    Project = "traefik-demo"
    Environment = "dev"
  }
}

output "instance_ip" {
  value = aws_instance.traefik_instance.public_ip
}

