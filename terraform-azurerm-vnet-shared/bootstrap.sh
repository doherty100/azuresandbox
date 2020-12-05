#!/bin/bash

# Bootstraps deployment with pre-requisites for applying Terraform configurations
# Script is idempotent and can be run multiple times

usage() {
    printf "Usage: $0 \n" 1>&2
    exit 1
}

# Set these defaults prior to running the script.
default_project="#AzureQuickStarts"
default_costcenter="10177772"
default_environment="dev"
default_resource_group_name="rg-vdc-nonprod-001"
default_location="eastus2"
default_vnet_name="vnet-shared-001"
default_vnet_address_space="10.1.0.0/16"
default_default_subnet_name="snet-default-001"
default_default_subnet_address_prefix="10.1.0.0/24"
default_bastion_subnet_name="AzureBastionSubnet"
default_bastion_subnet_address_prefix="10.1.1.0/27"
default_privatelink_subnet_name="snet-storage-private-endpoints-001"
default_privatelink_subnet_address_prefix="10.1.2.0/24"

# Intialize runtime defaults
upn=$(az ad signed-in-user show --query userPrincipalName --output tsv)
default_owner_object_id=$(az ad user show --id $upn --query objectId --output tsv)
default_aad_tenant_id=$(az account list --query "[? isDefault]|[0].tenantId" --output tsv)

# User input
read -e -i $default_project                           -p "project ---------------------------: " project
read -e -i $default_costcenter                        -p "costcenter ------------------------: " costcenter
read -e -i $default_environment                       -p "environment -----------------------: " environment
read -e -i $default_resource_group_name               -p "resource group name ---------------: " resource_group_name
read -e -i $default_location                          -p "location --------------------------: " location
read -e -i $default_aad_tenant_id                     -p "aad tenant id ---------------------: " aad_tenant_id
read -e -i $default_owner_object_id                   -p "owner object id -------------------: " owner_object_id
read -e -i $default_vnet_name                         -p "vnet name -------------------------: " vnet_name
read -e -i $default_vnet_address_space                -p "vnet address space ----------------: " vnet_address_space
read -e -i $default_default_subnet_name               -p "default subnet name ---------------: " default_subnet_name
read -e -i $default_default_subnet_address_prefix     -p "default subnet address prefix -----: " default_subnet_address_prefix
read -e -i $default_bastion_subnet_name               -p "bastion subnet name ---------------: " bastion_subnet_name
read -e -i $default_bastion_subnet_address_prefix     -p "bastion subnet address prefix -----: " bastion_subnet_address_prefix
read -e -i $default_privatelink_subnet_name           -p "privatelink subnet name -----------: " privatelink_subnet_name
read -e -i $default_privatelink_subnet_address_prefix -p "privatelink subnet address prefix -: " privatelink_subnet_address_prefix

project=${project:-$default_project}
costcenter=${costcenter:-$default_costcenter}
environment=${environment:-$default_environment}
resource_group_name=${resource_group_name:-$default_resource_group_name}
location=${location:-$default_location}
aad_tenant_id=${aad_tenant_id:-$default_aad_tenant_id}
owner_object_id=${owner_object_id:-$default_owner_object_id}
vnet_name=${vnet_name:=$default_vnet_name}
vnet_address_space=${vnet_address_space:-default_vnet_address_space}
default_subnet_name=${default_subnet_name:-default_default_subnet_name}
default_subnet_address_prefix=${default_subnet_address_prefix:-default_default_subnet_address_prefix}
bastion_subnet_name=${bastion_subnet_name:-default_bastion_subnet_name}
bastion_subnet_address_prefix=${bastion_subnet_address_prefix:-default_bastion_subnet_address_prefix}
privatelink_subnet_name=${privatelink_subnet_name:-default_privatelink_subnet_name}
privatelink_subnet_address_prefix=${privatelink_subnet_address_prefix:-default_privatelink_subnet_address_prefix}

# Validate location
location_id=$(az account list-locations --query "[?name=='$location'].id" --output tsv)

if [ -z "$location_id" ]
then
  printf "Invalid location '$location'...\n"
  usage
fi

# Build subnet map

subnets=""
subnets="${subnets}{\n"
subnets="${subnets}  default = {\n"
subnets="${subnets}    name                                           = \"$default_subnet_name\",\n"
subnets="${subnets}    address_prefix                                 = \"$default_subnet_address_prefix\",\n"
subnets="${subnets}    enforce_private_link_endpoint_network_policies = false\n"
subnets="${subnets}  },\n"
subnets="${subnets}  AzureBastionSubnet = {\n"
subnets="${subnets}    name                                           = \"$bastion_subnet_name\",\n"
subnets="${subnets}    address_prefix                                 = \"$bastion_subnet_address_prefix\",\n"
subnets="${subnets}    enforce_private_link_endpoint_network_policies = false\n"
subnets="${subnets}  },\n"
subnets="${subnets}  PrivateLink = {\n"
subnets="${subnets}    name                                           = \"$privatelink_subnet_name\",\n"
subnets="${subnets}    address_prefix                                 = \"$privatelink_subnet_address_prefix\",\n"
subnets="${subnets}    enforce_private_link_endpoint_network_policies = true\n"
subnets="${subnets}  }\n"
subnets="${subnets}}"

# Build tags map
tags=""
tags="${tags}{\n"
tags="${tags}  project     = \"$project\",\n"
tags="${tags}  costcenter  = \"$costcenter\",\n"
tags="${tags}  environment = \"$environment\"\n"
tags="${tags}}"

# Generate terraform.tfvars file
printf "\nGenerating terraform.tfvars file...\n\n"

printf "aad_tenant_id       = \"$aad_tenant_id\"\n"       > ./terraform.tfvars
printf "location            = \"$location\"\n"            >> ./terraform.tfvars
printf "owner_object_id     = \"$owner_object_id\"\n"     >> ./terraform.tfvars
printf "resource_group_name = \"$resource_group_name\"\n" >> ./terraform.tfvars
printf "subnets             = $subnets\n"                 >> ./terraform.tfvars
printf "tags                = $tags\n"                    >> ./terraform.tfvars
printf "vnet_address_space  = \"$vnet_address_space\"\n"  >> ./terraform.tfvars
printf "vnet_name           = \"$vnet_name\"\n"           >> ./terraform.tfvars

cat ./terraform.tfvars

printf "\nReview defaults in 'variables.tf' prior to applying Terraform plans...\n"
printf "\nBootstrapping complete...\n"

exit 0
