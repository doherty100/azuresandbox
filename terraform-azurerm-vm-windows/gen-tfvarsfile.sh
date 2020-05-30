#!/bin/bash

# Set these environment variables before running script
VM_ADMIN_PASSWORD_SECRET="adminpassword"
VM_ADMIN_USERNAME_SECRET="adminuser"
VM_IMAGE_PUBLISHER="MicrosoftWindowsServer"
VM_IMAGE_OFFER="WindowsServer"
VM_STORAGE_REPLICATION_TYPE="Standard_LRS"

# Set these environment variables by passing parameters to this script 
KEY_VAULT_ID=""
KEY_VAULT_NAME=""
LOCATION=""
LOG_ANALYTICS_WORKSPACE_ID=""
RESOURCE_GROUP_NAME=""
SUBNET_ID=""
TAGS=""
VM_DATA_DISK_COUNT=""
VM_DATA_DISK_SIZE_GB=""
VM_IMAGE_SKU=""
VM_NAME=""
VM_SIZE=""

# These are temporary variables
VM_IMAGE_ID=""
VM_SIZE_PROPERTIES=""

usage() {
    printf "Usage: $0\n  -n VM_NAME\n  -s VM_IMAGE_SKU\n  -z VM_SIZE\n  -c VM_DATA_DISK_COUNT\n  -d VM_DATA_DISK_SIZE_GB\n  -t TAGS\n" 1>&2
    exit 1
}

if [[ $# -eq 0 ]]; then
    usage
fi  

while getopts ":c:d:n:s:t:z:" option; do
    case "${option}" in
        c )
            VM_DATA_DISK_COUNT=${OPTARG}
            ;;
        d )
            VM_DATA_DISK_SIZE_GB=${OPTARG}
            ;;
        n ) 
            VM_NAME=${OPTARG}
            ;;
        s ) 
            VM_IMAGE_SKU=${OPTARG}
            ;;
        t )
            TAGS=${OPTARG}
            ;;
        z )
            VM_SIZE=${OPTARG}
            ;;
        \? )
            usage
            ;;
        : ) 
            printf "Error: -${OPTARG} requires an argument.\n"
            usage
            ;;
    esac
done

printf "Getting RESOURCE_GROUP_NAME...\n"
RESOURCE_GROUP_NAME=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" resource_group_01_name)

if [ $? != 0 ]; then
    echo "Error: Terraform output variable resource_group_01_name not found."
    usage
fi

printf "Getting LOCATION...\n"
LOCATION=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" resource_group_01_location)

if [ $? != 0 ]; then
    echo "Error: Terraform output variable resource_group_01_location not found."
    usage
fi

printf "Getting KEY_VAULT_ID...\n"
KEY_VAULT_ID=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" key_vault_01_id)

if [ $? != 0 ]; then
    echo "Error: Terraform output variable key_vault_01_id not found."
    usage
fi

printf "Getting KEY_VAULT_NAME...\n"
KEY_VAULT_NAME=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" key_vault_01_name)

if [ $? != 0 ]; then
    echo "Error: Terraform output variable key_vault_01_name not found."
    usage
fi

printf "Getting LOG_ANALYTICS_WORKSPACE_ID...\n"

LOG_ANALYTICS_WORKSPACE_ID=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" log_analytics_workspace_01_workspace_id)

if [ $? != 0 ]; then
    echo "Error: Terraform output variable log_analytics_workspace_01_workspace_id not found."
    usage
fi

printf "Getting SUBNET_ID...\n"
SUBNET_ID=$(terraform output -state="../terraform-azurerm-vnet-spoke/terraform.tfstate" vnet_spoke_01_default_subnet_id)

if [ $? != 0 ]; then
    echo "Error: Terraform output variable vnet_spoke_01_default_subnet_id not found."
    usage
fi

printf "Checking admin username secret...\n"
az keyvault secret show -n $VM_ADMIN_USERNAME_SECRET --vault-name $KEY_VAULT_NAME

if [ $? != 0 ]; then
    echo "Error: No secret named $VM_ADMIN_USERNAME_SECRET exists in $KEY_VAULT_NAME."
    usage
fi

printf "Checking admin password secret...\n"
az keyvault secret show -n $VM_ADMIN_PASSWORD_SECRET --vault-name $KEY_VAULT_NAME

if [ $? != 0 ]; then
    echo "Error: No secret named $VM_ADMIN_PASSWORD_SECRET exists in $KEY_VAULT_NAME."
    usage
fi

