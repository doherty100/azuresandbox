#!/bin/bash

# Bootstraps deployment with pre-requisites for applying Terraform configurations
# Script is idempotent and can be run multiple times

usage() {
    printf "Usage: $0 \n" 1>&2
    exit 1
}

# Set these defaults prior to running the script.
default_admin_username_secret="adminuser"
default_admin_username="bootstrapadmin"
default_admin_password_secret="adminpassword"
default_sql_database_name="sqldb-benchmarktest-01"

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
default_tags=$(terraform output -json -state=$state_file resource_group_01_tags)

state_file="../terraform-azurerm-vnet-spoke/terraform.tfstate"
if [ ! -f $state_file ]
then
    printf "Unable to locate \"$state_file\"...\n"
    printf "See README.md for quick starts that must be deployed first...\n"
    usage
fi

default_private_endpoints_subnet_id=$(terraform output -state=$state_file vnet_spoke_01_private_endpoints_subnet_id)
default_vnet_id=$(terraform output -state=$state_file vnet_spoke_01_id)
default_vnet_name=$(terraform output -state=$state_file vnet_spoke_01_name)

# Get user input
read -e -i $default_sql_database_name       -p "sql database name -----: " sql_database_name
read -e -i $default_admin_username_secret   -p "admin username secret -: " admin_username_secret
read -e -i $default_admin_username          -p "admin username value --: " admin_username
read -e -i $default_admin_password_secret   -p "admin password secret -: " admin_password_secret
read -e -s                                  -p "admin password value --: " admin_password
printf "password length ${#admin_password}\n"

sql_database_name=${sql_database_name:-$default_sql_database_name}
admin_username_secret=${admin_username_secret:-$default_admin_username_secret}
admin_username=${admin_username:-$default_admin_username}
admin_password_secret=${admin_password_secret:-$default_admin_password_secret}

# Bootstrap keyvault secrets
printf "Setting secret \"$admin_username_secret\" with value \"$admin_username\" in keyvault $default_key_vault_name...\n"
az keyvault secret set --vault-name ${default_key_vault_name:1:-1} --name $admin_username_secret --value "$admin_username"

printf "Setting secret \"$admin_password_secret\" with value length \"${#admin_password}\" in keyvault $default_key_vault_name...\n"
az keyvault secret set --vault-name ${default_key_vault_name:1:-1} --name $admin_password_secret --value "$admin_password"

# Generate terraform.tfvars file
printf "\nGenerating terraform.tfvars file...\n\n"

printf "admin_password_secret =         \"$admin_password_secret\"\n"           > ./terraform.tfvars
printf "admin_username_secret =         \"$admin_username_secret\"\n"           >> ./terraform.tfvars
printf "key_vault_id =                  $default_key_vault_id\n"                >> ./terraform.tfvars
printf "location =                      $default_location\n"                    >> ./terraform.tfvars
printf "private_endpoints_subnet_id =   $default_private_endpoints_subnet_id\n" >> ./terraform.tfvars
printf "resource_group_name =           $default_resource_group_name\n"         >> ./terraform.tfvars
printf "sql_database_name =             \"$sql_database_name\"\n"               >> ./terraform.tfvars
printf "tags =                          $default_tags\n"                        >> ./terraform.tfvars
printf "vnet_id =                       $default_vnet_id\n"                     >> ./terraform.tfvars
printf "vnet_name =                     $default_vnet_name\n"                   >> ./terraform.tfvars

cat ./terraform.tfvars

printf "\nReview defaults in \"variables.tf\" prior to applying Terraform plans...\n"
printf "\nBootstrapping complete...\n"

exit 0
