#!/bin/bash
# 03-install_ansible.sh
# Installs Ansible and prerequisites on the RHEL 9 control node

source ./setup_logging.sh

# Prompt for Red Hat subscription credentials interactively
log "Prompting for Red Hat subscription credentials..."
read -p "Enter Red Hat subscription username: " SUB_USERNAME
if [ -z "$SUB_USERNAME" ]; then
    log "Error: Username cannot be empty"
    exit 1
fi
read -s -p "Enter Red Hat subscription password: " SUB_PASSWORD
echo
if [ -z "$SUB_PASSWORD" ]; then
    log "Error: Password cannot be empty"
    exit 1
fi
log "Subscription credentials provided"

# Install prerequisites and Ansible only if not already installed
if ! command -v ansible >/dev/null 2>&1; then
    log "Updating system and installing required packages..."
    # Check if already registered before attempting registration
    if ! subscription-manager status >/dev/null 2>&1; then
        subscription-manager register --username "$SUB_USERNAME" --password "$SUB_PASSWORD" --auto-attach || {
            log "Error: Failed to register subscription"
            exit 1
        }
        log "System registered with Red Hat subscription"
    else
        log "System already registered with Red Hat subscription"
    fi
    dnf update -y || {
        log "Error: Failed to update system"
        exit 1
    }
    dnf install -y python3 python3-pip curl openssl || {
        log "Error: Failed to install python3, python3-pip, curl, or openssl"
        exit 1
    }
    # Install Ansible via pip
    log "Installing Ansible via pip..."
    sudo pip3 install ansible pywinrm || {
        log "Error: Failed to install Ansible and pywinrm via pip"
        exit 1
    }
    log "Ansible installed successfully"
else
    log "Ansible already installed"
fi
