# RHEL 9 Ansible Control Node Setup

This repository provides Bash scripts and Ansible playbooks to automate the provisioning of a Red Hat Enterprise Linux (RHEL) 9 server as an Ansible control node. The setup includes:

- Installing Ansible prerequisites.
- Initializing configuration playbooks and inventory.
- Prompting for Red Hat subscription details.
- Automatically integrating the generated private RSA key into `vars/control_node_vars.yml`.

## Prerequisites

- A freshly provisioned RHEL 9 server.
- Root access to the server.
- An active Red Hat subscription.

## Setup Overview

The setup process is divided into two main scripts:

1. **01-initialize_ansible_control_node.sh**: Prepares the server by installing necessary packages and setting up the Ansible environment.
2. **02-configure_ansible_control_node.sh**: Configures the Ansible control node by collecting user inputs and running the initial playbook.

## File Structure

```
RHEL-Ansible-Node-Configurations/
└── control-node-setup-ansible/
    ├── control-node-setup/
    │   ├── vars/
    │   │   └── control_node_vars.yml       # Templated sensitive vars for control node
    │   ├── 01-initialize_ansible_control_node.sh  # Initialization script
    │   ├── 02-configure_ansible_control_node.sh   # Configuration script
    │   └── main.sh                         # # Runs 01- and 02- scripts in sequence
    ├── inventory/
    │   └── inventory.yml                   # Initial inventory with localhost
    ├── managed-node-setup/
    │   ├── vars/
    │   │   └── remote_node_vars.yml        # Templated sensitive vars for managed nodes
    ├── playbooks/
    │   ├── control_node_setup.yml          # Playbook for control node
    │   └── managed_node_setup.yml          # Playbook for managed nodes (previously remote_node_setup.yml)
    ├── readme.md                           # Documentation
    └── site.yml                            # Master playbook (assumed from previous mention)
```

## Detailed Steps

### 1. Initialize the Ansible Control Node

**Script**: `01-initialize_ansible_control_node.sh`

**Purpose**: Sets up the server with essential packages and prepares the Ansible environment.

**Actions**:

- Updates system packages.
- Installs prerequisites: `python3`, `pip`, and `git`.
- Installs Ansible using `pip`.
- Configures the environment to include Ansible in the system PATH.
- Sets up the Ansible project directory.
- Clones the specified GitHub repository or creates the necessary directory structure.

**Usage**:

```bash
sudo bash 01-initialize_ansible_control_node.sh
```
**Note**: Ensure the script is executed with root privileges.

### 2. Configure the Ansible Control Node

**Script**: '02-configure_ansible_control_node.sh'

**Purpose**: Finalizes the configuration by collecting Red Hat subscription details and setting up the Ansible inventory and playbooks.

**Actions**:

- Prompts the user for Red Hat subscription username and password.
- Generates an SSH RSA key pair if not already present.
- Populates vars/control_node_vars.yml with the provided subscription details and the SSH private key.
- Verifies or creates inventory.yml with the localhost configuration.
- Executes the control node setup playbook.

**Usage**:

```bash
sudo bash 02-configure_ansible_control_node.sh
```
**Note**: Ensure the script is executed with root privileges.

### 3. Configure Managed Nodes (Optional)

- Update inventory/inventory.yml with managed node IPs.
- Run the managed node playbook:
```bash
cd playbooks
ansible-playbook managed_node_setup.yml -i ../inventory/inventory.yml
```

## Post-Setup Instructions

After completing the setup:
1. Verify Configuration: Ensure that vars/control_node_vars.yml contains accurate subscription details and the correct SSH private key.
2. Update Inventory: Add managed nodes to inventory.yml as needed.
3. Run Playbooks: Navigate to the appropriate directory and execute Ansible playbooks. For example:

```bash
cd /root/ansible_project/remote-node-setup
ansible-playbook remote_node_setup.yml -i ../inventory.yml
```
## Logging
Logs for each script execution are stored in:
- Initialization log: /var/log/ansible_init.log
- Configuration log: /var/log/ansible_config.log
Review these logs to troubleshoot any issues during the setup process.

## Security Considerations
- Ensure that vars/control_node_vars.yml has appropriate permissions to protect sensitive information:

```bash
chmod 600 /root/ansible_project/vars/control_node_vars.yml
```
- Regularly rotate SSH keys and update the inventory to maintain security.
