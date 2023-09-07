<!-- openssl genrsa -out ansible_key_pair.pem 2048
openssl rsa -in ansible_key_pair.pem -pubout -out ansible_public_key.pub && echo $(ssh-keygen -y -f private_key1.pem > public_key1.pub ansible_public_key.pub) > ansible_public_key.pub
chmod u+x ansible_key_pair.pem ansible_public_key.pub -->

ssh-keygen -t rsa -b 2048 -f ansible_key.pem
chmod u+x ansible_key.pem ansible_key.pem.pub

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ../assets/hashivault.pem -out ../assets/hashivault.crt

export VAULT_ADDR=https://vault.lab.aandd.io:8200
