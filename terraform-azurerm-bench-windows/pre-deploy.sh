#!/bin/bash

# Dependencies: Azure CLI, Terraform

# Set these environment variables before running script
VM_ADMIN_PASSWORD_SECRET="adminpassword"
VM_ADMIN_USERNAME_SECRET="adminuser"
VM_DB_POST_DEPLOYMENT_SCRIPT_NAME="virtual-machine-03-post-deploy.ps1"
VM_WEB_POST_DEPLOYMENT_SCRIPT_NAME="virtual-machine-04-post-deploy.ps1"

# Set these environment variables by passing parameters to this script 
VM_ADMIN_PASSWORD=""
VM_ADMIN_USERNAME=""

# These are temporary variables 
BLOB_STORAGE_CONTAINER_NAME=""
LOG_ANALYTICS_WORKSPACE_ID=""
LOG_ANALYTICS_WORKSPACE_KEY=""
STORAGE_ACCOUNT_NAME=""
STORAGE_ACCOUNT_KEY=""
VAULT_NAME=""

usage() {
    printf "Usage: $0 \n  -u VM_ADMIN_USERNAME\n  -p VM_ADMIN_PASSWORD\n" 1>&2
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
            VM_ADMIN_PASSWORD=${OPTARG}
            ;;
        u )
            VM_ADMIN_USERNAME=${OPTARG}
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

if [ $? != 0 ]; then
    printf "Error: Terraform output variable log_analytics_workspace_01_primary_shared_key not found.\n"
    usage
fi

printf "Getting LOG_ANALYTICS_WORKSPACE_ID...\n"
LOG_ANALYTICS_WORKSPACE_ID=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" log_analytics_workspace_01_workspace_id)

if [ $? != 0 ]; then
    printf "Error: Terraform output variable log_analytics_workspace_01_workspace_id not found.\n"
    usage
fi

printf "Getting LOG_ANALYTICS_WORKSPACE_KEY...\n"
LOG_ANALYTICS_WORKSPACE_KEY=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" log_analytics_workspace_01_primary_shared_key)

if [ $? != 0 ]; then
    printf "Error: Terraform output variable log_analytics_workspace_01_primary_shared_key not found.\n"
    usage
fi

printf "Validating VM_ADMIN_USERNAME '${VM_ADMIN_USERNAME}'...\n"

if [[ -z {$VM_ADMIN_USERNAME} ]]; then
    printf "Error: Invalid VM_ADMIN_USERNAME.\n"
    usage
fi

printf "Validating VM_ADMIN_PASSWORD...\n"

if [[ -z {$VM_ADMIN_PASSWORD} ]]; then
    printf "Error: Invalid VM_ADMIN_PASSWORD.\n"
    usage
fi

printf "Setting secret '${VM_ADMIN_USERNAME_SECRET}'...\n"

az keyvault secret set --vault-name "${VAULT_NAME}" --name "${VM_ADMIN_USERNAME_SECRET}" --value "${VM_ADMIN_USERNAME}"

if [ $? != 0 ]; then
    printf "Error: Attempt to set secret '${VM_ADMIN_USERNAME_SECRET}' failed.\n"
    usage
fi

printf "Setting secret '${VM_ADMIN_PASSWORD_SECRET}'...\n"

az keyvault secret set --vault-name "${VAULT_NAME}" --name "${VM_ADMIN_PASSWORD_SECRET}" --value "${VM_ADMIN_PASSWORD}"

if [ $? != 0 ]; then
    printf "Error: Attempt to set secret '${VM_ADMIN_PASSWORD_SECRET}' failed.\n"
    usage
fi

printf "Setting secret '${LOG_ANALYTICS_WORKSPACE_ID}'...\n"

az keyvault secret set --vault-name "${VAULT_NAME}" --name "${LOG_ANALYTICS_WORKSPACE_ID}" --value "${LOG_ANALYTICS_WORKSPACE_KEY}"

if [ $? != 0 ]; then
    printf "Error: Attempt to set secret '${LOG_ANALYTICS_WORKSPACE_ID}' failed.\n"
    usage
fi

printf "Getting STORAGE_ACCOUNT_NAME...\n"

STORAGE_ACCOUNT_NAME=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" storage_account_01_name)

if [ $? != 0 ]; then
    printf "Error: Terraform output variable storage_account_01_name not found.\n"
    usage
fi

printf "Getting STORAGE_ACCOUNT_KEY...\n"

STORAGE_ACCOUNT_KEY=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" storage_account_01_key)

if [ $? != 0 ]; then
    printf "Error: Terraform output variable storage_account_01_key not found.\n"
    usage
fi

printf "Setting secret '${STORAGE_ACCOUNT_NAME}'...\n"

az keyvault secret set --vault-name "${VAULT_NAME}" --name "${STORAGE_ACCOUNT_NAME}" --value "${STORAGE_ACCOUNT_KEY}"

if [ $? != 0 ]; then
    printf "Error: Attempt to set secret '${STORAGE_ACCOUNT_NAME}' failed.\n"
    usage
fi

printf "Getting BLOB_STORAGE_CONTAINER_NAME...\n"

BLOB_STORAGE_CONTAINER_NAME=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" storage_countainer_01_name)

if [ $? != 0 ]; then
    printf "Error: Terraform output variable storage_countainer_01_name not found.\n"
    usage
fi

printf "Uploading database server post-deployment script...\n"

az storage blob upload \
  --account-name $STORAGE_ACCOUNT_NAME \
  --account-key $STORAGE_ACCOUNT_KEY \
  --container-name $BLOB_STORAGE_CONTAINER_NAME \
  --name $VM_DB_POST_DEPLOYMENT_SCRIPT_NAME \
  --file $VM_DB_POST_DEPLOYMENT_SCRIPT_NAME

if [ $? != 0 ]; then
    echo "Error: Failed to upload database server post-deployment script.\n"
    usage
fi

printf "Uploading web server post-deployment script...\n"

az storage blob upload \
  --account-name $STORAGE_ACCOUNT_NAME \
  --account-key $STORAGE_ACCOUNT_KEY \
  --container-name $BLOB_STORAGE_CONTAINER_NAME \
  --name $VM_WEB_POST_DEPLOYMENT_SCRIPT_NAME \
  --file $VM_WEB_POST_DEPLOYMENT_SCRIPT_NAME

if [ $? != 0 ]; then
    echo "Error: Failed to upload web server post-deployment script.\n"
    usage
fi

printf "Pre deployment operations completed.\n"

exit 0
