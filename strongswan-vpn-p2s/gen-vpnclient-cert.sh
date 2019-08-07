#!/bin/bash 

COUNTRY=""
ORGANIZATION=""
USERNAME=""
PASSWORD=""

usage() {
    printf "Usage: $0 -c COUNTRY -o ORGANIZATION -u USERNAME -p PASSWORD\n" 1>&2
    exit 1
}

if [[ $# -eq 0 ]]; then
    usage
fi  

while getopts ":c:o:p:u:" option; do
    case "${option}" in
        c )
            COUNTRY=${OPTARG}
            ;;
        o )
            ORGANIZATION=${OPTARG}
            ;;
        P )
            PASSWORD=${OPTARG}
            ;;
        u )
            USERNAME=${OPTARG}
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

printf "Generating a new private key (${USERNAME}Key.pem)...\n"
ipsec pki --gen --outform pem > "${USERNAME}Key.pem"

printf "Generating a new client certificate (${USERNAME}Cert.pem) using the private key, CA certificate and CA private key...\n"
ipsec pki --issue --in "${USERNAME}Key.pem" --type priv \
  --cacert caCert.pem --cakey caKey.pem \
  --dn "C=${COUNTRY}, O=${ORGANIZATION}, CN=${USERNAME}" --san "${USERNAME}" --flag clientAuth \
  --outform pem > "${USERNAME}Cert.pem"

# Grab the public key from the newly generated private key, and use it to create a new X.509 user certificate
#ipsec pki --pub --in "${USERNAME}Key.pem" | ipsec pki --issue --cacert caCert.pem --cakey caKey.pem --dn "CN=${USERNAME}" --san "${USERNAME}" --flag clientAuth --outform pem > "${USERNAME}Cert.pem"

# Create a .p12 bundle including the certificate and private key and secure with a password
#openssl pkcs12 -in "${USERNAME}Cert.pem" -inkey "${USERNAME}Key.pem" -certfile caCert.pem -export -out "${USERNAME}.p12" -password "pass:${PASSWORD}"