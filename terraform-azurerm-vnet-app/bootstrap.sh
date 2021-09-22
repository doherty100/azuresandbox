#!/bin/bash

# Bootstraps deployment with pre-requisites for applying Terraform configurations
# Script is idempotent and can be run multiple times

usage() {
    printf "Usage: $0 \n" 1>&2
    exit 1
}

# Set these defaults prior to running the script.
default_vnet_name="vnet-app-01"
default_vnet_address_space="10.2.0.0/16"
default_database_subnet_name="snet-db-01"
default_database_subnet_address_prefix="10.2.0.0/27"
default_application_subnet_name="snet-app-01"
default_application_subnet_address_prefix="10.2.0.32/27"
default_privatelink_subnet_name="snet-private-endpoints-01"
default_privatelink_subnet_address_prefix="10.2.0.64/27"
default_vm_mssql_win_name="mssqlwin1"
vm_mssql_win_post_deploy_script="vm-mssql-win-post-deploy.ps1"
vm_mssql_win_sql_bootstrap_script="sql-bootstrap.ps1"
vm_mssql_win_sql_startup_script="sql-startup.ps1"

# Intialize runtime defaults
state_file="../terraform-azurerm-vnet-shared/terraform.tfstate"

printf "Retrieving runtime defaults from state file '$state_file'...\n"

if [ ! -f $state_file ]
then
    printf "Unable to locate \"$state_file\"...\n"
    printf "See README.md for quick starts that must be deployed first...\n"
    usage
fi

aad_tenant_id=$(terraform output -state=$state_file aad_tenant_id)
adds_domain_name=$(terraform output -state=$state_file adds_domain_name)
admin_password_secret=$(terraform output -state=$state_file admin_password_secret)
admin_username_secret=$(terraform output -state=$state_file admin_username_secret)
arm_client_id=$(terraform output -state=$state_file arm_client_id)
automation_account_name=$(terraform output -state=$state_file automation_account_name)
arm_client_id=$(terraform output -state=$state_file arm_client_id)
dns_server=$(terraform output -state=$state_file dns_server)
key_vault_id=$(terraform output -state=$state_file key_vault_id)
key_vault_name=$(terraform output -state=$state_file key_vault_name)
location=$(terraform output -state=$state_file location)
remote_virtual_network_id=$(terraform output -state=$state_file vnet_shared_01_id)
remote_virtual_network_name=$(terraform output -state=$state_file vnet_shared_01_name)
resource_group_name=$(terraform output -state=$state_file resource_group_name)
storage_account_name=$(terraform output -state=$state_file storage_account_name)
storage_container_name=$(terraform output -state=$state_file storage_container_name)
subscription_id=$(terraform output -state=$state_file subscription_id)
tags=$(terraform output -json -state=$state_file tags)

# User input
read -e -i $default_vnet_name                         -p "Virtual network name (vnet_name) --------------------------------------: " vnet_name
read -e -i $default_vnet_address_space                -p "Virtual network address space (vnet_address_space) --------------------: " vnet_address_space
read -e -i $default_database_subnet_name              -p "Database subnet name (database_subnet_name) ---------------------------: " database_subnet_name
read -e -i $default_database_subnet_address_prefix    -p "Database subnet address prefix (database_subnet_address_prefix) -------: " database_subnet_address_prefix
read -e -i $default_application_subnet_name           -p "Application subnet name (application_subnet_name) ---------------------: " application_subnet_name
read -e -i $default_application_subnet_address_prefix -p "Application subnet address prefix (application_subnet_address_prefix) -: " application_subnet_address_prefix
read -e -i $default_privatelink_subnet_name           -p "Privatelink subnet name (privatelink_subnet_name) ---------------------: " privatelink_subnet_name
read -e -i $default_privatelink_subnet_address_prefix -p "privatelink subnet address prefix (privatelink_subnet_address_prefix) -: " privatelink_subnet_address_prefix
read -e -i $default_vm_mssql_win_name                 -p "SQL Server virtual machine name (vm_mssql_win_name) -------------------: " vm_mssql_win_name

application_subnet_name=${application_subnet_name:-default_application_subnet_name}
application_subnet_address_prefix=${application_subnet_address_prefix:-default_application_subnet_address_prefix}
database_subnet_name=${database_subnet_name:-default_database_subnet_name}
database_subnet_address_prefix=${database_subnet_address_prefix:-default_database_subnet_address_prefix}
privatelink_subnet_name=${privatelink_subnet_name:-default_privatelink_subnet_name}
privatelink_subnet_address_prefix=${privatelink_subnet_address_prefix:-default_privatelink_subnet_address_prefix}
vm_mssql_win_name=${vm_mssql_win_name:-default_vm_mssql_win_name}
vnet_name=${vnet_name:=$default_vnet_name}
vnet_address_space=${vnet_address_space:-default_vnet_address_space}

# Upload post-deployment scripts
vm_mssql_win_post_deploy_script_uri="https://${storage_account_name:1:-1}.blob.core.windows.net/${storage_container_name:1:-1}/$vm_mssql_win_post_deploy_script"
vm_mssql_win_sql_bootstrap_script_uri="https://${storage_account_name:1:-1}.blob.core.windows.net/${storage_container_name:1:-1}/$vm_mssql_win_sql_bootstrap_script"
vm_mssql_win_sql_startup_script_uri="https://${storage_account_name:1:-1}.blob.core.windows.net/${storage_container_name:1:-1}/$vm_mssql_win_sql_startup_script"

