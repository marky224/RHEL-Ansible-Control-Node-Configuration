#!/bin/bash
# 04-configure_ssh.sh
# Configures SSH service and keys on the RHEL 9 control node

source ./setup_logging.sh

# Generate or verify SSH key pair
if [ ! -f "/root/.ssh/id_rsa" ]; then
    log "Generating SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f /root/.ssh/id_rsa -N "" || {
        log "Error: Failed to generate SSH key pair"
        exit 1
    }
    log "SSH key pair generated"
else
    log "SSH key pair already exists"
fi
chmod 700 /root/.ssh
chmod 600 /root/.ssh/id_rsa*

# Enable and configure SSH service
log "Configuring SSH service..."
if ! systemctl is-active sshd >/dev/null 2>&1; then
    systemctl enable sshd --now || {
        log "Error: Failed to enable/start sshd"
        exit 1
    }
    log "SSH service enabled and started"
fi
if ! grep -q "^PasswordAuthentication no" /etc/ssh/sshd_config; then
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    systemctl restart sshd || {
        log "Error: Failed to restart sshd after config change"
        exit 1
    }
    log "SSH configured to disable password authentication"
fi
