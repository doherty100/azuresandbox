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
RESOURCE_GROUP=""
VM_IMAGE_SKU=""
VM_NAME=""
VM_SIZE=""

# These are temporary variables
VAULT_NAME=""
VAULT_URI=""
VM_IMAGE_ID=""
VM_SIZE_PROPERTIES=""

usage() {
    echo "Usage: $0 -g RESOURCE_GROUP -s VM_IMAGE_SKU -t VM_SIZE -n VM_NAME" 1>&2
    exit 1
}

if [[ $# -eq 0  ]]; then
    usage
fi  

while getopts ":g:s:t:n:" option; do
    case "${option}" in
        g ) 
            RESOURCE_GROUP=${OPTARG}
            ;;
        s ) 
            VM_IMAGE_SKU=${OPTARG}
            ;;
        t )
            VM_SIZE=${OPTARG}
            ;;
        n ) 
            VM_NAME=${OPTARG}
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

# Validate resource group
printf "Checking resource group...\n"
az group show -n $RESOURCE_GROUP

if [ $? != 0 ]; then
    echo "Error: Resource group $RESOURCE_GROUP not found."
    usage
fi

# Get the vault_uri for the first key vault in the resource group
printf "Getting key vault...\n"
VAULT_URI=$(az keyvault list -g $RESOURCE_GROUP --query "[0].properties.vaultUri" | tr -d '"')

if [ -z $VAULT_URI ]; then
    echo "Error: No key vault exists in $RESOURCE_GROUP."
    usage
fi

echo $VAULT_URI

VAULT_NAME=$(az keyvault list -g $RESOURCE_GROUP --query "[0].name" | tr -d '"')

echo $VAULT_NAME

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

# Get the first Virtual Network in the resource group
printf "Getting virtual network...\n"
VNET_NAME=$(az network vnet list -g $RESOURCE_GROUP --query "[0].name" | tr -d '"')

echo $VNET_NAME

if [ -z $VNET_NAME ]; then
    echo "Error: No Virtual Network exists in $RESOURCE_GROUP."
    usage
fi

# Get the first subnet in the virtual network
printf "Getting subnet...\n"
SUBNET_ID=$(az network vnet show -n $VNET_NAME -g $RESOURCE_GROUP --query "subnets[0].id" | tr -d '"')

if [ -z $SUBNET_ID ]; then
    echo "Error: No subnet exists in Virtual Network $VNET_NAME."
    usage
fi

echo $SUBNET_ID

# Get the location for the virtual network
printf "Getting location...\n"
LOCATION=$(az network vnet show -n $VNET_NAME -g $RESOURCE_GROUP --query "location" | tr -d '"')

if [ -z $LOCATION ]; then
    echo "Error: Unable to get location of Virtual Network $VNET_NAME."
    usage
fi

echo $LOCATION

# Validate vm image sku
printf "Checking virtual machine image sku...\n"

VM_IMAGE_ID=$(az vm image list-skus -l $LOCATION -p $VM_IMAGE_PUBLISHER -f $VM_IMAGE_OFFER --query "[?name=='${VM_IMAGE_SKU}'].id" | tr -d '[]" \n')

if [ -z $VM_IMAGE_ID ]; then
    echo "Error: Virtual machine sku $VM_IMAGE_SKU is not valid."
    usage
fi

echo $VM_IMAGE_ID

# Validate vm size
printf "Checking virtual machine size...\n"

VM_SIZE_PROPERTIES=$(az vm list-sizes -l $LOCATION --query "[?name=='${VM_SIZE}']")

if [ "$VM_SIZE_PROPERTIES" = "[]" ]; then
    echo "Error: Virtual machine size $VM_SIZE is not valid."
    usage
fi

echo $VM_SIZE_PROPERTIES

# Write values out to terraform.tfvars file

printf "\Generating terraform.tfvars file...\n\n"

printf "location = \"$LOCATION\"\n" > ./terraform.tfvars
printf "resource_group_name = \"$RESOURCE_GROUP\"\n" >> ./terraform.tfvars
printf "subnet_id = \"$SUBNET_ID\"\n" >> ./terraform.tfvars
printf "vault_uri = \"$VAULT_URI\"\n" >> ./terraform.tfvars
printf "vnet_name = \"$VNET_NAME\"\n" >> ./terraform.tfvars
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