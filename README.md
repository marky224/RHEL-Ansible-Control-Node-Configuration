# RHEL Ansible Control Node Setup

## Overview
This repository automates provisioning of a **Red Hat Enterprise Linux (RHEL) 9** virtual machine as an Ansible control node at `192.168.10.100`. It’s part of a larger **Virtual Network Project**, managing remote PCs (Linux and Windows) via Ansible for IT support tasks like monitoring and administration.

## Features
- **Ansible Control Node**: Configures RHEL 9 to manage remote nodes via SSH (Linux) and WinRM (Windows).
- **Modular Scripts**: Numbered scripts for logging, network, Ansible install, SSH, and firewall setup.
- **Remote PC Support**: Framework for RHEL 9 and Windows 11 Pro nodes.

## Prerequisites
- **Control Node**:
  - RHEL 9 VM in VMware Workstation (4GB+ RAM, 4+ CPU Cores, 50GB+ disk).
  - Red Hat subscription for RHEL repositories.
  - Subnet: `192.168.10.0/24`, Gateway: `192.168.10.1`.

## Setup Instructions

### Deploy Control Node
1. **Download Scripts**:
   ```bash
   cd /root
   curl -O https://raw.githubusercontent.com/marky224/RHEL-Ansible-Control-Node/main/deploy/main.sh
   curl -O https://raw.githubusercontent.com/marky224/RHEL-Ansible-Control-Node/main/deploy/01-setup_logging.sh
   curl -O https://raw.githubusercontent.com/marky224/RHEL-Ansible-Control-Node/main/deploy/02-configure_network.sh
   curl -O https://raw.githubusercontent.com/marky224/RHEL-Ansible-Control-Node/main/deploy/03-install_ansible.sh
   curl -O https://raw.githubusercontent.com/marky224/RHEL-Ansible-Control-Node/main/deploy/04-configure_ssh.sh
   curl -O https://raw.githubusercontent.com/marky224/RHEL-Ansible-Control-Node/main/deploy/05-configure_firewall.sh
   sudo chmod +x *.sh 01-*.sh
   ```

2. **Run Main Script**:
   ```bash
   sudo ./main.sh
   ```
## Verify Setup
-  **Control Node**:
