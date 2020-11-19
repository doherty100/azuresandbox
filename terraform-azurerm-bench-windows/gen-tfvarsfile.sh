#!/bin/bash

# Set these environment variables before running script
VM_ADMIN_PASSWORD_SECRET="adminpassword"
VM_ADMIN_USERNAME_SECRET="adminuser"
VM_DB_IMAGE_OFFER="sql2019-ws2019"
VM_DB_IMAGE_PUBLISHER="MicrosoftSQLServer"
VM_DB_POST_DEPLOY_SCRIPT_NAME="virtual-machine-03-post-deploy.ps1"
VM_DB_STORAGE_REPLICATION_TYPE="StandardSSD_LRS"
VM_APP_IMAGE_OFFER="WindowsServer"
VM_APP_IMAGE_PUBLISHER="MicrosoftWindowsServer"
VM_APP_POST_DEPLOY_SCRIPT_NAME="virtual-machine-04-post-deploy.ps1"
VM_APP_STORAGE_REPLICATION_TYPE="Standard_LRS"
VM_SQL_STARTUP_SCRIPT_NAME="SQL-startup.ps1"

# Set these environment variables by passing parameters to this script 
TAGS=""
VM_DB_DATA_DISK_CONFIG=""
VM_DB_IMAGE_SKU=""
VM_DB_SIZE=""
VM_NAME_PREFIX=""
VM_APP_IMAGE_SKU=""
VM_APP_SIZE=""

# These are temporary variables
BLOB_STORAGE_ENDPOINT=""
BLOB_STORAGE_CONTAINER_NAME=""
KEY_VAULT_ID=""
KEY_VAULT_NAME=""
LOCATION="" 
LOG_ANALYTICS_WORKSPACE_ID=""
RESOURCE_GROUP_NAME=""
STORAGE_ACCOUNT_KEY=""
STORAGE_ACCOUNT_NAME=""
VM_APP_POST_DEPLOY_SCRIPT_URI=""
VM_APP_SUBNET_ID=""
VM_DB_SUBNET_ID=""
VM_DB_POST_DEPLOY_SCRIPT_URI=""
VM_IMAGE_ID=""
VM_SIZE_PROPERTIES=""
VM_SQL_STARTUP_SCRIPT_URI=""

usage() {
    printf "Usage: $0\n  -n VM_NAME_PREFIX\n  -s VM_DB_IMAGE_SKU\n  -z VM_DB_SIZE\n  -c VM_DB_DATA_DISK_CONFIG\n  -S VM_APP_IMAGE_SKU\n  -Z VM_APP_SIZE\n  --t TAGS\n" 1>&2
    exit 1
}

if [[ $# -eq 0 ]]; then
    usage
fi  

while getopts ":c:d:hn:s:S:t:z:Z:" option; do
    case "${option}" in
        c )
            VM_DB_DATA_DISK_CONFIG=${OPTARG}
            ;;
        h )
            usage
            ;;
        n ) 
            VM_NAME_PREFIX=${OPTARG}
            ;;
        s ) 
            VM_DB_IMAGE_SKU=${OPTARG}
            ;;
        S ) 
            VM_APP_IMAGE_SKU=${OPTARG}
            ;;
        t )
            TAGS=${OPTARG}
            ;;
        z )
            VM_DB_SIZE=${OPTARG}
            ;;
        Z )
            VM_APP_SIZE=${OPTARG}
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

printf "Getting LOG_ANALYTICS_WORKSPACE_ID...\n"

LOG_ANALYTICS_WORKSPACE_ID=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" log_analytics_workspace_01_workspace_id)

if [ -z $LOG_ANALYTICS_WORKSPACE_ID ]; then
    printf "Error: Terraform output variable log_analytics_workspace_01_workspace_id not found.\n"
    usage
fi

printf "Getting VM_APP_SUBNET_ID...\n"
VM_APP_SUBNET_ID=$(terraform output -state="../terraform-azurerm-vnet-spoke/terraform.tfstate" vnet_spoke_01_app_subnet_id)

if [ -z $VM_APP_SUBNET_ID ]; then
    printf "Error: Terraform output variable vnet_spoke_01_app_subnet_id not found.\n"
    usage
fi

printf "Getting VM_DB_SUBNET_ID...\n"
VM_DB_SUBNET_ID=$(terraform output -state="../terraform-azurerm-vnet-spoke/terraform.tfstate" vnet_spoke_01_db_subnet_id)

if [ -z $VM_DB_SUBNET_ID ]; then
    printf "Error: Terraform output variable vnet_spoke_01_db_subnet_id not found.\n"
    usage
fi

printf "Getting LOCATION...\n"
LOCATION=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" resource_group_01_location)

if [ -z $LOCATION ]; then
    printf "Error: Terraform output variable resource_group_01_location not found.\n"
    usage
fi

printf "Getting STORAGE_ACCOUNT_NAME...\n"

STORAGE_ACCOUNT_NAME=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" storage_account_01_name)

if [ -z $STORAGE_ACCOUNT_NAME ]; then
    printf "Error: Terraform output variable storage_account_01_name not found.\n"
    usage
fi

printf "Getting STORAGE_ACCOUNT_KEY...\n"

STORAGE_ACCOUNT_KEY=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" storage_account_01_key)

if [ -z $STORAGE_ACCOUNT_KEY ]; then
    printf "Error: Terraform output variable storage_account_01_key not found.\n"
    usage
fi

printf "Getting BLOB_STORAGE_ENDPOINT...\n"

BLOB_STORAGE_ENDPOINT=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" storage_account_01_blob_endpoint)

if [ -z $BLOB_STORAGE_ENDPOINT ]; then
    printf "Error: Terraform output variable storage_account_01_blob_endpoint not found.\n"
    usage
fi

printf "Getting BLOB_STORAGE_CONTAINER_NAME...\n"

BLOB_STORAGE_CONTAINER_NAME=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" storage_container_01_name)

if [ -z $BLOB_STORAGE_CONTAINER_NAME ]; then
    printf "Error: Terraform output variable storage_container_01_name not found.\n"
    usage
fi

printf "Checking admin username secret...\n"
az keyvault secret show -n $VM_ADMIN_USERNAME_SECRET --vault-name $KEY_VAULT_NAME

if [ $? != 0 ]; then
    printf "Error: No secret named '$VM_ADMIN_USERNAME_SECRET' exists in key vault '$KEY_VAULT_NAME'."
    usage
fi

printf "Checking admin password secret...\n"
az keyvault secret show -n $VM_ADMIN_PASSWORD_SECRET --vault-name $KEY_VAULT_NAME

if [ $? != 0 ]; then
    printf "Error: No secret named '$VM_ADMIN_PASSWORD_SECRET' exists in key vault '$KEY_VAULT_NAME'."
    usage
fi

printf "Checking log analytics workspaceKey secret...\n"
az keyvault secret show -n $LOG_ANALYTICS_WORKSPACE_ID --vault-name $KEY_VAULT_NAME

if [ $? != 0 ]; then
    printf "Error: No secret named '$LOG_ANALYTICS_WORKSPACE_ID' exists in key vault '$KEY_VAULT_NAME'.\n"
    usage
fi

printf "Checking storage account key secret...\n"
az keyvault secret show -n $STORAGE_ACCOUNT_NAME --vault-name $KEY_VAULT_NAME

if [ $? != 0 ]; then
    printf "Error: No secret named '$STORAGE_ACCOUNT_NAME' exists in key vault '$KEY_VAULT_NAME'.\n"
    usage
fi

printf "Checking that '${VM_DB_POST_DEPLOY_SCRIPT_NAME}' exists in container '$BLOB_STORAGE_CONTAINER_NAME'...\n"

az storage blob show \
  --account-name $STORAGE_ACCOUNT_NAME\
  --account-key $STORAGE_ACCOUNT_KEY\
  --container-name $BLOB_STORAGE_CONTAINER_NAME\
  --name $VM_DB_POST_DEPLOY_SCRIPT_NAME

if [ $? != 0 ]; then
    printf "Error: Post-deployment script '${VM_DB_POST_DEPLOY_SCRIPT_NAME}' missing from container '$BLOB_STORAGE_CONTAINER_NAME'.\n"
    usage
fi

VM_DB_POST_DEPLOY_SCRIPT_URI="${BLOB_STORAGE_ENDPOINT}${BLOB_STORAGE_CONTAINER_NAME}/${VM_DB_POST_DEPLOY_SCRIPT_NAME}"

