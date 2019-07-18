#!/bin/bash 

# Loads Terraform azurerm provider environment variables into interactive shell 

# Prerequisites before running this script: 
# - Install jp CLI interface for JMESPath (see jpinstall.sh)
# - Run createserviceprinciple.sh once to generate subscription.json and sp.json files

# Important Note: 
# - Execute this script interactively using 'source' command, e.g. 'source ./setvariables.sh'.
# - If you do not the environment variables will not get set in the interactive shell.


# These environment variables will be exported to the interactive shell by running this script using 'source ./setvariables.sh'
export ARM_SUBSCRIPTION_ID=""
export ARM_CLIENT_ID=""
export ARM_CLIENT_SECRET=""
export ARM_TENANT_ID=""

printf "Setting ARM_SUBSCRIPTION_ID from subscription.json...\n"
export ARM_SUBSCRIPTION_ID=$(jp -f subscription.json "id" | tr -d '"')

if [ -z $ARM_SUBSCRIPTION_ID ]; then
    echo "Error: Unable to set ARM_SUBSCRIPTION_ID"
fi 

printf "Setting ARM_CLIENT_ID from sp.json...\n"
export ARM_CLIENT_ID=$(jp -f sp.json 'appId' | tr -d '"')

if [ -z $ARM_CLIENT_ID ]; then
    echo "Error: Unable to set ARM_CLIENT_ID"
fi 

printf "Setting ARM_CLIENT_SECRET from sp.json...\n"
export ARM_CLIENT_SECRET=$(jp -f sp.json 'password' | tr -d '"')

if [ -z $ARM_CLIENT_SECRET ]; then
    echo "Error: Unable to set ARM_CLIENT_SECRET"
fi 

printf "Setting ARM_TENANT_ID from sp.json...\n"
export ARM_TENANT_ID=$(jp -f sp.json 'tenant' | tr -d '"')

if [ -z $ARM_TENANT_ID ]; then
    echo "Error: Unable to set ARM_TENANT_ID"
fi 
