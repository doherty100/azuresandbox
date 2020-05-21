#!/bin/bash

# Dependencies: Azure CLI

BASTION_HOST_NAME=""
LOCATION=""
REMOTE_VIRTUAL_NETWORK_ID=""
REMOTE_VIRTUAL_NETWORK_NAME=""
RESOURCE_GROUP_NAME=""
SUBNETS=""
TAGS=""
VNET_ADDRESS_SPACE=""
VNET_NAME=""

usage() {
    printf "Usage: $0 \n  -g RESOURCE_GROUP_NAME\n  -l LOCATION\n  -t TAGS\n  -v VNET_NAME\n  -a VNET_ADDRESS_SPACE\n  -s SUBNETS\n  -i REMOTE_VIRTUAL_NETWORK_ID\n  -n REMOTE_VIRTUAL_NETWORK_NAME\n  -b BASTION_HOST_NAME\n" 1>&2
    exit 1
}

if [[ $# -eq 0 ]]; then
    usage
fi  

while getopts ":a:b:g:i:l:n:s:t:v:" option; do
    case "${option}" in
        a )
            VNET_ADDRESS_SPACE=${OPTARG}
            ;;
        b )
            BASTION_HOST_NAME=${OPTARG}
            ;;
        g ) 
            RESOURCE_GROUP_NAME=${OPTARG}
            ;;
        i )
            REMOTE_VIRTUAL_NETWORK_ID=${OPTARG}
            ;;
        l ) 
            LOCATION=${OPTARG}
            ;;
        n )
            REMOTE_VIRTUAL_NETWORK_NAME=${OPTARG}
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

printf "Validating RESOURCE_GROUP_NAME '${RESOURCE_GROUP_NAME}'...\n"
az group show -n $RESOURCE_GROUP_NAME

if [ $? != 0 ]; then
    printf "Error: Resource group $RESOURCE_GROUP not found.\n"
    usage
fi

printf "Validating LOCATION '${LOCATION}'...\n"

LOCATION_ID=""
LOCATION_ID=$(az account list-locations --query "[?name=='${LOCATION}'].id" | tr -d '[]" \n')

if [[ -z ${LOCATION_ID} ]]; then
    printf "Error: Invalid LOCATION.\n"
    usage
fi

printf "Validating TAGS '${TAGS}'...\n"

if [[ -z ${TAGS} ]]; then
    printf "Error: Invalid TAGS.\n"
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

printf "Validating REMOTE_VIRTUAL_NETWORK_ID '${REMOTE_VIRTUAL_NETWORK_ID}'...\n"

if [[ -z ${REMOTE_VIRTUAL_NETWORK_ID} ]]; then
    printf "Error: Invalid REMOTE_VIRTUAL_NETWORK_ID.\n"
fi

printf "Validating REMOTE_VIRTUAL_NETWORK_NAME '${REMOTE_VIRTUAL_NETWORK_NAME}'...\n"

if [[ -z ${REMOTE_VIRTUAL_NETWORK_NAME} ]]; then
    printf "Error: Invalid REMOTE_VIRTUAL_NETWORK_NAME.\n"
fi

printf "Validating BASTION_HOST_NAME '${BASTION_HOST_NAME}'\n"

if [[ -z ${BASTION_HOST_NAME} ]]; then
    printf "Error: Invalid BASTION_HOST_NAME.\n"
    usage
fi

printf "\nGenerating terraform.tfvars file...\n\n"

printf "bastion_host_name = \"$BASTION_HOST_NAME\"\n" > ./terraform.tfvars
printf "location = \"$LOCATION\"\n" >> ./terraform.tfvars
printf "remote_virtual_network_id = \"$REMOTE_VIRTUAL_NETWORK_ID\"\n" >> ./terraform.tfvars
printf "remote_virtual_network_name = \"$REMOTE_VIRTUAL_NETWORK_NAME\"\n" >> ./terraform.tfvars
printf "resource_group_name = \"$RESOURCE_GROUP_NAME\"\n" >> ./terraform.tfvars
printf "subnets = $SUBNETS\n" >> ./terraform.tfvars
printf "tags = $TAGS\n" >> ./terraform.tfvars
printf "vnet_address_space = \"$VNET_ADDRESS_SPACE\"\n" >> ./terraform.tfvars
printf "vnet_name = \"$VNET_NAME\"\n" >> ./terraform.tfvars

cat ./terraform.tfvars

exit 0
