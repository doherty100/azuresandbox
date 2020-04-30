#!/bin/bash

# Dependencies: Azure CLI

LOCATION="" 
REMOTE_VIRTUAL_NETWORK_IDS=""
RESOURCE_GROUP_NAME=""
TAGS=""
VWAN_HUB_ADDRESS_PREFIX=""
VWAN_HUB_NAME=""
VWAN_NAME=""

usage() {
    printf "Usage: $0 \n  -g RESOURCE_GROUP_NAME\n  -l LOCATION\n  -t TAGS\n  -v VWAN_NAME\n  -h VWAN_HUB_NAME\n  -a VWAN_HUB_ADDRESS_PREFIX\n  -r REMOTE_VIRTUAL_NETWORK_IDS\n" 1>&2
    exit 1
}

if [[ $# -eq 0  ]]; then
    usage
fi  

while getopts ":a:g:h:l:r:t:v:" option; do
    case "${option}" in
        a ) 
            VWAN_HUB_ADDRESS_PREFIX=${OPTARG}
            ;;
        g ) 
            RESOURCE_GROUP_NAME=${OPTARG}
            ;;
        h )
            VWAN_HUB_NAME=${OPTARG}
            ;;
        l ) 
            LOCATION=${OPTARG}
            ;;
        r )
            REMOTE_VIRTUAL_NETWORK_IDS=${OPTARG}
            ;;
        t )
            TAGS=${OPTARG}
            ;;
        v )
            VWAN_NAME=${OPTARG}
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

if [[ -z {$RESOURCE_GROUP_NAME} ]]; then
    printf "Error: Invalid RESOURCE_GROUP_NAME.\n"
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

printf "Validating VWAN_NAME '${VWAN_NAME}'...\n"

if [[ -z ${VWAN_NAME} ]]; then
    printf "Error: Invalid VWAN_NAME.\n"
    usage
fi

printf "Validating VWAN_HUB_NAME '${VWAN_HUB_NAME}'...\n"

if [[ -z ${VWAN_HUB_NAME} ]]; then
    printf "Error: Invalid VWAN_HUB_NAME.\n"
    usage
fi

printf "Validating VWAN_HUB_ADDRESS_PREFIX '${VWAN_HUB_ADDRESS_PREFIX}'...\n"

if [[ -z ${VWAN_HUB_ADDRESS_PREFIX} ]]; then
    printf "Error: Invalid VWAN_HUB_ADDRESS_PREFIX.\n"
    usage
fi

printf "Validating REMOTE_VIRTUAL_NETWORK_IDS '${REMOTE_VIRTUAL_NETWORK_IDS}'...\n"

if [[ -z ${REMOTE_VIRTUAL_NETWORK_IDS} ]]; then
    printf "Error: Invalid REMOTE_VIRTUAL_NETWORK_IDS.\n"
    usage
fi

printf "\nGenerating terraform.tfvars file...\n\n"

printf "location = \"$LOCATION\"\n" > ./terraform.tfvars
printf "remote_virtual_network_ids = $REMOTE_VIRTUAL_NETWORK_IDS\n" >> ./terraform.tfvars
printf "resource_group_name = \"$RESOURCE_GROUP_NAME\"\n" >> ./terraform.tfvars
printf "tags = $TAGS\n" >> ./terraform.tfvars
printf "vwan_hub_address_prefix = \"$VWAN_HUB_ADDRESS_PREFIX\"\n" >> ./terraform.tfvars
printf "vwan_hub_name = \"$VWAN_HUB_NAME\"\n" >> ./terraform.tfvars
printf "vwan_name = \"$VWAN_NAME\"\n" >> ./terraform.tfvars

cat ./terraform.tfvars

exit 0
