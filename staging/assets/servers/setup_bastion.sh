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

# Retrieve and store private key for SSH to ec2 instances
mkdir .confidentials
aws secretsmanager get-secret-value --secret-id "ansible4-hashivault-ssh-private" --query 'SecretBinary' \
| sed 's/"//g' | base64 --decode > .confidentials/ssh_private.pem
chmod 400 .confidentials/ssh_private.pem

# Retrieve and setup SSH to Playbooks GitHub
aws secretsmanager get-secret-value --secret-id "ansible4-hashivault-playbooks-private" --query 'SecretBinary' \
| sed 's/"//g' | base64 --decode > .confidentials/playbooks_private.pem
chmod 400 .confidentials/playbooks_private.pem

eval "$(ssh-agent -s)"
ssh-add .confidentials/playbooks_private.pem

export GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no"
git clone git@github.com:gitHub882000/ansible4-hashivault-playbooks.git
