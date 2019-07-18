#!/bin/bash

# Downloads terraform release and moves it to /usr/local/bin directory

wget https://releases.hashicorp.com/terraform/0.12.3/terraform_0.12.3_linux_amd64.zip
unzip terraform_0.12.3_linux_amd64.zip
sudo mv terraform /usr/local/bin/
terraform --version
