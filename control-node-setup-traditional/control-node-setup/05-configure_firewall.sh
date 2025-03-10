#!/bin/bash
# 05-configure_firewall.sh
# Configures firewall rules on the RHEL 9 control node

source ./setup_logging.sh

# Configure firewall
log "Configuring firewall for SSH..."
if ! firewall-cmd --list-services | grep -q ssh; then
    firewall-cmd --permanent --add-service=ssh || {
        log "Error: Failed to add SSH to firewall"
        exit 1
    }
    firewall-cmd --reload || {
        log "Error: Failed to reload firewall"
        exit 1
    }
    log "Firewall configured for SSH"
else
    log "Firewall already configured for SSH"
fi
