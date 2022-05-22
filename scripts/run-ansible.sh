#!/bin/bash
set +ex

db_public_ip=$(cd ../infra && terraform output db_public_ip)
web_public_ip=$(cd ../infra && terraform output web_public_ip)
app_path="/var/www/package"
service_path="/usr/lib/systemd/system"

echo -e "all:\n  hosts:\n    web:\n      ansible_host: $web_public_ip\n    db:\n      ansible_host: $db_public_ip" >../ansible/inventories/inventory.yml

cd .. && make pack
cd scripts

# Passing --check command through for pipeline dry run

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -v -i ../ansible/inventories/inventory.yml \
  -e 'record_host_keys=True' -u ec2-user --private-key='/tmp/keys/ec2-key' \
  ../ansible/playbook.yml -e "db_url=$db_public_ip" -e "web_url=$web_public_ip" \
  -e "app_path"=$app_path -e "service_path"=$service_path $1
