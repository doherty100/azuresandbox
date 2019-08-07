#!/bin/bash 

openssl x509 -in caCert.pem -outform der | base64 -w0 ; echo
