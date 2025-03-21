#!/bin/bash
# Script to configure Ubuntu workstation worker with static IP and gather inventory details
# Run as root or with sudo

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root or with sudo"
    exit 1
fi

# Dynamically detect the first non-loopback interface
NETWORK_INTERFACE=$(ip link | grep -o '^[0-9]: [^:]*' | awk '{print $2}' | grep -v lo | head -n 1)
if [ -z "$NETWORK_INTERFACE" ]; then
    echo "Error: No non-loopback network interface found."
    exit 1
fi

# Gather current info
echo "Current Configuration:"
echo "Hostname: $(hostname -f)"
echo "IP: $(ip addr show dev $NETWORK_INTERFACE | grep -o 'inet [0-9.]*' | awk '{print $2}' | head -n 1)"
echo "OS: $(lsb_release -ds)"
echo "SSH User: $(whoami)"
echo "SSH Port: $(ss -tuln | grep :22 | awk '{print $5}' | cut -d: -f2 || echo '22')"

# Create backup directory if it doesn't exist
BACKUP_DIR="/etc/netplan.bak"
mkdir -p "$BACKUP_DIR"

# Backup existing Netplan configurations
if ls /etc/netplan/*.yaml >/dev/null 2>&1; then
    cp /etc/netplan/*.yaml "$BACKUP_DIR/"
    echo "Existing Netplan configurations backed up to $BACKUP_DIR"
else
    echo "No existing Netplan configurations found to backup"
fi

# Create or modify Netplan configuration file
NETPLAN_FILE="/etc/netplan/01-netcfg.yaml"

echo "Setting static IP to 192.168.10.134 on interface $NETWORK_INTERFACE..."
cat > $NETPLAN_FILE << EOL
network:
  version: 2
  ethernets:
    $NETWORK_INTERFACE:
      addresses:
        - 192.168.10.134/24
      gateway4: 192.168.10.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
EOL

# Apply Netplan configuration
netplan apply

# Wait for network changes to take effect
sleep 5

# Verify new IP
echo "New Configuration:"
echo "Hostname: $(hostname -f)"
echo "IP: $(ip addr show dev $NETWORK_INTERFACE | grep -o 'inet [0-9.]*' | awk '{print $2}' | head -n 1)"
echo "OS: $(lsb_release -ds)"
echo "SSH User: $(whoami)"
echo "SSH Port: $(ss -tuln | grep :22 | awk '{print $5}' | cut -d: -f2 || echo '22')"
echo "Static IP set to 192.168.10.134 completed."
