#!/bin/bash

printf "Removing all files matching '.terraform.lock.hcl'...\n"

find . -type f -name '.terraform.lock.hcl' 
find . -type f -name '.terraform.lock.hcl' | xargs -r rm

exit 0
