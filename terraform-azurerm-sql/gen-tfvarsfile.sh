#!/bin/bash

# Set these environment variables before running script
SQL_ADMIN_PASSWORD_SECRET="adminpassword"
SQL_ADMIN_USERNAME_SECRET="adminuser"

# Set these environment variables by passing parameters to this script 
TAGS=""

# These are temporary variables
KEY_VAULT_ID=""
KEY_VAULT_NAME=""
LOCATION="" 
RESOURCE_GROUP_NAME=""
SQL_DATABASE_NAME=""

usage() {
    printf "Usage: $0\n  -d SQL_DATABASE_NAME\n  -t TAGS\n" 1>&2
    exit 1
}

if [[ $# -eq 0 ]]; then
    usage
fi  

while getopts ":d:t:" option; do
    case "${option}" in
        d )
            SQL_DATABASE_NAME=${OPTARG}
            ;;
        t )
            TAGS=${OPTARG}
            ;;
        : ) 
            printf "Error: -${OPTARG} requires an argument.\n"
            usage
            ;;
        * ) 
            printf "Error: Unknown option -${OPTARG}.\n"
            usage
            ;;
    esac
done

printf "Getting RESOURCE_GROUP_NAME...\n"
RESOURCE_GROUP_NAME=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" resource_group_01_name)

if [ -z $RESOURCE_GROUP_NAME  ]; then
    printf "Error: Terraform output variable resource_group_01_name not found.\n"
    usage
fi

printf "Getting LOCATION...\n"
LOCATION=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" resource_group_01_location)

if [ -z $LOCATION ]; then
    printf "Error: Terraform output variable resource_group_01_location not found.\n"
    usage
fi

printf "Getting KEY_VAULT_ID...\n"
KEY_VAULT_ID=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" key_vault_01_id)

if [ -z $KEY_VAULT_ID ]; then
    printf "Error: Terraform output variable key_vault_01_id not found.\n"
    usage
fi

printf "Getting KEY_VAULT_NAME...\n"
KEY_VAULT_NAME=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" key_vault_01_name)

if [ -z $KEY_VAULT_NAME ]; then
    printf "Error: Terraform output variable key_vault_01_name not found.\n"
    usage
fi

printf "Checking admin username secret...\n"
az keyvault secret show -n $SQL_ADMIN_USERNAME_SECRET --vault-name $KEY_VAULT_NAME

if [ $? != 0 ]; then
    printf "Error: No secret named '$SQL_ADMIN_USERNAME_SECRET' exists in key vault '$KEY_VAULT_NAME'."
    usage
fi

printf "Checking admin password secret...\n"
az keyvault secret show -n $SQL_ADMIN_PASSWORD_SECRET --vault-name $KEY_VAULT_NAME

if [ $? != 0 ]; then
    printf "Error: No secret named '$SQL_ADMIN_PASSWORD_SECRET' exists in key vault '$KEY_VAULT_NAME'."
    usage
fi

printf "Validating SQL_DATABASE_NAME '${SQL_DATABASE_NAME}'...\n"

if [[ -z ${SQL_DATABASE_NAME} ]]; then
    printf "Error: Invalid SQL_DATABASE_NAME.\n"
    usage
fi

printf "Validating TAGS '${TAGS}'...\n"

if [[ -z ${TAGS} ]]; then
    printf "Error: Invalid TAGS.\n"
    usage
fi

# Write values out to terraform.tfvars file

printf "\Generating terraform.tfvars file...\n\n"

printf "key_vault_id = \"$KEY_VAULT_ID\"\n" > ./terraform.tfvars
printf "location = \"$LOCATION\"\n" >> ./terraform.tfvars
printf "resource_group_name = \"$RESOURCE_GROUP_NAME\"\n" >> ./terraform.tfvars
printf "tags = $TAGS\n" >> ./terraform.tfvars
printf "sql_admin_password_secret = \"$SQL_ADMIN_PASSWORD_SECRET\"\n" >> ./terraform.tfvars
printf "sql_admin_username_secret = \"$SQL_ADMIN_USERNAME_SECRET\"\n" >> ./terraform.tfvars
printf "sql_database_name = \"$SQL_DATABASE_NAME\"\n" >> ./terraform.tfvars

printf "Generated terraform.tfvars file:\n\n"

cat ./terraform.tfvars
exit 0
