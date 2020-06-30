#!/bin/sh

writelog() {
    MSG=$1
    TIMESTAMP=$(date +"%F %T %Z")
    printf "${TIMESTAMP}: ${MSG}\n" >> $0.log
}

writelog "Updating packages..."
apt update

writelog "Exiting normally..."
exit 0
