#!/bin/bash

# Dependencies: Azure CLI, Terraform

# Set these environment variables before running script
SQL_ADMIN_PASSWORD_SECRET="adminpassword"
SQL_ADMIN_USERNAME_SECRET="adminuser"

# Set these environment variables by passing parameters to this script 
SQL_ADMIN_PASSWORD=""
SQL_ADMIN_USERNAME=""

# These are temporary variables 
BLOB_STORAGE_CONTAINER_NAME=""
LOG_ANALYTICS_WORKSPACE_ID=""
LOG_ANALYTICS_WORKSPACE_KEY=""
STORAGE_ACCOUNT_NAME=""
STORAGE_ACCOUNT_KEY=""
VAULT_NAME=""

usage() {
    printf "Usage: $0 \n  -u SQL_ADMIN_USERNAME\n  -p SQL_ADMIN_PASSWORD\n" 1>&2
    exit 1
}

if [[ $# -eq 0  ]]; then
    usage
fi  

while getopts ":hp:u:" option; do
    case "${option}" in
        h )
            usage
            ;;
        p )
            SQL_ADMIN_PASSWORD=${OPTARG}
            ;;
        u )
            SQL_ADMIN_USERNAME=${OPTARG}
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

printf "Getting VAULT_NAME...\n"
VAULT_NAME=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" key_vault_01_name)

if [ -z $VAULT_NAME ]; then
    printf "Error: Terraform output variable log_analytics_workspace_01_primary_shared_key not found.\n"
    usage
fi

printf "Validating SQL_ADMIN_USERNAME '${SQL_ADMIN_USERNAME}'...\n"

if [[ -z {$SQL_ADMIN_USERNAME} ]]; then
    printf "Error: Invalid SQL_ADMIN_USERNAME.\n"
    usage
fi

printf "Validating SQL_ADMIN_PASSWORD...\n"

if [[ -z {$SQL_ADMIN_PASSWORD} ]]; then
    printf "Error: Invalid SQL_ADMIN_PASSWORD.\n"
    usage
fi

printf "Setting secret '${SQL_ADMIN_USERNAME_SECRET}'...\n"

az keyvault secret set --vault-name "${VAULT_NAME}" --name "${SQL_ADMIN_USERNAME_SECRET}" --value "${SQL_ADMIN_USERNAME}"

if [ $? != 0 ]; then
    printf "Error: Attempt to set secret '${SQL_ADMIN_USERNAME_SECRET}' failed.\n"
    usage
fi

printf "Setting secret '${SQL_ADMIN_PASSWORD_SECRET}'...\n"

az keyvault secret set --vault-name "${VAULT_NAME}" --name "${SQL_ADMIN_PASSWORD_SECRET}" --value "${SQL_ADMIN_PASSWORD}"

if [ $? != 0 ]; then
    printf "Error: Attempt to set secret '${SQL_ADMIN_PASSWORD_SECRET}' failed.\n"
    usage
fi

printf "Pre deployment operations completed.\n"

exit 0
