#!/bin/bash

# Dependencies: Azure CLI and graph extension (preview)

LOCATION=""
QUERY_TEXT=""
SUBSCRIPTION=""

usage() {
    printf "Usage: $0 \n  -l LOCATION\n  -s SUBSCRIPTION\n" 1>&2
    exit 1
}

while getopts ":hl:s:" option; do
    case "${option}" in
        l )
            LOCATION=${OPTARG}
            ;;
        h ) 
            usage
            ;;
        s ) 
            SUBSCRIPTION=${OPTARG}
            ;;
        : ) 
            printf "Error: -${OPTARG} requires an argument.\n"
            usage
            ;;
        * ) 
            printf "Error: Unknown option -${OPTARG}.\n"
            usage
            ;;
    esac
done

printf "Validating LOCATION '${LOCATION}'...\n"

LOCATION_ID=""
LOCATION_ID=$(az account list-locations --query "[?name=='${LOCATION}'].id" | tr -d '[]" \n')

if [[ -z ${LOCATION_ID} ]]; then
    printf "Error: Invalid LOCATION.\n"
    usage
fi

printf "Generating vm-sizes.json...\n"

az vm list-sizes -l ${LOCATION} -o json > vm-sizes.json

if [ $? != 0 ]; then
    printf "Error: Unable to generate vm-sizes.json.\n"
    usage
fi

if [[ -z ${SUBSCRIPTION} ]]; then
    printf "No subscription filter will be applied...\n"
else
    printf "Subscription filter '${SUBSCRIPTION}' will be applied...\n"
fi

FILE_COUNT=0

for FILENAME in ./*.kql
do
    let "FILE_COUNT++"

    if [ $FILE_COUNT -gt 1 ]; then
        printf "Sleeping for 30s to avoid throttling...\n"
        sleep 30s
    fi

    printf "Running resource graph query '${FILENAME}'...\n"

    if [[ -z ${SUBSCRIPTION} ]]; then 
        az graph query -q "$(<${FILENAME})" --first 5000 -o json > ${FILENAME}.json
    else
        az graph query -q "$(<${FILENAME})" -s ${SUBSCRIPTION} --first 5000 -o json > ${FILENAME}.json
    fi
    
    if [ $? != 0 ]; then
        printf "Error: Error running query '${FILENAME}'.\n"
        usage
    fi
    

done

if [ $FILENAME = "./*.kql" ]; then
    printf "Error: No .kql files found in current directory.\n"
    usage
fi

printf "\nRan ${FILE_COUNT} resource graph queries.\n\n"

ls ./*.json

exit 0
