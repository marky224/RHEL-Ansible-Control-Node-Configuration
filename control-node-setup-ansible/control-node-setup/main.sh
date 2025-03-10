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
./01-initialize_ansible_control_node.sh || { echo "Error: Logging setup failed"; exit 1; }
./02-configure_ansible_control_node.sh || { echo "Error: Logging setup failed"; exit 1; }

# Source logging for final message
source ./setup_logging.sh
log "Control node setup complete at 192.168.0.100"
log "Next steps: Configure remote nodes and update inventory yaml files."
