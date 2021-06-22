#!/bin/bash

printf "Removing all files matching 'terraform.*'...\n"

find . -type f -name 'terraform.*' 
find . -type f -name 'terraform.*' | xargs -r rm

printf "Removing all files and directories matching '.terraform'...\n"

find . -type d -name '.terraform'
find . -type d -name '.terraform' | xargs -r rm -r

printf "Removing all files matching '.terraform.tfstate.lock.info'...\n"

find . -type f -name '.terraform.tfstate.lock.info' 

exit 0