printf "Checking that '${VM_APP_POST_DEPLOY_SCRIPT_NAME}' exists in container '$BLOB_STORAGE_CONTAINER_NAME'...\n"

az storage blob show \
  --account-name $STORAGE_ACCOUNT_NAME\
  --account-key $STORAGE_ACCOUNT_KEY\
  --container-name $BLOB_STORAGE_CONTAINER_NAME\
  --name $VM_APP_POST_DEPLOY_SCRIPT_NAME

if [ $? != 0 ]; then
    printf "Error: Post-deployment script '${VM_APP_POST_DEPLOY_SCRIPT_NAME}' missing from container '$BLOB_STORAGE_CONTAINER_NAME'.\n"
    usage
fi

VM_APP_POST_DEPLOY_SCRIPT_URI="${BLOB_STORAGE_ENDPOINT}${BLOB_STORAGE_CONTAINER_NAME}/${VM_APP_POST_DEPLOY_SCRIPT_NAME}"

printf "Checking that '${VM_SQL_STARTUP_SCRIPT_NAME}' exists in container '$BLOB_STORAGE_CONTAINER_NAME'...\n"

az storage blob show \
  --account-name $STORAGE_ACCOUNT_NAME\
  --account-key $STORAGE_ACCOUNT_KEY\
  --container-name $BLOB_STORAGE_CONTAINER_NAME\
  --name $VM_SQL_STARTUP_SCRIPT_NAME

if [ $? != 0 ]; then
    printf "Error: Script '${VM_SQL_STARTUP_SCRIPT_NAME}' missing from container '$BLOB_STORAGE_CONTAINER_NAME'.\n"
    usage
fi

VM_SQL_STARTUP_SCRIPT_URI="${BLOB_STORAGE_ENDPOINT}${BLOB_STORAGE_CONTAINER_NAME}/${VM_SQL_STARTUP_SCRIPT_NAME}"

printf "Validating VM_NAME_PREFIX '${VM_NAME_PREFIX}'...\n"
if [ -z $VM_NAME_PREFIX ]; then
    printf "Error: Invalid VM_NAME_PREFIX."
    usage
fi

printf "Validating VM_DB_IMAGE_SKU '${VM_DB_IMAGE_SKU}'...\n"

VM_IMAGE_ID=$(az vm image list-skus -l $LOCATION -p $VM_DB_IMAGE_PUBLISHER -f $VM_DB_IMAGE_OFFER --query "[?name=='${VM_DB_IMAGE_SKU}'].id" | tr -d '[]" \n')

if [ -z $VM_IMAGE_ID ]; then
    printf "Error: Virtual machine sku $VM_DB_IMAGE_SKU is not valid."
    usage
fi

printf "Validating VM_APP_IMAGE_SKU '${VM_APP_IMAGE_SKU}'...\n"

VM_IMAGE_ID=$(az vm image list-skus -l $LOCATION -p $VM_APP_IMAGE_PUBLISHER -f $VM_APP_IMAGE_OFFER --query "[?name=='${VM_APP_IMAGE_SKU}'].id" | tr -d '[]" \n')

if [ -z $VM_IMAGE_ID ]; then
    printf "Error: Virtual machine sku $VM_APP_IMAGE_SKU is not valid."
    usage
fi

printf "Validating VM_DB_SIZE '${VM_DB_SIZE}'...\n"

VM_SIZE_PROPERTIES=""
VM_SIZE_PROPERTIES=$(az vm list-sizes -l $LOCATION --query "[?name=='${VM_DB_SIZE}']")

if [ "$VM_DB_SIZE_PROPERTIES" = "[]" ]; then
    printf "Error: Virtual machine size '${VM_DB_SIZE}' is not valid."
    usage
fi

printf "Validating VM_APP_SIZE '${VM_APP_SIZE}'...\n"

VM_SIZE_PROPERTIES=""
VM_SIZE_PROPERTIES=$(az vm list-sizes -l $LOCATION --query "[?name=='${VM_DB_SIZE}']")

if [ "$VM_DB_SIZE_PROPERTIES" = "[]" ]; then
    printf "Error: Virtual machine size '${VM_DB_SIZE}' is not valid."
    usage
fi

printf "Validating TAGS '${TAGS}'...\n"

if [[ -z ${TAGS} ]]; then
    printf "Error: Invalid TAGS.\n"
    usage
fi

