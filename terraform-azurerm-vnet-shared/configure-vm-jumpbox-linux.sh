#!/bin/bash

# Note: This code has been tested on Ubuntu 20.04 LTS (Focal Fossa) and will not work on other Linux distros

# Initialize constants
log_file='/run/cloud-init/tmp/configure-vm-jumpbox-linux.log'
dhcp_exit_hook_script='/etc/dhcp/dhclient-exit-hooks.d/hook-ddns'
key_vault_tag_name='keyvault'
domain_name_tag_name='adds_domain_name'

# Startup
printf  '=%.0s' {1..100} > $log_file
printf  '\n' >> $log_file
printf "Timestamp: $(date +"%Y-%m-%d %H:%M:%S.%N %Z")...\n" >> $log_file
printf "Starting '$0'...\n" >> $log_file

# Get key vault from tags
printf "Getting key vault from tags...\n" >> $log_file
key_vault_name=$(jp -f "/run/cloud-init/instance-data.json" -u "ds.meta_data.imds.compute.tagsList[?name == '$key_vault_tag_name'] | [0].value")
printf "Key vault name is '$key_vault_name'...\n" >> $log_file

# Get domain name from tags
printf "Getting domain name from tags...\n" >> $log_file
adds_domain_name=$(jp -f "/run/cloud-init/instance-data.json" -u "ds.meta_data.imds.compute.tagsList[?name == '$domain_name_tag_name'] | [0].value")
printf "Domain name is '$adds_domain_name'...\n" >> $log_file
adds_realm_name=$(echo $adds_domain_name | tr '[:lower:]' '[:upper:]')
printf "Realm name is '$adds_realm_name'...\n" >> $log_file

