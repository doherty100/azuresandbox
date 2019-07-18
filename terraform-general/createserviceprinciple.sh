#!/bin/bash 

# Generates an Azure Active Directory service principal and writes the details to file sp.json

# Prerequisites before running this script: 
# - Install latest version of Azure CLI
# - Identify the Azure subscription you want to use and set it as the default using 'az account set -s'

printf "Getting default Azure subscription...\n"
SUBSCRIPTION_ID=$(az account list --query "[?isDefault].id" | tr -d '"[] \n')

printf "Generating service principal...\n\n"
az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/$SUBSCRIPTION_ID" > ./sp.json

printf "Generated sp.json file:\n\n"
cat ./sp.json
