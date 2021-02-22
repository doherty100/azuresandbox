#!/bin/bash

# Bootstraps deployment with pre-requisites for applying Terraform configurations
# Script is idempotent and can be run multiple times

usage() {
    printf "Usage: $0 \n" 1>&2
    exit 1
}

# Set these defaults prior to running the script.
default_vnet_name="vnet-spoke-001"
default_vnet_address_space="10.2.0.0/16"
default_default_subnet_name="snet-default-002"
default_default_subnet_address_prefix="10.2.0.0/24"
default_privatelink_subnet_name="snet-storage-private-endpoints-002"
default_privatelink_subnet_address_prefix="10.2.1.64/27"
default_database_subnet_name="snet-db-001"
default_database_subnet_address_prefix="10.2.1.0/27"
default_application_subnet_name="snet-app-001"
default_application_subnet_address_prefix="10.2.1.32/27"

# Intialize runtime defaults
state_file="../terraform-azurerm-vnet-shared/terraform.tfstate"
if [ ! -f $state_file ]
then
    printf "Unable to locate \"$state_file\"...\n"
    printf "See README.md for quick starts that must be deployed first...\n"
    usage
fi

default_subscription_id=$(terraform output -state=$state_file subscription_id)
default_resource_group_name=$(terraform output -state=$state_file resource_group_01_name)
default_location=$(terraform output -state=$state_file resource_group_01_location)
default_tags=$(terraform output -json -state=$state_file resource_group_01_tags)
default_remote_virtual_network_id=$(terraform output -state=$state_file vnet_shared_01_id)
default_remote_virtual_network_name=$(terraform output -state=$state_file vnet_shared_01_name)

# User input
read -e -i $default_vnet_name                         -p "vnet name -------------------------: " vnet_name
read -e -i $default_vnet_address_space                -p "vnet address space ----------------: " vnet_address_space
read -e -i $default_default_subnet_name               -p "default subnet name ---------------: " default_subnet_name
read -e -i $default_default_subnet_address_prefix     -p "default subnet address prefix -----: " default_subnet_address_prefix
read -e -i $default_privatelink_subnet_name           -p "privatelink subnet name -----------: " privatelink_subnet_name
read -e -i $default_privatelink_subnet_address_prefix -p "privatelink subnet address prefix -: " privatelink_subnet_address_prefix
read -e -i $default_database_subnet_name              -p "database subnet name --------------: " database_subnet_name
read -e -i $default_database_subnet_address_prefix    -p "database subnet address prefix ----: " database_subnet_address_prefix
read -e -i $default_application_subnet_name           -p "application subnet name -----------: " application_subnet_name
read -e -i $default_application_subnet_address_prefix -p "application subnet address prefix -: " application_subnet_address_prefix

vnet_name=${vnet_name:=$default_vnet_name}
vnet_address_space=${vnet_address_space:-default_vnet_address_space}
default_subnet_name=${default_subnet_name:-default_default_subnet_name}
default_subnet_address_prefix=${default_subnet_address_prefix:-default_default_subnet_address_prefix}
privatelink_subnet_name=${privatelink_subnet_name:-default_privatelink_subnet_name}
privatelink_subnet_address_prefix=${privatelink_subnet_address_prefix:-default_privatelink_subnet_address_prefix}
database_subnet_name=${database_subnet_name:-default_database_subnet_name}
database_subnet_address_prefix=${database_subnet_address_prefix:-default_database_subnet_address_prefix}
application_subnet_name=${application_subnet_name:-default_application_subnet_name}
application_subnet_address_prefix=${application_subnet_address_prefix:-default_application_subnet_address_prefix}

# Build subnet map
subnets=""
subnets="${subnets}{\n"
subnets="${subnets}  default = {\n"
subnets="${subnets}    name                                           = \"$default_subnet_name\",\n"
subnets="${subnets}    address_prefix                                 = \"$default_subnet_address_prefix\",\n"
subnets="${subnets}    enforce_private_link_endpoint_network_policies = false\n"
subnets="${subnets}  },\n"
subnets="${subnets}  PrivateLink = {\n"
subnets="${subnets}    name                                           = \"$privatelink_subnet_name\",\n"
subnets="${subnets}    address_prefix                                 = \"$privatelink_subnet_address_prefix\",\n"
subnets="${subnets}    enforce_private_link_endpoint_network_policies = true\n"
subnets="${subnets}  },\n"
subnets="${subnets}  database = {\n"
subnets="${subnets}    name                                           = \"$database_subnet_name\",\n"
subnets="${subnets}    address_prefix                                 = \"$database_subnet_address_prefix\",\n"
subnets="${subnets}    enforce_private_link_endpoint_network_policies = false\n"
subnets="${subnets}  },\n"
subnets="${subnets}  application = {\n"
subnets="${subnets}    name                                           = \"$application_subnet_name\",\n"
subnets="${subnets}    address_prefix                                 = \"$application_subnet_address_prefix\",\n"
subnets="${subnets}    enforce_private_link_endpoint_network_policies = false\n"
subnets="${subnets}  }\n"
subnets="${subnets}}"

# Generate terraform.tfvars file
printf "\nGenerating terraform.tfvars file...\n\n"

printf "location                    = $default_location\n"                    > ./terraform.tfvars
printf "remote_virtual_network_id   = $default_remote_virtual_network_id\n"   >> ./terraform.tfvars
printf "remote_virtual_network_name = $default_remote_virtual_network_name\n" >> ./terraform.tfvars
printf "resource_group_name         = $default_resource_group_name\n"         >> ./terraform.tfvars
printf "subnets                     = $subnets\n"                             >> ./terraform.tfvars
printf "subscription_id             = $default_subscription_id\n"         >> ./terraform.tfvars
printf "tags                        = $default_tags\n"                        >> ./terraform.tfvars
printf "vnet_address_space          = \"$vnet_address_space\"\n"              >> ./terraform.tfvars
printf "vnet_name                   = \"$vnet_name\"\n"                       >> ./terraform.tfvars

cat ./terraform.tfvars

printf "\nReview defaults in \"variables.tf\" prior to applying Terraform configurations...\n"
printf "\nBootstrapping complete...\n"

exit 0
