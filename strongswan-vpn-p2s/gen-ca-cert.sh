#!/bin/bash 

COUNTRY=""
ORGANIZATION=""
COMMON_NAME=""

usage() {
    printf "Usage: $0 -c COUNTRY -o ORGANIZATION -n COMMON_NAME\n" 1>&2
    exit 1
}

if [[ $# -eq 0 ]]; then
    usage
fi  

while getopts ":c:n:o:" option; do
    case "${option}" in
        c )
            COUNTRY=${OPTARG}
            ;;
        n )
            COMMON_NAME=${OPTARG}
            ;;
        o )
            ORGANIZATION=${OPTARG}
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

printf "Generating a new private key (caKey.pem)...\n"
ipsec pki --gen --outform pem > caKey.pem

printf "Generating a new self-signed CA certificate (caCert.pem) using the private key (caKey.pem)...\n"
ipsec pki --self --in caKey.pem --dn "C=${COUNTRY}, O=${ORGANIZATION}, CN=${COMMON_NAME}" --ca --outform pem > caCert.pem