printf "Validating VM_DB_DATA_DISK_CONFIG '${VM_DB_DATA_DISK_CONFIG}'...\n"

if [[ -z ${TAGS} ]]; then
    printf "Error: Invalid VM_DB_DATA_DISK_CONFIG.\n"
    usage
fi

# Write values out to terraform.tfvars file

printf "\Generating terraform.tfvars file...\n\n"

printf "key_vault_id = \"$KEY_VAULT_ID\"\n" > ./terraform.tfvars
printf "key_vault_name = \"$KEY_VAULT_NAME\"\n" >> ./terraform.tfvars
printf "location = \"$LOCATION\"\n" >> ./terraform.tfvars
printf "log_analytics_workspace_id = \"$LOG_ANALYTICS_WORKSPACE_ID\"\n" >> ./terraform.tfvars
printf "resource_group_name = \"$RESOURCE_GROUP_NAME\"\n" >> ./terraform.tfvars
printf "storage_account_name = \"$STORAGE_ACCOUNT_NAME\"\n" >> ./terraform.tfvars
printf "vm_db_subnet_id = \"$VM_DB_SUBNET_ID\"\n" >> ./terraform.tfvars
printf "tags = $TAGS\n" >> ./terraform.tfvars
printf "vm_admin_password_secret = \"$VM_ADMIN_PASSWORD_SECRET\"\n" >> ./terraform.tfvars
printf "vm_admin_username_secret = \"$VM_ADMIN_USERNAME_SECRET\"\n" >> ./terraform.tfvars
printf "vm_app_image_offer = \"$VM_APP_IMAGE_OFFER\"\n" >> ./terraform.tfvars
printf "vm_app_image_publisher = \"$VM_APP_IMAGE_PUBLISHER\"\n" >> ./terraform.tfvars
printf "vm_app_image_sku = \"$VM_APP_IMAGE_SKU\"\n" >> ./terraform.tfvars
printf "vm_app_name = \"${VM_NAME_PREFIX}app01\"\n" >> ./terraform.tfvars
printf "vm_app_post_deploy_script_name = \"$VM_APP_POST_DEPLOY_SCRIPT_NAME\"\n" >> ./terraform.tfvars
printf "vm_app_post_deploy_script_uri = \"$VM_APP_POST_DEPLOY_SCRIPT_URI\"\n" >> ./terraform.tfvars
printf "vm_app_size = \"$VM_APP_SIZE\"\n" >> ./terraform.tfvars
printf "vm_app_storage_replication_type = \"$VM_APP_STORAGE_REPLICATION_TYPE\"\n" >> ./terraform.tfvars
printf "vm_app_subnet_id = \"$VM_APP_SUBNET_ID\"\n" >> ./terraform.tfvars
printf "vm_db_data_disk_config = $VM_DB_DATA_DISK_CONFIG\n" >> ./terraform.tfvars
printf "vm_db_image_offer = \"$VM_DB_IMAGE_OFFER\"\n" >> ./terraform.tfvars
printf "vm_db_image_publisher = \"$VM_DB_IMAGE_PUBLISHER\"\n" >> ./terraform.tfvars
printf "vm_db_image_sku = \"$VM_DB_IMAGE_SKU\"\n" >> ./terraform.tfvars
printf "vm_db_name = \"${VM_NAME_PREFIX}db01\"\n" >> ./terraform.tfvars
printf "vm_db_post_deploy_script_name = \"$VM_DB_POST_DEPLOY_SCRIPT_NAME\"\n" >> ./terraform.tfvars
printf "vm_db_post_deploy_script_uri = \"$VM_DB_POST_DEPLOY_SCRIPT_URI\"\n" >> ./terraform.tfvars
printf "vm_db_size = \"$VM_DB_SIZE\"\n" >> ./terraform.tfvars
printf "vm_db_storage_replication_type = \"$VM_DB_STORAGE_REPLICATION_TYPE\"\n" >> ./terraform.tfvars
printf "vm_sql_startup_script_name = \"$VM_SQL_STARTUP_SCRIPT_NAME\"\n" >> ./terraform.tfvars
printf "vm_sql_startup_script_uri = \"$VM_SQL_STARTUP_SCRIPT_URI\"\n" >> ./terraform.tfvars

printf "Generated terraform.tfvars file:\n\n"

cat ./terraform.tfvars
exit 0
