#!/bin/bash

# Dependencies: Azure CLI and graph extension (preview)

FILE_COUNT=0
QUERY_TEXT=""
RESOURCE_GROUP_NAME=""

usage() {
    printf "Usage: $0 \n  -g RESOURCE_GROUP_NAME\n" 1>&2
    exit 1
}

if [[ $# -eq 0  ]]; then
    usage
fi  

while getopts ":g:" option; do
    case "${option}" in
        g ) 
            RESOURCE_GROUP_NAME=${OPTARG}
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
    printf "Error: Resource group '$RESOURCE_GROUP_NAME' not found.\n"
    usage
fi

for FILENAME in ./*.kql
do
    let "FILE_COUNT++"
    printf "Creating shared query '${FILENAME}' in resource group '${RESOURCE_GROUP_NAME}'...\n"
    QUERY_TEXT=$(<${FILENAME})
    
    az graph shared-query create -g "${RESOURCE_GROUP_NAME}" -n "${FILENAME}" -d "" -q "${QUERY_TEXT}"    
    
    if [ $? != 0 ]; then
        printf "Error: Error creating shared query '${FILENAME}'.\n"
        usage
    fi
done

if [ $FILENAME = "./*.kql" ]; then
    printf "Error: No .kql files found in current directory.\n"
    usage
fi

printf "\nCreated ${FILE_COUNT} shared queries.\n"

exit 0