printf "Checking log analytics workspaceKey secret...\n"
az keyvault secret show -n $LOG_ANALYTICS_WORKSPACE_ID --vault-name $KEY_VAULT_NAME

if [ $? != 0 ]; then
    printf "Error: No secret named $LOG_ANALYTICS_WORKSPACE_ID exists in $KEY_VAULT_NAME.\n"
    usage
fi

printf "Validating VM_NAME '${VM_NAME}'...\n"
if [ -z $VM_NAME ]; then
    echo "Error: Invalid VM_NAME."
    usage
fi

printf "Validating VM_IMAGE_SKU '${VM_IMAGE_SKU}'...\n"

VM_IMAGE_ID=$(az vm image list-skus -l $LOCATION -p $VM_IMAGE_PUBLISHER -f $VM_IMAGE_OFFER --query "[?name=='${VM_IMAGE_SKU}'].id" | tr -d '[]" \n')

if [ -z $VM_IMAGE_ID ]; then
    echo "Error: Virtual machine sku $VM_IMAGE_SKU is not valid."
    usage
fi

printf "Validating VM_SIZE '${VM_SIZE}'...\n"

VM_SIZE_PROPERTIES=$(az vm list-sizes -l $LOCATION --query "[?name=='${VM_SIZE}']")

if [ "$VM_SIZE_PROPERTIES" = "[]" ]; then
    echo "Error: Virtual machine size '${VM_SIZE}' is not valid."
    usage
fi

printf "Validating LOG_ANALYTICS_WORKSPACE_ID '$LOG_ANALYTICS_WORKSPACE_ID'...\n"

if [ -z $LOG_ANALYTICS_WORKSPACE_ID ]; then
    printf "Error: Invalid LOG_ANALYTICS_WORKSPACE_ID"
    usage
fi

printf "Validating TAGS '${TAGS}'...\n"

if [[ -z ${TAGS} ]]; then
    printf "Error: Invalid TAGS.\n"
    usage
fi

printf "Validating VM_DATA_DISK_COUNT '${VM_DATA_DISK_COUNT}'...\n"

if [[ -z ${TAGS} ]]; then
    printf "Error: Invalid VM_DATA_DISK_COUNT.\n"
    usage
fi

printf "Validating VM_DATA_DISK_SIZE_GB '${VM_DATA_DISK_SIZE_GB}'...\n"

if [[ -z ${TAGS} ]]; then
    printf "Error: Invalid VM_DATA_DISK_SIZE_GB.\n"
    usage
fi

# Write values out to terraform.tfvars file

printf "\Generating terraform.tfvars file...\n\n"

printf "key_vault_id = \"$KEY_VAULT_ID\"\n" > ./terraform.tfvars
printf "location = \"$LOCATION\"\n" >> ./terraform.tfvars
printf "log_analytics_workspace_id = \"$LOG_ANALYTICS_WORKSPACE_ID\"\n" >> ./terraform.tfvars
printf "resource_group_name = \"$RESOURCE_GROUP_NAME\"\n" >> ./terraform.tfvars
printf "subnet_id = \"$SUBNET_ID\"\n" >> ./terraform.tfvars
printf "tags = $TAGS\n" >> ./terraform.tfvars
printf "vm_admin_password_secret = \"$VM_ADMIN_PASSWORD_SECRET\"\n" >> ./terraform.tfvars
printf "vm_admin_username_secret = \"$VM_ADMIN_USERNAME_SECRET\"\n" >> ./terraform.tfvars
printf "vm_data_disk_count = \"$VM_DATA_DISK_COUNT\"\n" >> ./terraform.tfvars
printf "vm_data_disk_size_gb = \"$VM_DATA_DISK_SIZE_GB\"\n" >> ./terraform.tfvars
printf "vm_image_offer = \"$VM_IMAGE_OFFER\"\n" >> ./terraform.tfvars
printf "vm_image_publisher = \"$VM_IMAGE_PUBLISHER\"\n" >> ./terraform.tfvars
printf "vm_image_sku = \"$VM_IMAGE_SKU\"\n" >> ./terraform.tfvars
printf "vm_name = \"$VM_NAME\"\n" >> ./terraform.tfvars
printf "vm_size = \"$VM_SIZE\"\n" >> ./terraform.tfvars
printf "vm_storage_replication_type = \"$VM_STORAGE_REPLICATION_TYPE\"\n" >> ./terraform.tfvars

printf "Generated terraform.tfvars file:\n\n"

cat ./terraform.tfvars
exit 0
