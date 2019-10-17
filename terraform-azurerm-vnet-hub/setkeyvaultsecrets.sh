#!/bin/bash

# Dependencies: Azure CLI, Terraform

# Set these environment variables before running script
VM_ADMIN_PASSWORD_SECRET="adminpassword"
VM_ADMIN_USERNAME_SECRET="adminuser"

# Set these environment variables by passing parameters to this script 
VM_ADMIN_PASSWORD=""
VM_ADMIN_USERNAME=""

# These are temporary variables 
LOG_ANALYTICS_WORKSPACE_ID=""
LOG_ANALYTICS_WORKSPACE_KEY=""
VAULT_NAME=""

usage() {
    printf "Usage: $0 \n  -u VM_ADMIN_USERNAME\n  -p VM_ADMIN_PASSWORD\n" 1>&2
    exit 1
}

if [[ $# -eq 0  ]]; then
    usage
fi  

while getopts ":p:u:" option; do
    case "${option}" in
        p )
            VM_ADMIN_PASSWORD=${OPTARG}
            ;;
        u )
            VM_ADMIN_USERNAME=${OPTARG}
            ;;
        \? )
            usage
            ;;
        : ) 
            echo "Error: -${OPTARG} requires an argument."
            usage
            ;;
    esac
done

printf "Validating VM_ADMIN_USERNAME '${VM_ADMIN_USERNAME}'...\n"

if [[ -z {$VM_ADMIN_USERNAME} ]]; then
    printf "Error: Invalid VM_ADMIN_USERNAME.\n"
    usage
fi

printf "Validating VM_ADMIN_PASSWORD '${VM_ADMIN_PASSWORD}'...\n"

if [[ -z {$VM_ADMIN_PASSWORD} ]]; then
    printf "Error: Invalid VM_ADMIN_PASSWORD.\n"
    usage
fi

printf "Getting LOG_ANALYTICS_WORKSPACE_ID...\n"
LOG_ANALYTICS_WORKSPACE_ID=$(terraform output log_analytics_workspace_01_workspace_id)

printf "Validating LOG_ANALYTICS_WORKSPACE_ID '${LOG_ANALYTICS_WORKSPACE_ID}'...\n"

if [[ -z {$LOG_ANALYTICS_WORKSPACE_ID} ]]; then
    printf "Error: Invalid LOG_ANALYTICS_WORKSPACE_ID, check Terraform output variable log_analytics_workspace_01_workspace_id.\n"
    usage
fi

printf "Getting LOG_ANALYTICS_WORKSPACE_KEY...\n"
LOG_ANALYTICS_WORKSPACE_KEY=$(terraform output log_analytics_workspace_01_primary_shared_key)

printf "Validating LOG_ANALYTICS_WORKSPACE_KEY '${LOG_ANALYTICS_WORKSPACE_KEY}'...\n"

if [[ -z {$LOG_ANALYTICS_WORKSPACE_KEY} ]]; then
    printf "Error: Invalid LOG_ANALYTICS_WORKSPACE_KEY, check Terraform output variable log_analytics_workspace_01_primary_shared_key.\n"
    usage
fi

printf "Getting key vault name...\n"
VAULT_NAME=$(terraform output key_vault_01_name)

printf "Validating VAULT_NAME '${VAULT_NAME}'...\n"

if [[ -z {$VAULT_NAME} ]]; then
    printf "Error: Invalid VAULT_NAME, check Terraform output variable key_vault_01_name.\n"
    usage
fi

printf "Setting secret '${VM_ADMIN_USERNAME_SECRET}'...\n"

az keyvault secret set --vault-name "${VAULT_NAME}" --name "${VM_ADMIN_USERNAME_SECRET}" --value "${VM_ADMIN_USERNAME}"

if [ $? != 0 ]; then
    printf "Error: Attempt to set secret '${VM_ADMIN_USERNAME_SECRET}' failed."
    usage
fi

printf "Setting secret '${VM_ADMIN_PASSWORD_SECRET}'...\n"

az keyvault secret set --vault-name "${VAULT_NAME}" --name "${VM_ADMIN_PASSWORD_SECRET}" --value "${VM_ADMIN_PASSWORD}"

if [ $? != 0 ]; then
    printf "Error: Attempt to set secret '${VM_ADMIN_PASSWORD_SECRET}' failed."
    usage
fi

printf "Setting secret '${LOG_ANALYTICS_WORKSPACE_ID}'...\n"

az keyvault secret set --vault-name "${VAULT_NAME}" --name "${LOG_ANALYTICS_WORKSPACE_ID}" --value "${LOG_ANALYTICS_WORKSPACE_KEY}"

if [ $? != 0 ]; then
    printf "Error: Attempt to set secret '${LOG_ANALYTICS_WORKSPACE_ID}' failed."
    usage
fi

printf "Key vault secrets set successfully.\n"

exit 0