# Get managed identity access token for key vault
printf "Getting managed identity access token...\n" >> $log_file
response=$(curl 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https%3A%2F%2Fvault.azure.net' -H Metadata:true -s)
access_token=$(echo $response |  jp -u 'access_token')
printf "Access token length is '${#access_token}'...\n" >> $log_file

# Get adminuser secret from key vault
secret_name="adminuser"
printf "Getting '$secret_name' secret from key vault...\n" >> $log_file
secret_uri="https://$key_vault_name.vault.azure.net/secrets/$secret_name?api-version=7.2"
admin_username=$(curl -X GET -H "Authorization: Bearer $access_token" -H "Content-Type:appplication/json" "$secret_uri" | jp -u 'value')
printf "Value of '$secret_name' secret is '$admin_username'...\n" >> $log_file

# Get adminpassword secret from key vault
secret_name="adminpassword"
printf "Getting '$secret_name' secret from key vault...\n" >> $log_file
secret_uri="https://$key_vault_name.vault.azure.net/secrets/$secret_name?api-version=7.2"
admin_password=$(curl -X GET -H "Authorization: Bearer $access_token" -H "Content-Type:appplication/json" "$secret_uri" | jp -u 'value')
printf "Length of '$secret_name' secret is '${#admin_password}'...\n" >> $log_file

# Update hosts file
printf "Backing up /etc/hosts...\n" >> $log_file
sudo cp -f /etc/hosts /etc/hosts.bak 
printf "Updating /etc/hosts...\n" >> $log_file
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file
sudo sed -i "s/127.0.0.1 localhost/127.0.0.1 `hostname`.$adds_domain_name `hostname`/" /etc/hosts
cat /etc/hosts >> $log_file
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file

# Update DHCP configuration
printf "Backing up /etc/dhclient.conf...\n" >> $log_file
sudo cp -f /etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf.bak
printf "Updating DHCP configuration...\n" >> $log_file
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file
sudo sed -i "s/#supersede domain-name \"fugue.com home.vix.com\";/supersede domain-name \"$adds_domain_name\";/" /etc/dhcp/dhclient.conf
cat /etc/dhcp/dhclient.conf >> $log_file
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file

# Update NTP configuration
printf "Backing up /etc/ntp.conf...\n" >> $log_file
sudo cp -f /etc/ntp.conf /etc/ntp.conf.bak
printf "Updating NTP configuration...\n" >> $log_file
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file
sudo sed -i "$ a server $adds_domain_name" /etc/ntp.conf
cat /etc/ntp.conf >> $log_file
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file

# Update Kerberos configuration
printf "Backing up /etc/krb5.conf...\n" >> $log_file
sudo cp -f /etc/krb5.conf /etc/krb5.conf.bak
printf "Updating Kerberos configuration...\n" >> $log_file
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file
sudo sed -i '/^\[libdefaults\]/a \        rdns=false' /etc/krb5.conf
cat /etc/krb5.conf >> $log_file
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file

# Join domain
printf "Renewing DHCP lease...\n" >> $log_file
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file
sudo dhclient eth0 -v &>> $log_file
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file
printf "Joining domain...\n" >> $log_file
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file
echo $admin_password | sudo realm join --verbose $adds_realm_name -U "$admin_username@$adds_realm_name" --install=/ &>> $log_file
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file

# Create keytab file then authenticate with AD
printf "Creating keytab file...\n" >> $log_file
printf "%b" "addent -password -p $admin_username@$adds_realm_name -k 1 -e RC4-HMAC\n$admin_password\nwkt /etc/$admin_username.keytab\nq\n" | sudo ktutil &>> $log_file
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file
printf "Authenticating using keytab file...\n" >> $log_file
sudo kinit -V -k -t /etc/$admin_username.keytab $admin_username@$adds_realm_name &>> $log_file

# Register with DNS server
printf "Registering with DNS server...\n" >> $log_file
printf "%b" "update add `hostname`.$adds_domain_name 3600 a `hostname -I`\nsend\n" | sudo nsupdate -g &>> $log_file

# Configure dynamic DNS registration
printf "Creating DHCP client exit hook...\n" >> $log_file
echo '#!/bin/sh' | sudo tee $dhcp_exit_hook_script > /dev/null
echo 'adds_realm_name=$(echo $new_domain_name | tr "[:lower:]" "[:upper:]")' | sudo tee -a $dhcp_exit_hook_script  > /dev/null
echo "host=\`hostname\`" | sudo tee -a $dhcp_exit_hook_script  > /dev/null
echo "admin_username=$admin_username" | sudo tee -a $dhcp_exit_hook_script  > /dev/null
echo 'if [ "$interface" != "eth0" ]' | sudo tee -a $dhcp_exit_hook_script  > /dev/null
echo 'then' | sudo tee -a $dhcp_exit_hook_script  > /dev/null
echo '  return' | sudo tee -a $dhcp_exit_hook_script  > /dev/null
echo 'fi' | sudo tee -a $dhcp_exit_hook_script  > /dev/null
echo 'if [ "$reason" = BOUND ] || [ "$reason" = RENEW ] ||' | sudo tee -a $dhcp_exit_hook_script  > /dev/null
echo '   [ "$reason" = REBIND ] || [ "$reason" = REBOOT ]' | sudo tee -a $dhcp_exit_hook_script  > /dev/null
echo 'then' | sudo tee -a $dhcp_exit_hook_script  > /dev/null
echo '  sudo kinit -k -t /etc/$admin_username.keytab $admin_username@$adds_realm_name' | sudo tee -a $dhcp_exit_hook_script  > /dev/null
echo '  printf "%b" "update delete $host.$new_domain_name a\nupdate add $host.$new_domain_name 3600 a $new_ip_address\nsend\n" | nsupdate -g' | sudo tee -a $dhcp_exit_hook_script  > /dev/null
echo 'fi' | sudo tee -a $dhcp_exit_hook_script  > /dev/null
sudo chmod 755 $dhcp_exit_hook_script
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file
sudo cat $dhcp_exit_hook_script >> $log_file

# Exit
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file
printf "Exiting '$0'...\n" >> $log_file
printf "Timestamp: $(date +"%Y-%m-%d %H:%M:%S.%N %Z")...\n" >> $log_file
printf  '=%.0s' {1..100} >> $log_file
printf  '\n' >> $log_file
exit 0
