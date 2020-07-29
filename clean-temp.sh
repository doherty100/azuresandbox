#!/bin/bash

# Removes temporary files and folders recursively from current directory

printf "Removing all files matching 'terraform.*', '*.txt' and '*.json'...\n"

find . -type f -name 'terraform.*' -or -name '*.txt' -or -name '*.json'
find . -type f -name 'terraform.*' -or -name '*.txt' -or -name '*.json' | xargs -r rm

printf "Removing all directories matching '.terraform'...\n"

find . -type d -name '.terraform'
find . -type d -name '.terraform' | xargs -r rm -r

exit 0
