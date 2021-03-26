#!/bin/bash

# Bootstraps deployment with pre-requisites for applying Terraform configurations
# Script is idempotent and can be run multiple times

usage() {
    printf "Usage: $0 \n" 1>&2
    exit 1
}

# Set these defaults prior to running the script.
default_vm_name="ubuntu-jumpbox-02"
default_admin_username_secret="adminuser"
default_admin_username="bootstrapadmin"
default_admin_password_secret="adminpassword"

# Intialize runtime defaults
state_file="../terraform-azurerm-vnet-shared/terraform.tfstate"
if [ ! -f $state_file ]
then
    printf "Unable to locate \"$state_file\"...\n"
    printf "See README.md for quick starts that must be deployed first...\n"
    usage
fi

default_subscription_id=$(terraform output -state=$state_file subscription_id)
default_resource_group_name=$(terraform output -state=$state_file resource_group_01_name)
default_location=$(terraform output -state=$state_file resource_group_01_location)
default_key_vault_id=$(terraform output -state=$state_file key_vault_01_id)
default_key_vault_name=$(terraform output -state=$state_file key_vault_01_name)
default_subnet_id=$(terraform output -state=$state_file vnet_shared_01_default_subnet_id)
default_tags=$(terraform output -json -state=$state_file resource_group_01_tags)

# Get user input
read -e -i $default_vm_name                   -p "vm name -------------------: " vm_name
read -e -i $default_admin_username_secret     -p "admin username secret -----: " admin_username_secret
read -e -i $default_admin_username            -p "admin username value ------: " admin_username
read -e -i $default_admin_password_secret     -p "admin password secret -----: " admin_password_secret
read -e -s                                    -p "admin password value ------: " admin_password
printf "password length ${#admin_password}\n"

vm_name=${vm_name:-$default_vm_name}
admin_username_secret=${admin_username_secret:-$default_admin_username_secret}
admin_username=${admin_username:-$default_admin_username}
admin_password_secret=${admin_password_secret:-$default_admin_password_secret}

# Generate SSH keys
printf "Gnerating SSH keys...\n"
echo -e 'y' | ssh-keygen -m PEM -t rsa -b 4096 -C "$admin_username" -f sshkeytemp -N "$admin_password" 
ssh_public_key_secret_name="$admin_username-ssh-key-public"
ssh_public_key_secret_value=$(cat sshkeytemp.pub)
ssh_private_key_secret_name="$admin_username-ssh-key-private"
ssh_private_key_secret_value=$(cat sshkeytemp)

# Bootstrap keyvault secrets
printf "Setting secret '$admin_username_secret' with value '$admin_username' in keyvault '$default_key_vault_name'...\n"
az keyvault secret set \
    --vault-name ${default_key_vault_name:1:-1} \
    --name $admin_username_secret \
    --value "$admin_username"

printf "Setting secret '$admin_password_secret' with value length '${#admin_password}' in keyvault '$default_key_vault_name'...\n"
az keyvault secret set \
    --vault-name ${default_key_vault_name:1:-1} \
    --name $admin_password_secret \
    --value "$admin_password" \
    --output none

printf "Setting secret '$ssh_public_key_secret_name' with value length \"${#ssh_public_key_secret_value}\" in keyvault '$default_key_vault_name'...\n"
az keyvault secret set \
    --vault-name ${default_key_vault_name:1:-1} \
    --name $ssh_public_key_secret_name \
    --value "$ssh_public_key_secret_value"

printf "Setting secret '$ssh_private_key_secret_name' with value length \"${#ssh_private_key_secret_value}\" in keyvault '$default_key_vault_name'...\n"
az keyvault secret set \
    --vault-name ${default_key_vault_name:1:-1} \
    --name $ssh_private_key_secret_name \
    --value "$ssh_private_key_secret_value" \
    --output none

# Generate terraform.tfvars file
printf "\nGenerating terraform.tfvars file...\n\n"

printf "admin_password_secret           = \"$admin_password_secret\"\n"             > ./terraform.tfvars
printf "admin_username_secret           = \"$admin_username_secret\"\n"             >> ./terraform.tfvars
printf "key_vault_id                    = $default_key_vault_id\n"                  >> ./terraform.tfvars
printf "key_vault_name                  = $default_key_vault_name\n"                >> ./terraform.tfvars
printf "location                        = $default_location\n"                      >> ./terraform.tfvars
printf "resource_group_name             = $default_resource_group_name\n"           >> ./terraform.tfvars
printf "ssh_public_key                  = \"$ssh_public_key_secret_value\"\n"       >> ./terraform.tfvars
printf "subnet_id                       = $default_subnet_id\n"                     >> ./terraform.tfvars
printf "subscription_id                 = $default_subscription_id\n"               >> ./terraform.tfvars
printf "tags                            = $default_tags\n"                          >> ./terraform.tfvars
printf "vm_name                         = \"$vm_name\"\n"                           >> ./terraform.tfvars

cat ./terraform.tfvars

printf "\nReview defaults in \"variables.tf\" prior to applying Terraform configurations...\n"
printf "\nBootstrapping complete...\n"

exit 0
