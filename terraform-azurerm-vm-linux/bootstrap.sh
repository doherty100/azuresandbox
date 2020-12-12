#!/bin/bash

# Bootstraps deployment with pre-requisites for applying Terraform configurations
# Script is idempotent and can be run multiple times

usage() {
    printf "Usage: $0 \n" 1>&2
    exit 1
}

# Set these defaults prior to running the script.
default_vm_name="ubuntu-jumpbox-02"
default_app_vm_post_deploy_script="post-deploy-app-vm.sh"
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

default_resource_group_name=$(terraform output -state=$state_file resource_group_01_name)
default_location=$(terraform output -state=$state_file resource_group_01_location)
default_key_vault_id=$(terraform output -state=$state_file key_vault_01_id)
default_key_vault_name=$(terraform output -state=$state_file key_vault_01_name)
default_log_analytics_workspace_id=$(terraform output -state=$state_file log_analytics_workspace_01_workspace_id)
default_law_workspace_key=$(terraform output -state=$state_file log_analytics_workspace_01_primary_shared_key)
default_subnet_id=$(terraform output -state=$state_file vnet_shared_01_default_subnet_id)
default_storage_account_name=$(terraform output -state=$state_file storage_account_01_name)
default_storage_account_key=$(terraform output -state=$state_file storage_account_01_key)
default_blob_storage_endpoint=$(terraform output -state=$state_file storage_account_01_blob_endpoint)
default_blob_storage_container_name=$(terraform output -state=$state_file storage_container_01_name)
default_tags=$(terraform output -json -state=$state_file resource_group_01_tags)

# Get user input
read -e -i $default_vm_name                   -p "vm name -------------------: " vm_name
read -e -i $default_app_vm_post_deploy_script -p "app vm post deploy script -: " app_vm_post_deploy_script
read -e -i $default_admin_username_secret     -p "admin username secret -----: " admin_username_secret
read -e -i $default_admin_username            -p "admin username value ------: " admin_username
read -e -i $default_admin_password_secret     -p "admin password secret -----: " admin_password_secret
read -e -s                                    -p "admin password value ------: " admin_password
printf "password length ${#admin_password}\n"

vm_name=${vm_name:-$default_vm_name}
app_vm_post_deploy_script=${app_vm_post_deploy_script:-$default_app_vm_post_deploy_script}
admin_username_secret=${admin_username_secret:-$default_admin_username_secret}
admin_username=${admin_username:-$default_admin_username}
admin_password_secret=${admin_password_secret:-$default_admin_password_secret}
app_vm_post_deploy_script_uri="https://${default_storage_account_name:1:-1}.blob.core.windows.net/${default_blob_storage_container_name:1:-1}/$app_vm_post_deploy_script"

# Bootstrap keyvault secrets
printf "Setting secret \"$admin_username_secret\" with value \"$admin_username\" in keyvault $default_key_vault_name...\n"
az keyvault secret set --vault-name ${default_key_vault_name:1:-1} --name $admin_username_secret --value "$admin_username"

printf "Setting secret \"$admin_password_secret\" with value length \"${#admin_password}\" in keyvault $default_key_vault_name...\n"
az keyvault secret set --vault-name ${default_key_vault_name:1:-1} --name $admin_password_secret --value "$admin_password"

printf "Setting log analytics secret $default_log_analytics_workspace_id with value $default_law_workspace_key in keyvault $default_key_vault_name...\n"
az keyvault secret set --vault-name ${default_key_vault_name:1:-1} --name ${default_log_analytics_workspace_id:1:-1} --value "${default_law_workspace_key:1:-1}"

printf "Setting storage account secret $default_storage_account_name with value $default_storage_account_key to keyvault $default_key_vault_name...\n"
az keyvault secret set --vault-name ${default_key_vault_name:1:-1} --name ${default_storage_account_name:1:-1} --value "${default_storage_account_key:1:-1}"

# Upload post-deployment scripts

printf "Uploading post-deployment scripts to container $default_blob_storage_container_name in storage account $default_storage_account_name...\n"
az storage blob upload-batch \
    --account-name ${default_storage_account_name:1:-1} \
    --account-key ${default_storage_account_key:1:-1} \
    --destination ${default_blob_storage_container_name:1:-1} \
    --source '.' \
    --pattern 'post-deploy-app-vm.sh'

# Generate terraform.tfvars file
printf "\nGenerating terraform.tfvars file...\n\n"

printf "admin_password_secret = \"$admin_password_secret\"\n"                 > ./terraform.tfvars
printf "admin_username_secret = \"$admin_username_secret\"\n"                 >> ./terraform.tfvars
printf "app_vm_post_deploy_script_name = \"$app_vm_post_deploy_script\"\n"    >> ./terraform.tfvars
printf "app_vm_post_deploy_script_uri = \"$app_vm_post_deploy_script_uri\"\n" >> ./terraform.tfvars
printf "key_vault_id = $default_key_vault_id\n"                               >> ./terraform.tfvars
printf "key_vault_name = $default_key_vault_name\n"                           >> ./terraform.tfvars
printf "location = $default_location\n"                                       >> ./terraform.tfvars
printf "log_analytics_workspace_id = $default_log_analytics_workspace_id\n"   >> ./terraform.tfvars
printf "resource_group_name = $default_resource_group_name\n"                 >> ./terraform.tfvars
printf "storage_account_name = $default_storage_account_name\n"               >> ./terraform.tfvars
printf "subnet_id = $default_subnet_id\n"                                     >> ./terraform.tfvars
printf "tags = $default_tags\n"                                               >> ./terraform.tfvars
printf "vm_name = \"$vm_name\"\n"                                             >> ./terraform.tfvars

cat ./terraform.tfvars

printf "\nReview defaults in \"variables.tf\" prior to applying Terraform configurations...\n"
printf "\nBootstrapping complete...\n"

exit 0
