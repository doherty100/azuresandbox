#!/bin/bash

# Dependencies: Azure CLI

LOCATION="" 
RESOURCE_GROUP_NAME=""
TAGS=""
VNET_HUB_01_ID=""
VNET_HUB_01_NAME=""
VNET_SPOKE_01_ID=""
VNET_SPOKE_01_NAME=""
VWAN_HUB_ADDRESS_PREFIX=""


usage() {
    printf "Usage: $0 \n  -a VWAN_HUB_ADDRESS_PREFIX\n  -t TAGS\n" 1>&2
    exit 1
}

if [[ $# -eq 0  ]]; then
    usage
fi  

while getopts ":a:t:" option; do
    case "${option}" in
        a ) 
            VWAN_HUB_ADDRESS_PREFIX=${OPTARG}
            ;;
        t )
            TAGS=${OPTARG}
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

printf "Getting VNET_HUB_01_ID...\n"
VNET_HUB_01_ID=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" vnet_hub_01_id)

if [ $? != 0 ]; then
    echo "Error: Terraform output variable vnet_hub_01_id not found."
    usage
fi

printf "Getting VNET_HUB_01_NAME...\n"
VNET_HUB_01_NAME=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" vnet_hub_01_name)

if [ $? != 0 ]; then
    echo "Error: Terraform output variable vnet_hub_01_name not found."
    usage
fi

printf "Getting VNET_SPOKE_01_ID...\n"
VNET_SPOKE_01_ID=$(terraform output -state="../terraform-azurerm-vnet-spoke/terraform.tfstate" vnet_spoke_01_id)

if [ $? != 0 ]; then
    echo "Error: Terraform output variable vnet_spoke_01_id not found."
    usage
fi

printf "Getting VNET_SPOKE_01_NAME...\n"
VNET_SPOKE_01_NAME=$(terraform output -state="../terraform-azurerm-vnet-spoke/terraform.tfstate" vnet_spoke_01_name)

if [ $? != 0 ]; then
    echo "Error: Terraform output variable vnet_spoke_01_id not found."
    usage
fi

printf "Validating VWAN_HUB_ADDRESS_PREFIX '${VWAN_HUB_ADDRESS_PREFIX}'...\n"

if [[ -z ${VWAN_HUB_ADDRESS_PREFIX} ]]; then
    printf "Error: Invalid VWAN_HUB_ADDRESS_PREFIX.\n"
    usage
fi

printf "Validating TAGS '${TAGS}'...\n"

if [[ -z ${TAGS} ]]; then
    printf "Error: Invalid TAGS.\n"
    usage
fi

printf "\nGenerating terraform.tfvars file...\n\n"

printf "location = \"$LOCATION\"\n" > ./terraform.tfvars
printf "remote_virtual_network_ids = { $VNET_HUB_01_NAME = \"$VNET_HUB_01_ID\", $VNET_SPOKE_01_NAME = \"$VNET_SPOKE_01_ID\" }\n" >> ./terraform.tfvars
printf "resource_group_name = \"$RESOURCE_GROUP_NAME\"\n" >> ./terraform.tfvars
printf "tags = $TAGS\n" >> ./terraform.tfvars
printf "vwan_hub_address_prefix = \"$VWAN_HUB_ADDRESS_PREFIX\"\n" >> ./terraform.tfvars

cat ./terraform.tfvars

exit 0
