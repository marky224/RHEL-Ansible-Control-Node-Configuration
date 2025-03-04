#!/bin/bash
# main.sh
# Orchestrates Ansible control node setup on RHEL 9

# Ensure script runs with sudo if not root
if [ "$EUID" -ne 0 ]; then
    echo "Error: Please run as root or with sudo"
    exit 1
fi

# Verify RHEL 9
if ! grep -q "Red Hat Enterprise Linux 9" /etc/os-release; then
    echo "Error: This script is designed for RHEL 9 only"
    exit 2
fi

# Run setup scripts
./setup_logging.sh || { echo "Error: Logging setup failed"; exit 1; }
./configure_network.sh || { echo "Error: Network configuration failed"; exit 1; }
./install_ansible.sh || { echo "Error: Ansible installation failed"; exit 1; }
./configure_ssh.sh || { echo "Error: SSH configuration failed"; exit 1; }
./configure_firewall.sh || { echo "Error: Firewall configuration failed"; exit 1; }

# Source logging for final message
source ./setup_logging.sh
log "Control node setup complete at 192.168.10.100"
log "Next steps: Configure remote nodes and update ansible/inventory/inventory.yml."
