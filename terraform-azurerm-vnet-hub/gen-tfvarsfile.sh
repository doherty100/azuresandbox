#!/bin/bash

# Dependencies: Azure CLI

AAD_TENANT_ID=""
BASTION_HOST_NAME=""
KEY_VAULT_ADMIN_OBJECT_ID=""
LOCATION="" 
RESOURCE_GROUP_NAME=""
SHARED_IMAGE_GALLERY_NAME=""
STORAGE_REPLICATION_TYPE=""
STORAGE_SHARE_QUOTA=""
SUBNETS=""
TAGS=""
VNET_ADDRESS_SPACE=""
VNET_NAME=""

usage() {
    printf "Usage: $0 \n  -g RESOURCE_GROUP_NAME\n  -l LOCATION\n  -t TAGS\n  -v VNET_NAME\n  -a VNET_ADDRESS_SPACE\n  -s SUBNETS\n  -r STORAGE_REPLICATION_TYPE\n  -q STORAGE_SHARE_QUOTA\n  -o KEY_VAULT_ADMIN_OBJECT_ID\n  -d AAD_TENANT_ID\n  -h SHARED_IMAGE_GALLERY_NAME\n  -b BASTION_HOST_NAME\n" 1>&2
    exit 1
}

if [[ $# -eq 0  ]]; then
    usage
fi  

while getopts ":a:b:d:g:h:l:o:q:r:s:t:v:" option; do
    case "${option}" in
        a )
            VNET_ADDRESS_SPACE=${OPTARG}
            ;;
        b )
            BASTION_HOST_NAME=${OPTARG}
            ;;
        d )
            AAD_TENANT_ID=${OPTARG}
            ;;
        g ) 
            RESOURCE_GROUP_NAME=${OPTARG}
            ;;
        h )
            SHARED_IMAGE_GALLERY_NAME=${OPTARG}
            ;;
        l ) 
            LOCATION=${OPTARG}
            ;;
        o )
            KEY_VAULT_ADMIN_OBJECT_ID=${OPTARG}
            ;;
        q )
            STORAGE_SHARE_QUOTA=${OPTARG}
            ;;
        r )
            STORAGE_REPLICATION_TYPE=${OPTARG}
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

printf "Validating STORAGE_REPLICATION_TYPE '${STORAGE_REPLICATION_TYPE}'\n"

case $STORAGE_REPLICATION_TYPE in
    LRS | GRS | RAGRS | ZRS )
        ;;
    * )
        printf "Error: Invalid STORAGE_REPLICATION_TYPE.\n"
        usage
        ;;
esac

printf "Validating STORAGE_SHARE_QUOTA '${STORAGE_SHARE_QUOTA}'\n"

if [[ -z ${STORAGE_SHARE_QUOTA} ]]; then
    printf "Error: Invalid STORAGE_SHARE_QUOTA.\n"
    usage
fi

printf "Validating KEY_VAULT_ADMIN_OBJECT_ID '${KEY_VAULT_ADMIN_OBJECT_ID}'\n"

if [[ -z ${KEY_VAULT_ADMIN_OBJECT_ID} ]]; then
    printf "Error: Invalid KEY_VAULT_ADMIN_OBJECT_ID.\n"
    usage
fi

printf "Validating AAD_TENANT_ID '${AAD_TENANT_ID}'\n"

if [[ -z {$AAD_TENANT_ID} ]]; then
    printf "Error: Invalid AAD_TENANT_ID.\n"
    usage
fi

printf "Validating SHARED_IMAGE_GALLERY_NAME '${SHARED_IMAGE_GALLERY_NAME}'\n"

if [[ -z ${SHARED_IMAGE_GALLERY_NAME} ]]; then
    printf "Error: Invalid SHARED_IMAGE_GALLERY_NAME.\n"
    usage
fi

printf "Validating BASTION_HOST_NAME '${BASTION_HOST_NAME}'\n"

if [[ -z ${BASTION_HOST_NAME} ]]; then
    printf "Error: Invalid BASTION_HOST_NAME.\n"
    usage
fi

printf "\nGenerating terraform.tfvars file...\n\n"

printf "aad_tenant_id = \"$AAD_TENANT_ID\"\n" > ./terraform.tfvars
printf "bastion_host_name = \"$BASTION_HOST_NAME\"\n" >> ./terraform.tfvars
printf "key_vault_admin_object_id = \"$KEY_VAULT_ADMIN_OBJECT_ID\"\n" >> ./terraform.tfvars
printf "location = \"$LOCATION\"\n" >> ./terraform.tfvars
printf "resource_group_name = \"$RESOURCE_GROUP_NAME\"\n" >> ./terraform.tfvars
printf "shared_image_gallery_name = \"$SHARED_IMAGE_GALLERY_NAME\"\n" >> ./terraform.tfvars
printf "storage_replication_type = \"$STORAGE_REPLICATION_TYPE\"\n" >> ./terraform.tfvars
printf "storage_share_quota = \"$STORAGE_SHARE_QUOTA\"\n" >> ./terraform.tfvars
printf "subnets = $SUBNETS\n" >> ./terraform.tfvars
printf "tags = $TAGS\n" >> ./terraform.tfvars
printf "vnet_address_space = \"$VNET_ADDRESS_SPACE\"\n" >> ./terraform.tfvars
printf "vnet_name = \"$VNET_NAME\"\n" >> ./terraform.tfvars

cat ./terraform.tfvars

exit 0
