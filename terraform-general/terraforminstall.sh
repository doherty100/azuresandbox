#!/bin/bash

# Installs a specific version of Terraform on Ubuntu. See https://releases.hashicorp.com/terraform/ for a list of releases. 
# Version parameter should be passed in the format "0.00.0" e.g. "0.12.6"

VERSION=""

usage() {
    echo "Usage: $0 -v VERSION" 1>&2
    exit 1
}

if [[ $# -eq 0  ]]; then
    usage
fi  

while getopts ":v:" option; do
    case "${option}" in
        v ) 
            VERSION=${OPTARG}
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

printf "Downloading Terraform version ${VERSION}...\n"
wget "https://releases.hashicorp.com/terraform/${VERSION}/terraform_${VERSION}_linux_amd64.zip" 

if [ $? != 0 ]; then
    echo "Error: Download failed."
    usage
fi

printf "Unzipping archive...\n"
unzip "terraform_${VERSION}_linux_amd64.zip"

if [ $? != 0 ]; then
    echo "Error: Unzip failed."
    usage
fi

printf "Moving unzipped terraform folder to /usr/local/bin...\n"
sudo mv terraform /usr/local/bin/

if [ $? != 0 ]; then
    echo "Error: Move failed."
    usage
fi

printf "Checking terraform version...\n"
terraform --version

if [ $? != 0 ]; then
    echo "Error: Version check failed."
    usage
fi

exit 0
