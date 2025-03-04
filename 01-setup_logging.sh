#!/bin/bash
# 01-setup_logging.sh
# Sets up logging for the Ansible control node setup

LOG_FILE="${LOG_FILE:-/var/log/ansible_control_setup.log}"

# Function to log messages with timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Rotate logs if larger than 10MB
rotate_logs() {
    if [ -f "$LOG_FILE" ] && [ $(stat -c%s "$LOG_FILE") -gt 10485760 ]; then
        mv "$LOG_FILE" "${LOG_FILE}.$(date '+%Y%m%d%H%M%S')"
        touch "$LOG_FILE" && chmod 644 "$LOG_FILE"
        log "Log file rotated due to size exceeding 10MB."
    fi
}

# Setup logging
touch "$LOG_FILE" 2>/dev/null || { log "Error: Cannot create log file at $LOG_FILE"; exit 1; }
chmod 644 "$LOG_FILE"
rotate_logs
log "Logging initialized"
