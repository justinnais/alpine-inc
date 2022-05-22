# Scripts

## `run-ansible.sh`

This script gets the Terraform output of the database and web IP addresses, and creates an `inventory.yaml` file for Ansible.

It then packages the Notes application, before running the Ansible Playbook. We pass in parameters to use in our template file.

## `update-secrets.sh`

This script updates the GitHub Secrets by reading with `aws/credentials` file and passing the key value pairs to the GitHub CLI. This saves time from manually updating the secrets which we have to do every 4 hours.