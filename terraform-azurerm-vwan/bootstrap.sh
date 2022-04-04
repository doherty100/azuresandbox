#!/bin/bash

# Bootstraps deployment with pre-requisites for applying Terraform configurations
# Script is idempotent and can be run multiple times

usage() {
    printf "Usage: $0 \n" 1>&2
    exit 1
}

# Set these defaults prior to running the script.
default_vwan_hub_address_prefix="10.3.0.0/16"

# Intialize runtime defaults
state_file="../terraform-azurerm-vnet-shared/terraform.tfstate"
if [ ! -f $state_file ]
then
    printf "Unable to locate \"$state_file\"...\n"
    printf "See README.md for configurations that must be deployed first...\n"
    usage
fi

aad_tenant_id=$(terraform output -state=$state_file aad_tenant_id)
arm_client_id=$(terraform output -state=$state_file arm_client_id)
location=$(terraform output -state=$state_file location)
resource_group_name=$(terraform output -state=$state_file resource_group_name)
subscription_id=$(terraform output -state=$state_file subscription_id)
tags=$(terraform output -json -state=$state_file tags)
vnet_shared_01_id=$(terraform output -state=$state_file vnet_shared_01_id)
vnet_shared_01_name=$(terraform output -state=$state_file vnet_shared_01_name)

state_file="../terraform-azurerm-vnet-app/terraform.tfstate"
if [ ! -f $state_file ]
then
    printf "Unable to locate \"$state_file\"...\n"
    printf "See README.md for configurations that must be deployed first...\n"
    usage
fi

vnet_app_01_id=$(terraform output -state=$state_file vnet_app_01_id)
vnet_app_01_name=$(terraform output -state=$state_file vnet_app_01_name)

# User input
read -e -i $default_vwan_hub_address_prefix -p "vwan hub address prefix -: " vwan_hub_address_prefix

vwan_hub_address_prefix=${vwan_hub_address_prefix:=$default_vwan_hub_address_prefix}

# Build vnet map
virtual_networks="${virtual_networks}{\n"
virtual_networks="${virtual_networks}  ${vnet_shared_01_name:1:-1} = $vnet_shared_01_id\n"
virtual_networks="${virtual_networks}  ${vnet_app_01_name:1:-1} = $vnet_app_01_id\n"
virtual_networks="${virtual_networks}}"

#Generate terraform.tfvars file
printf "\nGenerating terraform.tfvars file...\n\n"

printf "aad_tenant_id           = $aad_tenant_id\n"                 > ./terraform.tfvars
printf "arm_client_id           = $arm_client_id\n"                 >> ./terraform.tfvars
printf "location                = $location\n"                      >> ./terraform.tfvars
printf "resource_group_name     = $resource_group_name\n"           >> ./terraform.tfvars
printf "subscription_id         = $subscription_id\n"               >> ./terraform.tfvars
printf "tags                    = $tags\n"                          >> ./terraform.tfvars
printf "virtual_networks        = $virtual_networks\n"              >> ./terraform.tfvars
printf "vwan_hub_address_prefix = \"$vwan_hub_address_prefix\"\n"   >> ./terraform.tfvars

cat ./terraform.tfvars

printf "\nReview defaults in \"variables.tf\" prior to applying Terraform configurations...\n"
printf "\nBootstrapping complete...\n"

exit 0
