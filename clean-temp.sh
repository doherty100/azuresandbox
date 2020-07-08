#!/bin/bash

# Removes temporary files and folders recursively from current directory

printf "Removing all files matching 'terraform.*' and '*.txt'...\n"
find -name 'terraform.*' -or -name '*.txt'
find -name 'terraform.*' -or -name '*.txt' | xargs rm

printf "Removing all directories matching '.terraform'...\n"
find -name '.terraform'
find -name '.terraform' | xargs rm -r

exit 0