printf "Getting storage account key for storage account '${storage_account_name:1:-1}' from key vault '${key_vault_name:1:-1}'...\n"
storage_account_key=$(az keyvault secret show --name ${storage_account_name:1:-1} --vault-name ${key_vault_name:1:-1} --query value --output tsv)

printf "Uploading post-deployment scripts to container '${storage_container_name:1:-1}' in storage account '${storage_account_name:1:-1}'...\n"
az storage blob upload-batch \
    --account-name ${storage_account_name:1:-1} \
    --account-key "$storage_account_key" \
    --destination ${storage_container_name:1:-1} \
    --source '.' \
    --pattern '*.ps1'

# Build subnet map
subnets=""
subnets="${subnets}{\n"
subnets="${subnets}  database = {\n"
subnets="${subnets}    name                                           = \"$database_subnet_name\",\n"
subnets="${subnets}    address_prefix                                 = \"$database_subnet_address_prefix\",\n"
subnets="${subnets}    enforce_private_link_endpoint_network_policies = false\n"
subnets="${subnets}  },\n"
subnets="${subnets}  application = {\n"
subnets="${subnets}    name                                           = \"$application_subnet_name\",\n"
subnets="${subnets}    address_prefix                                 = \"$application_subnet_address_prefix\",\n"
subnets="${subnets}    enforce_private_link_endpoint_network_policies = false\n"
subnets="${subnets}  },\n"
subnets="${subnets}  PrivateLink = {\n"
subnets="${subnets}    name                                           = \"$privatelink_subnet_name\",\n"
subnets="${subnets}    address_prefix                                 = \"$privatelink_subnet_address_prefix\",\n"
subnets="${subnets}    enforce_private_link_endpoint_network_policies = true\n"
subnets="${subnets}  }\n"
subnets="${subnets}}"

# Generate terraform.tfvars file
printf "\nGenerating terraform.tfvars file...\n\n"

printf "aad_tenant_id                           = $aad_tenant_id\n"                               > ./terraform.tfvars
printf "adds_domain_name                        = $adds_domain_name\n"                            >> ./terraform.tfvars
printf "admin_password_secret                   = $admin_password_secret\n"                       >> ./terraform.tfvars
printf "admin_username_secret                   = $admin_username_secret\n"                       >> ./terraform.tfvars
printf "arm_client_id                           = $arm_client_id\n"                               >> ./terraform.tfvars
printf "automation_account_name                 = $automation_account_name\n"                     >> ./terraform.tfvars
printf "dns_server                              = $dns_server\n"                                  >> ./terraform.tfvars
printf "key_vault_id                            = $key_vault_id\n"                                >> ./terraform.tfvars
printf "location                                = $location\n"                                    >> ./terraform.tfvars
printf "remote_virtual_network_id               = $remote_virtual_network_id\n"                   >> ./terraform.tfvars
printf "remote_virtual_network_name             = $remote_virtual_network_name\n"                 >> ./terraform.tfvars
printf "resource_group_name                     = $resource_group_name\n"                         >> ./terraform.tfvars
printf "storage_account_name                    = $storage_account_name\n"                        >> ./terraform.tfvars
printf "subnets                                 = $subnets\n"                                     >> ./terraform.tfvars
printf "subscription_id                         = $subscription_id\n"                             >> ./terraform.tfvars
printf "tags                                    = $tags\n"                                        >> ./terraform.tfvars
printf "vm_mssql_win_name                       = \"$vm_mssql_win_name\"\n"                       >> ./terraform.tfvars
printf "vm_mssql_win_post_deploy_script         = \"$vm_mssql_win_post_deploy_script\"\n"         >> ./terraform.tfvars
printf "vm_mssql_win_post_deploy_script_uri     = \"$vm_mssql_win_post_deploy_script_uri\"\n"     >> ./terraform.tfvars
printf "vm_mssql_win_sql_bootstrap_script       = \"$vm_mssql_win_sql_bootstrap_script\"\n"       >> ./terraform.tfvars
printf "vm_mssql_win_sql_bootstrap_script_uri   = \"$vm_mssql_win_sql_bootstrap_script_uri\"\n"   >> ./terraform.tfvars
printf "vm_mssql_win_sql_startup_script         = \"$vm_mssql_win_sql_startup_script\"\n"         >> ./terraform.tfvars
printf "vm_mssql_win_sql_startup_script_uri     = \"$vm_mssql_win_sql_startup_script_uri\"\n"     >> ./terraform.tfvars
printf "vnet_address_space                      = \"$vnet_address_space\"\n"                      >> ./terraform.tfvars
printf "vnet_name                               = \"$vnet_name\"\n"                               >> ./terraform.tfvars

cat ./terraform.tfvars

printf "\nReview defaults in \"variables.tf\" prior to applying Terraform configurations...\n"
printf "\nBootstrapping complete...\n"

exit 0
