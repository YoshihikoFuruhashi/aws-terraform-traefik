#! /bin/bash

# Download Terraform
curl -LO https://releases.hashicorp.com/terraform/1.4.6/terraform_1.4.6_linux_amd64.zip

# Unzip and move Terraform binary to a directory in your PATH
sudo apt-get install unzip
unzip terraform_1.4.6_linux_amd64.zip
sudo mv terraform /usr/local/bin/
