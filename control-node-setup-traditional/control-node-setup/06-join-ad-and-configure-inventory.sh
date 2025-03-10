#!/bin/bash
# 06-join-ad-and-configure-inventory.sh
# This script handles AD joining, Ansible Vault setup, and inventory creation.


# Enable logging
LOG_FILE="/var/log/rhel_ad_join.log"
echo "$(date) - Starting RHEL 9 AD join and inventory configuration" >> "$LOG_FILE"

# Exit on error
set -e

# Variables
AD_DOMAIN="msp.local"
AD_SERVER_IP="192.168.0.10"
AD_ADMIN_USER="Administrator@$AD_DOMAIN"
RHEL_IP="192.168.0.100"

# Prompt for AD admin password securely
read -s -p "Enter AD Administrator password: " AD_ADMIN_PASS
echo "" # Newline after password input

# Install AD integration packages
sudo dnf install -y realmd sssd oddjob oddjob-mkhomedir samba-common-tools krb5-workstation chrony >> "$LOG_FILE" 2>&1 || { echo "Package install failed" >> "$LOG_FILE"; exit 1; }

# Configure DNS to point to AD DC
echo "nameserver $AD_SERVER_IP" | sudo tee /etc/resolv.conf
echo "search $AD_DOMAIN" | sudo tee -a /etc/resolv.conf
echo "$(date) - DNS configured" >> "$LOG_FILE"

# Configure time synchronization with AD DC
sudo systemctl enable --now chronyd >> "$LOG_FILE" 2>&1
sudo chronyc -a "server $AD_SERVER_IP iburst" >> "$LOG_FILE" 2>&1
sudo chronyc -a 'makestep' >> "$LOG_FILE" 2>&1
echo "$(date) - Time sync configured" >> "$LOG_FILE"

# Join the AD domain
echo "$AD_ADMIN_PASS" | sudo realm join -U "$AD_ADMIN_USER" "$AD_DOMAIN" >> "$LOG_FILE" 2>&1 || { echo "AD join failed" >> "$LOG_FILE"; exit 1; }
echo "$(date) - Successfully joined $AD_DOMAIN" >> "$LOG_FILE"

# Enable home directory creation for AD users
sudo authselect select sssd with-mkhomedir --force >> "$LOG_FILE" 2>&1
echo "$(date) - SSSD configured with home directory creation" >> "$LOG_FILE"

# Configure Ansible Vault with the password
echo "$AD_ADMIN_PASS" | ansible-vault encrypt_string --name 'ansible_password' > /etc/ansible/vault_password.yml
echo "$(date) - Ansible Vault configured" >> "$LOG_FILE"

# Create inventory file with encrypted password reference
cat <<EOF | sudo tee /etc/ansible/inventory.ini
[linux_nodes]
rhel9-control ansible_host=$RHEL_IP ansible_user=$AD_ADMIN_USER ansible_connection=ssh

[windows_nodes]
win2025 ansible_host=$AD_SERVER_IP ansible_user=$AD_ADMIN_USER ansible_connection=winrm ansible_winrm_transport=ntlm ansible_port=5985 ansible_winrm_scheme=http ansible_password={{ ansible_password }}
EOF
echo "$(date) - Ansible inventory created" >> "$LOG_FILE"

# Secure permissions
sudo chmod 600 /etc/ansible/vault_password.yml
sudo chmod 644 /etc/ansible/inventory.ini
sudo chown root:root /etc/ansible/vault_password.yml /etc/ansible/inventory.ini

echo "$(date) - RHEL 9 AD join and inventory configuration complete" >> "$LOG_FILE"
echo "Setup complete. Use 'ansible --vault-id /etc/ansible/vault_password.yml' for commands requiring the vault."
