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
    printf "See README.md for samples that must be deployed first...\n"
    usage
fi

default_subscription_id=$(terraform output -state=$state_file subscription_id)
default_resource_group_name=$(terraform output -state=$state_file resource_group_01_name)
default_location=$(terraform output -state=$state_file resource_group_01_location)
default_tags=$(terraform output -json -state=$state_file resource_group_01_tags)
default_shared_virtual_network_id=$(terraform output -state=$state_file vnet_shared_01_id)
default_shared_virtual_network_name=$(terraform output -state=$state_file vnet_shared_01_name)

state_file="../terraform-azurerm-vnet-spoke/terraform.tfstate"
if [ ! -f $state_file ]
then
    printf "Unable to locate \"$state_file\"...\n"
    printf "See README.md for samples that must be deployed first...\n"
    usage
fi

default_spoke_virtual_network_id=$(terraform output -state=$state_file vnet_spoke_01_id)
default_spoke_virtual_network_name=$(terraform output -state=$state_file vnet_spoke_01_name)

# User input
read -e -i $default_vwan_hub_address_prefix -p "vwan hub address prefix -: " vwan_hub_address_prefix

vwan_hub_address_prefix=${vwan_hub_address_prefix:=$default_vwan_hub_address_prefix}

# Build vnet map
default_vnets="${default_vnets}{\n"
default_vnets="${default_vnets}  ${default_shared_virtual_network_name:1:-1} = $default_shared_virtual_network_id,\n"
default_vnets="${default_vnets}  ${default_spoke_virtual_network_name:1:-1}  = $default_spoke_virtual_network_id\n"
default_vnets="${default_vnets}}"

#Generate terraform.tfvars file
printf "\nGenerating terraform.tfvars file...\n\n"

printf "location                = $default_location\n"              > ./terraform.tfvars
printf "virtual_network_ids     = $default_vnets\n"                 >> ./terraform.tfvars
printf "resource_group_name     = $default_resource_group_name\n"   >> ./terraform.tfvars
printf "subscription_id         = $default_subscription_id\n"       >> ./terraform.tfvars
printf "tags                    = $default_tags\n"                  >> ./terraform.tfvars
printf "vwan_hub_address_prefix = \"$vwan_hub_address_prefix\"\n"   >> ./terraform.tfvars

cat ./terraform.tfvars

printf "\nReview defaults in \"variables.tf\" prior to applying Terraform configurations...\n"
printf "\nBootstrapping complete...\n"

exit 0
