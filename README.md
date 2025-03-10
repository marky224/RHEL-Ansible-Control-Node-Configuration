# RHEL Ansible Control Node Setup

## Overview
This repository automates provisioning of a **Red Hat Enterprise Linux (RHEL) 9** virtual machine as an Ansible control node at `192.168.0.100`. It’s part of a larger **Virtual Network Project**, managing remote PCs (Linux and Windows) via Ansible for IT support tasks like monitoring and administration.

## Features
- **Ansible Control Node**: Configures RHEL 9 to manage remote nodes via SSH (Linux) and WinRM (Windows).
- **Modular Scripts**: Numbered scripts for logging, network, Ansible install, SSH, and firewall setup.
- **Remote PC Support**: Framework for RHEL 9 and Windows 11 Pro nodes.

## Process for Provisioning a Linux RHEL Server as an Ansible Control Node
Provisioning a Linux server as an Ansible control node typically involves these steps:

1. **Configure Networking**:
   - Assign a static IP address (e.g., `192.168.0.100`) within the network.
   - Set the gateway and DNS servers to ensure connectivity.
2. **Install Base Dependencies**:
   - Update the system and install essential tools (e.g., `python3`, `curl`, `openssl`).
3. **Install Ansible**:
   - Install Ansible, either via package manager (e.g., `dnf`) or Python’s `pip`, ensuring compatibility with the Linux distribution.
   - Include additional modules (e.g., `pywinrm` for Windows support) as needed.
4. **Set Up SSH**:
   - Generate an SSH key pair for secure, passwordless access to remote nodes.
   - Configure the SSH daemon (`sshd`) to disable password authentication and use keys.
5. **Configure Firewall**:
   - Open necessary ports (e.g., 22 for SSH) to allow communication with remote nodes.
6. **Prepare for Remote Management**:
   - Create an inventory file (e.g., `inventory.yml`) listing remote nodes.
   - Test connectivity with a simple Ansible command (e.g., `ansible all -m ping`).

This process ensures the server can manage remote systems effectively, leveraging Ansible’s automation capabilities.

## Prerequisites
- **Control Node**:
  - RHEL 9 VM in VMware Workstation (4GB+ RAM, 4+ CPU Cores, 50GB+ disk).
  - Red Hat subscription for RHEL repositories.
  - Subnet: `192.168.0.0/24`, Gateway: `192.168.0.1`.
