#!/bin/bash

# Removes temporary files and folders recursively from current directory

printf "Removing all files matching 'terraform.*' and '*.txt'...\n"

find . -depth -type f -name 'terraform.*' -or -name '*.txt'
find . -depth -type f -name 'terraform.*' -or -name '*.txt'| xargs -r rm

printf "Removing all directories matching '.terraform'...\n"

find . -depth -type d -name '.terraform'
find . -depth -type d -name '.terraform' | xargs -r rm -r

exit 0
