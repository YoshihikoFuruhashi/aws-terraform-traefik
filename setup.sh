#! /bin/bash
set -e

# Update the system and install Docker
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo service docker start
sudo usermod -a -G docker ec2-user

# Install Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/libexec/docker/cli-plugins/docker-compose
sudo chmod +x /usr/libexec/docker/cli-plugins/docker-compose

# Login to ECR
aws ecr get-login-password --region ap-northeast-1 | sudo docker login --username AWS --password-stdin 655474831190.dkr.ecr.ap-northeast-1.amazonaws.com

# Run Docker Compose
cd /home/ec2-user
sudo docker compose -f stack.yml up -d
