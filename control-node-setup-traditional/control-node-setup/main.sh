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
./01-setup_logging.sh || { echo "Error: Logging setup failed"; exit 1; }
./02-configure_network.sh || { echo "Error: Network configuration failed"; exit 1; }
./03-install_ansible.sh || { echo "Error: Ansible installation failed"; exit 1; }
./04-configure_ssh.sh || { echo "Error: SSH configuration failed"; exit 1; }
./05-configure_firewall.sh || { echo "Error: Firewall configuration failed"; exit 1; }
./06-join-ad-and-configure-inventory.sh || { echo "Error: Active Directory configuration failed"; exit 1; }


# Source logging for final message
source ./setup_logging.sh
log "Control node setup complete at 192.168.0.100"
log "Next steps: Configure remote nodes and update ansible/inventory/inventory.yml."
