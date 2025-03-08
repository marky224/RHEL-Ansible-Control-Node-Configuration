markdown

# Remote Scripts - RHEL Ansible + Kubernetes Infrastructure for IT Support

## Overview
The `remote_scripts/` directory contains scripts to configure remote PCs for management by the **Red Hat Enterprise Linux (RHEL) 9** Ansible control node at `192.168.10.100`. These scripts establish SSH (Linux) or WinRM (Windows) connectivity, automate SSH key exchange for Linux, and provide robust error handling with logging. The primary focus is the RHEL 9 workstation at `192.168.10.134`, with a production-ready configuration for Windows 11 Pro at `192.168.10.135`, and templates for Ubuntu and Fedora CoreOS for potential future use.

---

### Files

- **`rhel9_connect.sh`**: Configures the RHEL 9 workstation at `192.168.10.134` for SSH-based Ansible management.
- **`windows_connect.ps1`**: Configures Windows 11 Pro at `192.168.10.135` for WinRM-based Ansible management over HTTPS with interactive credential prompts.
- **`ubuntu_connect.sh`**: Template to configure Ubuntu for SSH-based Ansible management.
- **`fedora_connect.sh`**: Template to configure Fedora CoreOS for SSH-based Ansible management.

---

### Purpose
These scripts:
- Install prerequisites (e.g., `openssh-server`, `curl` for Linux).
- Configure connectivity (SSH for Linux, WinRM over HTTPS for Windows) with firewall rules.
- Automate SSH key exchange for Linux by fetching the control node’s public key from `https://192.168.10.100:8080/ssh_key`.
- Log actions and errors to `/var/log/ansible_connect.log` (Linux) or `C:\ansible_connect.log` (Windows).
- Send a check-in to `https://192.168.10.100:8080/checkin` with hostname, IP, and OS details, including retry logic.

---

### Prerequisites
- **Control Node**: RHEL 9 server at `192.168.10.100` with:
  - `scripts/checkin_listener.py` running with HTTPS (`python3 scripts/checkin_listener.py &`).
  - `scripts/ssh_key_server.py` running with HTTPS (`python3 scripts/ssh_key_server.py &`).
- **Network**: Remote PCs on the `192.168.10.0/24` subnet (e.g., VMware Workstation NAT or Bridged network) with internet access.
- **Permissions**: Root privileges on Linux (e.g., `root` on RHEL 9 workstation); Administrator privileges on Windows.
- **Red Hat Subscription**: Required for RHEL 9 package updates on the workstation.

---

### Usage Instructions

#### General Steps
1. **Download**: Fetch scripts from GitHub using `curl` (Linux) or `Invoke-WebRequest` (Windows).
2. **Make Executable** (Linux): `chmod +x <script_name>`.
3. **Run**: Execute with `sudo` (Linux) or as Administrator (Windows).
4. **Check Logs**: Review `/var/log/ansible_connect.log` (Linux) or `C:\ansible_connect.log` (Windows) for setup details.

#### Specific Instructions

1. **`rhel9_connect.sh`**
   - **Target**: RHEL 9 workstation at `192.168.10.134`.
   - **Command**:
     ```bash
     curl -O https://raw.githubusercontent.com/marky224/rhel-ansible-k8s-it-support/main/remote_scripts/rhel9_connect.sh
     chmod +x rhel9_connect.sh
     sudo ./rhel9_connect.sh
     ```
   - **Notes**: Validates the static IP `192.168.10.134` and requires a Red Hat subscription for updates. Fetches the control node’s SSH key over HTTPS.

2. **`windows_connect.ps1`**
   - **Target**: Windows 11 Pro at `192.168.10.135`.
   - **Command**:
     ```powershell
     Invoke-WebRequest -Uri "https://raw.githubusercontent.com/marky224/rhel-ansible-k8s-it-support/main/remote_scripts/windows_connect.ps1" -OutFile "windows_connect.ps1"
     .\windows_connect.ps1 -ControlNodeIP "192.168.10.100"
     ```
   - **Notes**: Sets static IP `192.168.10.135` and prompts interactively for username and password (e.g., "Enter Windows admin username"). Configures WinRM over HTTPS with a self-signed certificate for production security. Uses HTTPS for check-in with a self-signed certificate (testing mode).

3. **`ubuntu_connect.sh`**
   - **Target**: Ubuntu (template; adjust IP if used).
   - **Command**:
     ```bash
     curl -O https://raw.githubusercontent.com/marky224/rhel-ansible-k8s-it-support/main/remote_scripts/ubuntu_connect.sh
     chmod +x ubuntu_connect.sh
     sudo ./ubuntu_connect.sh
     ```
   - **Notes**: Not currently active; intended for future Ubuntu PCs. Assumes a default Ubuntu user; adjust `$USER` if different.

4. **`fedora_connect.sh`**
   - **Target**: Fedora CoreOS (template; adjust IP if used).
   - **Command**:
     ```bash
     curl -O https://raw.githubusercontent.com/marky224/rhel-ansible-k8s-it-support/main/remote_scripts/fedora_connect.sh
     chmod +x fedora_connect.sh
     sudo ./fedora_connect.sh
     ```
   - **Notes**: Not currently active; assumes SSH via Ignition. May require a reboot if `curl` is installed.

---

### Enhancements

#### Automated SSH Key Exchange
- **How**: The `rhel9_connect.sh` script fetches the control node’s public key from `https://192.168.10.100:8080/ssh_key` and adds it to `/root/.ssh/authorized_keys`.
- **Setup**: Ensure `scripts/ssh_key_server.py` runs with HTTPS on the control node.

#### Improved Error Handling and Logging
- **Error Handling**: Validates IPs, exits on critical failures with specific messages, and retries check-ins 3 times with 5-second delays.
- **Logging**: Records actions and errors with timestamps to `/var/log/ansible_connect.log` (Linux) or `C:\ansible_connect.log` (Windows).
- **Windows Security**: `windows_connect.ps1` uses interactive prompts for credentials, configures WinRM over HTTPS with a self-signed certificate, and dynamically detects the network interface for production reliability.

---

### Post-Execution

- **Verify**: Check `logs/checkin.log` on the control node at `192.168.10.100` for entries like:
  ```plaintext
  2025-02-24 10:00:00 - Check-in received: hostname=rhel9-workstation&ip=192.168.10.134&os=rhel9
  2025-02-24 10:00:05 - Check-in received: hostname=WIN11-PC&ip=192.168.10.135&os=windows11
  ```
- **Test Connectivity**: From the control node:
  ```bash
  ansible all -m ping -i ansible/inventory/inventory.yml  # For Linux
  ansible windows_pc -m win_ping -i ansible/inventory/inventory.yml  # For Windows
  ```
- **Troubleshooting**: Review logs on the remote PC for detailed errors:
  ```plaintext:
  /var/log/ansible_connect.log  # For Linux
  C:\ansible_connect.log  # For Windows
  ```
