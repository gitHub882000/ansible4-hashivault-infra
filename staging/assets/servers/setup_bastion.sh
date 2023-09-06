#!/bin/bash
# Install Ansible
apt-add-repository ppa:ansible/ansible -y
apt update
apt install ansible -y

# Install AWS CLI
cd /home/ubuntu/
apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install

# Retrieve and store private keys
mkdir .confidentials
aws secretsmanager get-secret-value --secret-id "ansible4-hashivault-ssh-private" --query 'SecretBinary' \
| sed 's/"//g' | base64 --decode > .confidentials/ssh_private.pem
chmod -400 .confidentials/ssh_private.pem