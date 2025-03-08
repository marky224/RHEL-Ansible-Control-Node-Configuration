#!/bin/bash
# Script to configure RHEL 9 workstation worker with static IP and gather inventory details
# Run as root or with sudo

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
echo "OS: $(cat /etc/redhat-release)"
echo "SSH User: $(whoami)"
echo "SSH Port: $(ss -tuln | grep :22 | awk '{print $5}' | cut -d: -f2 || echo '22')"

# Set static IP to 192.168.10.134
echo "Setting static IP to 192.168.10.134 on interface $NETWORK_INTERFACE..."
nmcli con mod "System $NETWORK_INTERFACE" ipv4.addresses 192.168.10.134/24
nmcli con mod "System $NETWORK_INTERFACE" ipv4.gateway 192.168.10.1
nmcli con mod "System $NETWORK_INTERFACE" ipv4.method manual
nmcli con mod "System $NETWORK_INTERFACE" ipv4.dns "8.8.8.8,8.8.4.4"
nmcli con up "System $NETWORK_INTERFACE"

# Verify new IP
echo "New Configuration:"
echo "Hostname: $(hostname -f)"
echo "IP: $(ip addr show dev $NETWORK_INTERFACE | grep -o 'inet [0-9.]*' | awk '{print $2}' | head -n 1)"
echo "OS: $(cat /etc/redhat-release)"
echo "SSH User: $(whoami)"
echo "SSH Port: $(ss -tuln | grep :22 | awk '{print $5}' | cut -d: -f2 || echo '22')"
echo "Static IP set to 192.168.10.134 completed."
