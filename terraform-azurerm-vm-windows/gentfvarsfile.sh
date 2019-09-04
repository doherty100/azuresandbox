#!/bin/bash

# This script generates a terraform.tfvars file for the terraform-azurerm-vm-windows quickstart

# Prerequisites before running this script: 
# - Install latest version of Azure CLI
# - Change the variables on lines 13-19 if necessary prior to running the script
# - Identify the resource group where you want to deploy the VM and pass it to the script using the -g parameter
#     Make sure the resource group has at least one virtual network with at least one subnet
#     Make sure the resource group has at least one key vault
#     Make sure the key vault has a secret used to identify the name of the administrator user account
#     Make sure the key vault has a secret used to identify the password for the administrator user account
# - Identify the virtual machine image sku to be used to create the VM and pass it to the script using the -s parameter
#     See 'az vm image list-skus' for a list of available skus.
# - Identify the virtual machine size to be used to create the VM and pass it to the script using the -t parameter
#     See 'az vm list-sizes' for a list of available sizes.
# - Choose a virtual machine name and pass it to the script using the -n parameter

# Set these environment variables before running script
VM_ADMIN_PASSWORD_SECRET="adminpassword"
VM_ADMIN_USERNAME_SECRET="adminuser"
VM_DATA_DISK_COUNT="0"
VM_DATA_DISK_SIZE_GB="0"
VM_IMAGE_PUBLISHER="MicrosoftWindowsServer"
VM_IMAGE_OFFER="WindowsServer"
VM_STORAGE_REPLICATION_TYPE="Standard_LRS"

# Set these environment variables by passing parameters to this script 
LOCATION=""
RESOURCE_GROUP_NAME=""
SUBNET_ID=""
VM_IMAGE_SKU=""
VM_NAME=""
VM_SIZE=""

# These are temporary variables
VAULT_NAME=""
KEY_VAULT_ID=""
VM_IMAGE_ID=""
VM_SIZE_PROPERTIES=""

usage() {
    echo "Usage: $0 -n VM_NAME -s VM_IMAGE_SKU -t VM_SIZE -g RESOURCE_GROUP_NAME -l LOCATION -i SUBNET_ID" 1>&2
    exit 1
}

if [[ $# -eq 0 ]]; then
    usage
fi  

while getopts ":g:i:l:n:s:t:" option; do
    case "${option}" in
        g ) 
            RESOURCE_GROUP_NAME=${OPTARG}
            ;;
        i )
            SUBNET_ID=${OPTARG}
            ;;
        l )
            LOCATION=${OPTARG}
            ;;
        n ) 
            VM_NAME=${OPTARG}
            ;;
        s ) 
            VM_IMAGE_SKU=${OPTARG}
            ;;
        t )
            VM_SIZE=${OPTARG}
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

echo $VM_IMAGE_ID

printf "Validating VM_SIZE '${VM_SIZE}'...\n"

VM_SIZE_PROPERTIES=$(az vm list-sizes -l $LOCATION --query "[?name=='${VM_SIZE}']")

if [ "$VM_SIZE_PROPERTIES" = "[]" ]; then
    echo "Error: Virtual machine size $VM_SIZE is not valid."
    usage
fi

echo $VM_SIZE_PROPERTIES

printf "Validating RESOURCE_GROUP_NAME '${RESOURCE_GROUP_NAME}'...\n"
az group show -n $RESOURCE_GROUP_NAME

if [ $? != 0 ]; then
    echo "Error: Resource group $RESOURCE_GROUP not found."
    usage
fi

printf "Validating SUBNET_ID '${SUBNET_ID}'...\n"

if [ -z $SUBNET_ID ]; then
    echo "Error: Invalid SUBNET_ID."
    usage
fi

printf "Validating LOCATION '${LOCATION}'...\n"

LOCATION_ID=""
LOCATION_ID=$(az account list-locations --query "[?name=='${LOCATION}'].id" | tr -d '[]" \n')

if [ -z $LOCATION_ID ]; then
    echo "Error: Invalid LOCATION."
    usage
fi

# Get the key_vault_id for the first key vault in the resource group
printf "Getting key vault...\n"
KEY_VAULT_ID=$(az keyvault list -g $RESOURCE_GROUP_NAME --query "[0].id" | tr -d '"')

if [ -z $KEY_VAULT_ID ]; then
    echo "Error: No key vault exists in $RESOURCE_GROUP_NAME."
    usage
fi

echo $KEY_VAULT_ID

VAULT_NAME=$(az keyvault list -g $RESOURCE_GROUP_NAME --query "[0].name" | tr -d '"')

# Validate admin username secret
printf "Checking admin username secret...\n"
az keyvault secret show -n $VM_ADMIN_USERNAME_SECRET --vault-name $VAULT_NAME

if [ $? != 0 ]; then
    echo "Error: No secret named $VM_ADMIN_USERNAME_SECRET exists in $VAULT_NAME."
    usage
fi

# Validate admin password secret
printf "Checking admin password secret...\n"
az keyvault secret show -n $VM_ADMIN_PASSWORD_SECRET --vault-name $VAULT_NAME

if [ $? != 0 ]; then
    echo "Error: No secret named $VM_ADMIN_PASSWORD_SECRET exists in $VAULT_NAME."
    usage
fi

# Write values out to terraform.tfvars file

printf "\Generating terraform.tfvars file...\n\n"

printf "key_vault_id = \"$KEY_VAULT_ID\"\n" > ./terraform.tfvars
printf "location = \"$LOCATION\"\n" >> ./terraform.tfvars
printf "resource_group_name = \"$RESOURCE_GROUP_NAME\"\n" >> ./terraform.tfvars
printf "subnet_id = \"$SUBNET_ID\"\n" >> ./terraform.tfvars
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