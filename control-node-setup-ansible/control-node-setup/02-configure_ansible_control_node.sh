#!/bin/bash
# 02-configure_ansible_control_node.sh
# Configures Ansible control node after initialization by prompting for credentials,
# setting up inventory, and running the playbook

# Exit on any error
set -e

# Variables
ANSIBLE_DIR="${ANSIBLE_DIR:-/root/ansible_project}"
LOG_FILE="/var/log/ansible_config.log"
VARS_FILE="$ANSIBLE_DIR/vars/control_node_vars.yml"
INVENTORY_FILE="$ANSIBLE_DIR/inventory.yml"

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
log "Starting Ansible control node configuration"

# Step 1: Populate control_node_vars.yml with Red Hat credentials and SSH key
log "Step 1: Configuring $VARS_FILE with sensitive data..."

# Prompt for Red Hat credentials
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
log "Red Hat credentials provided"

# Generate SSH RSA private key if it doesn't exist
SSH_KEY_FILE="/root/.ssh/id_rsa"
if [ ! -f "$SSH_KEY_FILE" ]; then
    log "Generating SSH RSA key pair..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_FILE" -N "" || {
        log "Error: Failed to generate SSH key pair"
        exit 1
    }
    chmod 600 "$SSH_KEY_FILE"
    chmod 644 "$SSH_KEY_FILE.pub"
    log "SSH key pair generated at $SSH_KEY_FILE"
else
    log "Existing SSH key found at $SSH_KEY_FILE, using it"
fi

# Read the private key content
SSH_PRIVATE_KEY=$(cat "$SSH_KEY_FILE" | sed 's/^/  /')  # Indent for YAML formatting

# Write to control_node_vars.yml
cat << EOF > "$VARS_FILE"
---
# Sensitive variables for control node
sub_username: "$SUB_USERNAME"
sub_password: "$SUB_PASSWORD"
ssh_private_key: |
$SSH_PRIVATE_KEY
EOF

chmod 600 "$VARS_FILE"
log "$VARS_FILE populated with Red Hat credentials and SSH private key"

# Step 2: Verify or create inventory.yml with localhost
log "Step 2: Verifying or creating $INVENTORY_FILE..."

if [ -f "$INVENTORY_FILE" ]; then
    if grep -q "localhost" "$INVENTORY_FILE"; then
        log "Inventory file exists and contains localhost"
    else
        log "Warning: $INVENTORY_FILE exists but lacks localhost, appending..."
        cat << EOF >> "$INVENTORY_FILE"

all:
  children:
    control_node:
      hosts:
        localhost:
          ansible_connection: local
          ansible_python_interpreter: /usr/bin/python3
EOF
    fi
else
    log "Creating new $INVENTORY_FILE with localhost..."
    cat << EOF > "$INVENTORY_FILE"
---
all:
  children:
    control_node:
      hosts:
        localhost:
          ansible_connection: local
          ansible_python_interpreter: /usr/bin/python3
EOF
fi
chmod 644 "$INVENTORY_FILE"
log "Inventory file ready at $INVENTORY_FILE"

# Step 3: Run the control node setup playbook
log "Step 3: Running control node setup playbook..."
cd "$ANSIBLE_DIR/control-node-setup" || { log "Error: Directory $ANSIBLE_DIR/control-node-setup not found"; exit 1; }

# Check if playbook exists
PLAYBOOK="control_node_setup.yml"
if [ ! -f "$PLAYBOOK" ]; then
    log "Error: $PLAYBOOK not found in $ANSIBLE_DIR/control-node-setup"
    exit 1
fi

# Run the playbook
log "Executing: ansible-playbook $PLAYBOOK -i ../inventory.yml"
ansible-playbook "$PLAYBOOK" -i "../inventory.yml" || {
    log "Error: Playbook execution failed, check $LOG_FILE or run with -v for details"
    exit 1
}
log "Playbook executed successfully!"

# Final instructions
cat << EOF
Ansible control node configuration completed!
- Check logs at $LOG_FILE for details.
- Next, update $INVENTORY_FILE with managed nodes as needed.
- Run remote node setup with: cd $ANSIBLE_DIR/remote-node-setup && ansible-playbook remote_node_setup.yml -i ../inventory.yml
EOF