# ansible-nodes

This subfolder contains scripts for setting up remote nodes (Linux and Windows) on the network to be managed by an Ansible control node running on Red Hat Enterprise Linux (RHEL). The purpose is to prepare these remote nodes for Ansible management by enabling passwordless SSH (for Linux) or WinRM (for Windows) connectivity, ensuring the control node can initiate and maintain an Ansible connection.

## Prerequisites

Before using the scripts in this subfolder, ensure the following:

- The Ansible control node is configured (see the main repository's `README.md` for setup instructions).
- Remote nodes are accessible over the network from the control node.
- For Linux nodes:
  - SSH server (`sshd`) is installed and running.
  - Python 3 is installed (required for Ansible module execution).
- For Windows nodes:
  - PowerShell 5.1 or later is installed.
  - WinRM (Windows Remote Management) is enabled and configured.

## Structure

- **`linux_nodes.sh`**: Bash script to configure Linux-based remote nodes for Ansible management.
- **`windows_nodes.ps1`**: PowerShell script to configure Windows-based remote nodes for Ansible management.

## Setup Instructions

### 1. Linux Remote Nodes Configuration (`linux_nodes.sh`)

This script configures Linux remote nodes by:
- Creating an Ansible user with sudo privileges.
- Setting up passwordless SSH authentication from the control node.
- Ensuring Python is installed for Ansible compatibility.

#### Usage
1. Copy `linux_nodes.sh` to the control node or run it from the repository directory.
2. Edit the script to specify the target Linux node IP addresses or hostnames and the Ansible user's credentials.
3. Execute the script:
   ```bash
   chmod +x linux_nodes.sh
   ./linux_nodes.sh
   ```
4. Verify connectivity from the control node:
    ```bash
    ansible linux_nodes -m ping
    ```

### 2. Windows Remote Nodes Configuration (windows_nodes.ps1)

This script configures Windows remote nodes by:
- Enabling WinRM for remote management.
- Configuring basic authentication and allowing unencrypted traffic (if needed for testing; adjust for production security).
- Creating a local Ansible user account (optional).

#### Usage
1. Copy windows_nodes.ps1 to the target Windows node or execute it remotely via PowerShell Remoting.
2. Run the script with elevated privileges (as Administrator):
   ```powershell
   Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
   .\windows_nodes.ps1
    ```
3. Verify connectivity from the control node:
   ```bash
   ansible windows_nodes -m win_ping
   ```

## Testing Connectivity
After running the scripts:
1. Test Linux nodes:
   ```bash
   ansible linux_nodes -m ping
   ```
2. Test Windows nodes:
   ```bash
   ansible windows_nodes -m win_ping
   ```
Successful responses ("pong" for Linux, "SUCCESS" for Windows) indicate the nodes are ready for Ansible management.

## Notes

- Ensure firewall rules allow SSH (port 22) for Linux and WinRM (ports 5985/5986) for Windows.
- For production environments, enhance security by using encrypted WinRM (HTTPS) and SSH key hardening.
- Scripts assume basic network connectivity; adjust for specific network configurations (e.g., proxies, VPNs).

## License
This project is licensed under the MIT License - see the LICENSE file in the main repository for details.


