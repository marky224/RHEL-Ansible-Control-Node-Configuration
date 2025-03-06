#!/bin/bash

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
CERT_DEST="/etc/pki/tls/certs/win2025_cert.pem"

# Prompt for AD admin password securely
read -s -p "Enter AD Administrator password: " AD_ADMIN_PASS
echo ""

# Prompt for Ansible Vault password securely
read -s -p "Enter Ansible Vault password (for local encryption): " VAULT_PASS
echo ""

# Prompt for PEM file path
read -p "Enter the path to the WinRM HTTPS certificate PEM file (e.g., /tmp/win2025_cert.pem): " PEM_PATH
if [ ! -f "$PEM_PATH" ]; then
    echo "Error: PEM file not found at $PEM_PATH" | tee -a "$LOG_FILE"
    exit 1
fi

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

# Save and secure the Ansible Vault password
echo "$VAULT_PASS" | sudo tee /etc/ansible/vault_pass.txt > /dev/null
sudo chmod 600 /etc/ansible/vault_pass.txt
sudo chown root:root /etc/ansible/vault_pass.txt
echo "$(date) - Ansible Vault password saved securely" >> "$LOG_FILE"

# Encrypt the AD password with Ansible Vault
ENCRYPTED_PASS=$(ansible-vault encrypt_string --vault-id /etc/ansible/vault_pass.txt "$AD_ADMIN_PASS" --name 'ansible_password' | grep -v 'Encryption successful')

# Copy and secure the PEM certificate
sudo cp "$PEM_PATH" "$CERT_DEST"
sudo chmod 644 "$CERT_DEST"
sudo chown root:root "$CERT_DEST"
sudo update-ca-trust
echo "$(date) - WinRM HTTPS certificate saved and trusted at $CERT_DEST" >> "$LOG_FILE"

# Configure Ansible (overwrite existing ansible.cfg if present)
sudo mkdir -p /etc/ansible
cat <<EOF | sudo tee /etc/ansible/ansible.cfg
[defaults]
inventory = /etc/ansible/inventory.ini
host_key_checking = False
log_path = /var/log/ansible.log
vault_password_file = /etc/ansible/vault_pass.txt
EOF
echo "$(date) - Ansible configuration updated" >> "$LOG_FILE"

# Create inventory file with HTTPS for WinRM
cat <<EOF | sudo tee /etc/ansible/inventory.ini
[linux_nodes]
rhel9-control ansible_host=$RHEL_IP ansible_user=$AD_ADMIN_USER ansible_connection=ssh

[windows_nodes]
win2025 ansible_host=$AD_SERVER_IP ansible_user=$AD_ADMIN_USER ansible_connection=winrm ansible_winrm_transport=ntlm ansible_port=5986 ansible_winrm_scheme=https ansible_winrm_ca_trust_path=$CERT_DEST $ENCRYPTED_PASS
EOF
sudo chmod 644 /etc/ansible/inventory.ini
echo "$(date) - Ansible inventory created with WinRM HTTPS and Vault encryption" >> "$LOG_FILE"

echo "$(date) - RHEL 9 AD join and inventory configuration complete" >> "$LOG_FILE"
echo "Setup complete. Use 'ansible --vault-id /etc/ansible/vault_pass.txt' for commands requiring the vault."
