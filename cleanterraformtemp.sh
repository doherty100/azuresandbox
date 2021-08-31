#!/bin/bash

printf "Removing all files matching 'terraform.*'...\n"

find . -type f -name 'terraform.*' 
find . -type f -name 'terraform.*' | xargs -r rm

printf "Removing all files and directories matching '.terraform'...\n"

find . -type d -name '.terraform'
find . -type d -name '.terraform' | xargs -r rm -r

printf "Removing all files matching 'terraform.lock.hcl'...\n"

find . -type f -name '.terraform.tfstate.lock.info' 
find . -type f -name '.terraform.tfstate.lock.info' | xargs -r rm -r 

exit 0
