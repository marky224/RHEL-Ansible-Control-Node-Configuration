#!/bin/bash
# 01-initialize_ansible_control_node.sh
# Initializes Ansible on a newly provisioned RHEL 9 server to act as a control node

# Exit on any error
set -e

# Variables
LOG_FILE="/var/log/ansible_init.log"
ANSIBLE_DIR="/root/ansible_project"
GITHUB_REPO="https://github.com/<your-username>/<your-repo>.git"  # Replace with your repo URL

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
log "Initializing Ansible control node setup"

# Update system
log "Updating system packages..."
dnf update -y || { log "Error: Failed to update system"; exit 1; }

# Install prerequisites
log "Installing prerequisites (python3, pip, git)..."
dnf install -y python3 python3-pip git || { log "Error: Failed to install prerequisites"; exit 1; }

# Install Ansible
log "Installing Ansible..."
pip3 install ansible --user || { log "Error: Failed to install Ansible"; exit 1; }
export PATH="$HOME/.local/bin:$PATH"
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
ansible --version && log "Ansible installed: $(ansible --version | head -n 1)" || { log "Error: Ansible not functional"; exit 1; }

# Create Ansible project directory
log "Setting up Ansible project directory at $ANSIBLE_DIR..."
if [ ! -d "$ANSIBLE_DIR" ]; then
    mkdir -p "$ANSIBLE_DIR"
    chmod 700 "$ANSIBLE_DIR"
fi
cd "$ANSIBLE_DIR"

# Clone GitHub repo or create structure manually
if [ -n "$GITHUB_REPO" ]; then
    log "Cloning GitHub repository: $GITHUB_REPO..."
    git clone "$GITHUB_REPO" . || { log "Error: Failed to clone repository"; exit 1; }
else
    log "No GitHub repo specified, creating directory structure manually..."
    mkdir -p control-node-setup remote-node-setup vars
    # Assume playbooks are copied manually later
fi

# Ensure directory structure exists
for dir in control-node-setup remote-node-setup vars; do
    [ -d "$dir" ] || { log "Error: Directory $dir missing"; exit 1; }
done
log "Directory structure created: $(ls -d */)"

# Instructions for next steps
log "Ansible control node initialized successfully!"
cat << EOF
Next steps:
1. Populate $ANSIBLE_DIR/vars/control_node_vars.yml with your sensitive data (e.g., Red Hat credentials).
2. Verify $ANSIBLE_DIR/inventory.yml or create it with 'localhost'.
3. Run the control node setup playbook:
   cd $ANSIBLE_DIR/control-node-setup
   ansible-playbook control_node_setup.yml -i ../inventory.yml
EOF
