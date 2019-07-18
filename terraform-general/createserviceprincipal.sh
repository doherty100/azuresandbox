#!/bin/bash 

# Use this script to configure Terraform authentication to Azure using a Service Principal with a Client Secret as per these docs:
# https://www.terraform.io/docs/providers/azurerm/auth/service_principal_client_secret.html
# Run this script once prior to running setvariables.sh

# This script creates a service principal with Contribtor rights using the default Azure subscription and generates three temporary files:
# - subscription.json (used by setvariables.sh to set ARM_SUBSCRIPTION_ID environment variable)
# - sp.json (used by setvariables.sh to set ARM_CLIENT_ID, ARM_CLIENT_SECRET and ARM_TENANT_ID environment variables)
# - spdetails.json (used to grant key vault access policies to the service principal)

# IMPORTANT: These temporary json files contain secrets which should be deleted after use. Do not check them into a source repository

# Prerequisites before running this script: 
# - Make sure you have RBAC privileges on your default Azure subscripton sufficient to create service principals
# - Install latest version of Azure CLI

# Set these environment variables by passing parameters to this script 
RESOURCE_GROUP=""
VAULT_NAME=""

# These are temporary variables
APP_ID=""
OBJECT_ID=""

usage() {
    echo "Usage: $0 -g RESOURCE_GROUP -v VAULT_NAME" 1>&2
    exit 1
}

if [[ $# -eq 0  ]]; then
    usage
fi  

while getopts ":g:v:" option; do
    case "${option}" in
        g ) 
            RESOURCE_GROUP=${OPTARG}
            ;;
        v ) 
            VAULT_NAME=${OPTARG}
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

printf "Logging into Azure CLI...\n"
az login 

if [ $? != 0 ]; then
    echo "Error: az login failed."
    usage
fi

# Validate resource group
printf "Checking resource group...\n"
az group show -n $RESOURCE_GROUP

if [ $? != 0 ]; then
    echo "Error: Resource group '$RESOURCE_GROUP' not found."
    usage
fi

# Validate KeyVault
printf "Checking key vault...\n"
az keyvault show -n $VAULT_NAME -g $RESOURCE_GROUP

if [ $? != 0 ]; then
    echo "Error: Key vault '$VAULT_NAME' not found."
    usage
fi

printf "Generating subscription.json file using default subscription...\n"
SUBSCRIPTION_ID=$(az account list --query "[?isDefault].id" | tr -d '"[] \n')
az account show -s $SUBSCRIPTION_ID > ./subscription.json

if [ $? != 0 ]; then
    echo "Error: Attempt to view subscription $SUBSCRIPTION_ID failed."
    usage
fi

cat ./subscription.json

printf "Creating service principal...\n"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" > ./sp.json

if [ $? != 0 ]; then
    echo "Error: Attempt to create service principal failed."
    usage
fi

cat ./sp.json

printf "Getting AppId for newly created service principal...\n"
APP_ID=$(jp -f sp.json 'appId' | tr -d '"')

if [ -z $APP_ID ]; then
    echo "Error: Attempt to retrieve appId failed."
    usage
fi

printf "Generating spdetails.json for newly created service principal...\n"
az ad sp show --id $APP_ID > ./spdetails.json

if [ $? != 0 ]; then
    echo "Error: Attempt to get details for service principal failed."
    usage
fi

cat ./spdetails.json

printf "Getting objectId for service principal...\n"
OBJECT_ID=$(jp -f spdetails.json 'objectId' | tr -d '"')

if [ -z $OBJECT_ID ]; then
    echo "Error: Attempt to retrieve objectId failed."
    usage
fi

printf "Setting key vault access policies for service principal...\n"
az keyvault set-policy -n $VAULT_NAME -g $RESOURCE_GROUP --object-id $OBJECT_ID --secret-permissions get

if [ $? != 0 ]; then
    echo "Error: Attempt to set key vault access policies failed."
    usage
fi

printf "Logging out of Azure CLI...\n"
az logout 

printf "\nRun 'source ./setvariables.sh next.\n"

exit 0
