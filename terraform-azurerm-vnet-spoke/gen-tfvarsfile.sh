#!/bin/bash

# Dependencies: Azure CLI

LOCATION=""
REMOTE_VIRTUAL_NETWORK_ID=""
REMOTE_VIRTUAL_NETWORK_NAME=""
RESOURCE_GROUP_NAME=""
SUBNETS=""
TAGS=""
VNET_ADDRESS_SPACE=""
VNET_NAME=""

usage() {
    printf "Usage: $0 \n  -v VNET_NAME\n  -a VNET_ADDRESS_SPACE\n  -s SUBNETS\n  -t TAGS\n" 1>&2
    exit 1
}

if [[ $# -eq 0 ]]; then
    usage
fi  

while getopts ":a:s:t:v:" option; do
    case "${option}" in
        a )
            VNET_ADDRESS_SPACE=${OPTARG}
            ;;
        s )
            SUBNETS=${OPTARG}
            ;;
        t )
            TAGS=${OPTARG}
            ;;        
        v )
            VNET_NAME=${OPTARG}
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

printf "Validating VNET_NAME '${VNET_NAME}'...\n"

if [[ -z ${VNET_NAME} ]]; then
    printf "Error: Invalid VNET_NAME.\n"
    usage
fi

printf "Validating VNET_ADDRESS_SPACE '${VNET_ADDRESS_SPACE}'...\n"

if [[ -z ${VNET_ADDRESS_SPACE} ]]; then
    printf "Error: Invalid VNET_ADDRESS_SPACE.\n"
    usage
fi

printf "Validating SUBNETS '${SUBNETS}'...\n"

if [[ -z ${SUBNETS} ]]; then
    printf "Error: Invalid SUBNETS.\n"
    usage
fi

printf "Validating TAGS '${TAGS}'...\n"

if [[ -z ${TAGS} ]]; then
    printf "Error: Invalid TAGS.\n"
    usage
fi

printf "Getting REMOTE_VIRTUAL_NETWORK_ID...\n"
REMOTE_VIRTUAL_NETWORK_ID=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" vnet_hub_01_id)

if [ $? != 0 ]; then
    echo "Error: Terraform output variable vnet_hub_01_id not found."
    usage
fi

printf "Getting REMOTE_VIRTUAL_NETWORK_NAME...\n"
REMOTE_VIRTUAL_NETWORK_NAME=$(terraform output -state="../terraform-azurerm-vnet-hub/terraform.tfstate" vnet_hub_01_name)

if [ $? != 0 ]; then
    echo "Error: Terraform output variable vnet_hub_01_name not found."
    usage
fi

printf "\nGenerating terraform.tfvars file...\n\n"

printf "location = \"$LOCATION\"\n" > ./terraform.tfvars
printf "remote_virtual_network_id = \"$REMOTE_VIRTUAL_NETWORK_ID\"\n" >> ./terraform.tfvars
printf "remote_virtual_network_name = \"$REMOTE_VIRTUAL_NETWORK_NAME\"\n" >> ./terraform.tfvars
printf "resource_group_name = \"$RESOURCE_GROUP_NAME\"\n" >> ./terraform.tfvars
printf "subnets = $SUBNETS\n" >> ./terraform.tfvars
printf "tags = $TAGS\n" >> ./terraform.tfvars
printf "vnet_address_space = \"$VNET_ADDRESS_SPACE\"\n" >> ./terraform.tfvars
printf "vnet_name = \"$VNET_NAME\"\n" >> ./terraform.tfvars

cat ./terraform.tfvars

exit 0
