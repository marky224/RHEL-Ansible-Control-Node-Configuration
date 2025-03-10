# RHEL 9 Ansible Control Node Setup

This repository provides Bash scripts and Ansible playbooks to automate the provisioning of a Red Hat Enterprise Linux (RHEL) 9 server as an Ansible control node. The setup includes:

- Installing Ansible prerequisites.
- Initializing configuration playbooks and inventory.
- Prompting for Red Hat subscription details.
- Automatically integrating the generated private RSA key into `vars/control_node_vars.yml`.

### Directory Details
- **`control-node-setup/`**: Scripts and sensitive vars for initializing and configuring the Ansible control node.
  - `main.sh`: Orchestrates the setup by running `01-initialize_ansible_control_node.sh` and `02-configure_ansible_control_node.sh`.
- **`inventory/`**: Contains the inventory file, starting with `localhost`, to be updated with managed nodes later.
- **`managed-node-setup/`**: Sensitive vars for managed nodes (playbook is in `playbooks/`).
- **`playbooks/`**: Ansible playbooks for control and managed node configurations.

## Prerequisites

- A freshly provisioned RHEL 9 server.
- Root access to the server.
- An active Red Hat subscription.

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

### 1. Clone the Repository

```bash
git clone https://github.com/marky224/RHEL-Ansible-Node-Configurations.git /root/ansible_project
cd /root/ansible_project/control-node-setup-ansible
```

### 2. Run the Main Setup Script

- Run `main.sh` to initialize and configure the control node in one step:
```bash
chmod +x control-node-setup/main.sh
./control-node-setup/main.sh
``` 
- Prompts: Enter your Red Hat subscription username and password when prompted by 02-configure_ansible_control_node.sh.
- SSH Key: An RSA key pair will be generated automatically if not present.

### 3. Verify the Setup

- **Check logs**: `cat /var/log/ansible_main.log` (or `/var/log/ansible_config.log` for details).
- **Verify Ansible**: `ansible --version`
- **Test network**: `ip addr`
- **Check SSH**: `systemctl status sshd`

### 4. Configure Managed Nodes (Optional)

- Update `inventory/inventory.yml` with managed node IPs.
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
