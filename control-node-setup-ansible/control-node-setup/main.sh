#!/bin/bash
# main.sh
# Orchestrates the initialization and configuration of the Ansible control node

# Exit on any error
set -e

# Variables
LOG_FILE="/var/log/ansible_main.log"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"

# Function to log messages
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    log "Error: This script must be run as root"
    exit 1
fi

# Initialize logging
touch "$LOG_FILE" || { log "Error: Cannot create log file at $LOG_FILE"; exit 1; }
chmod 644 "$LOG_FILE"
log "Starting Ansible control node setup orchestration"

# Step 1: Run initialization script
log "Running 01-initialize_ansible_control_node.sh..."
"$SCRIPT_DIR/01-initialize_ansible_control_node.sh" || {
    log "Error: Initialization failed, check $LOG_FILE or /var/log/ansible_init.log"
    exit 1
}
log "Initialization completed successfully"

# Step 2: Run configuration script
log "Running 02-configure_ansible_control_node.sh..."
"$SCRIPT_DIR/02-configure_ansible_control_node.sh" || {
    log "Error: Configuration failed, check $LOG_FILE or /var/log/ansible_config.log"
    exit 1
}
log "Configuration completed successfully"

# Final message
log "Ansible control node setup completed!"
echo "Setup complete! Check $LOG_FILE for details."
