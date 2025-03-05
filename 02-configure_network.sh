#!/bin/bash
# configure_network.sh
# Configures network settings for the Ansible control node

source ./setup_logging.sh

CONTROL_NODE_IP="192.168.0.100"
GATEWAY_IP="192.168.0.1"
TIMEOUT=30

# Dynamically detect active interface
log "Detecting active network interface..."
INTERFACE=$(ip link | grep -E '^[0-9]+: ' | grep -v 'lo:' | grep 'state UP' | awk -F: '{print $2}' | tr -d ' ' | head -n 1)
if [ -z "$INTERFACE" ]; then
    log "Warning: No active UP interface found. Using first available..."
    INTERFACE=$(ip link | grep -E '^[0-9]+: ' | grep -v 'lo:' | awk -F: '{print $2}' | tr -d ' ' | head -n 1)
    if [ -z "$INTERFACE" ]; then
        log "Error: No network interface found"
        exit 1
    fi
fi
log "Using interface: $INTERFACE"

# Detect NetworkManager connection name
CONNECTION_NAME=$(nmcli con show --active | grep "$INTERFACE" | awk '{print $1}' | head -n 1)
if [ -z "$CONNECTION_NAME" ]; then
    log "Warning: No active connection found. Using first match..."
    CONNECTION_NAME=$(nmcli con show | grep "$INTERFACE" | awk '{print $1}' | head -n 1)
    if [ -z "$CONNECTION_NAME" ]; then
        log "Error: No NetworkManager connection found for $INTERFACE"
        exit 1
    fi
fi
log "Using connection name: $CONNECTION_NAME"

# Set static IP idempotently
log "Configuring static IP $CONTROL_NODE_IP on $INTERFACE..."
CURRENT_IP=$(nmcli con show "$CONNECTION_NAME" | grep 'ipv4.addresses' | awk '{print $2}' | cut -d'/' -f1)
if [ "$CURRENT_IP" != "$CONTROL_NODE_IP" ]; then
    nmcli con mod "$CONNECTION_NAME" ipv4.addresses "$CONTROL_NODE_IP/24" \
        ipv4.gateway "$GATEWAY_IP" ipv4.dns "8.8.8.8 8.8.4.4" ipv4.method manual || {
        log "Error: Failed to set IP address"
        exit 1
    }
    nmcli con up "$CONNECTION_NAME" || {
        log "Error: Failed to apply network settings"
        exit 1
    }
    log "Static IP set to $CONTROL_NODE_IP"
else
    log "Static IP already set to $CONTROL_NODE_IP"
fi
