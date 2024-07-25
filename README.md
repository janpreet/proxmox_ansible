# Proxmox Cluster Setup with Ansible and OPA

This repository contains an Ansible playbook for setting up a Proxmox cluster, along with an Open Policy Agent (OPA) Rego policy for validating the playbook.

## Contents

- `cluster.yaml`: Ansible playbook for Proxmox cluster setup
- `proxmox_policy.rego`: OPA Rego policy for playbook validation
- `inventory.ini`: Sample inventory file (not provided, see example below)

## Playbook Overview

The `cluster.yaml` playbook automates the process of setting up a Proxmox cluster. It performs the following main tasks:

1. Determines the first node and cluster size
2. Creates the cluster on the first node
3. Adds subsequent nodes to the cluster
4. Sets up QDevice for two-node clusters
5. Verifies cluster status

## Prerequisites

- Ansible installed on your control node
- OPA (Open Policy Agent) installed for policy validation
- Proxmox nodes with SSH access

## Usage

1. Update the `inventory.ini` file with your Proxmox node information:

   ```ini
   [proxmox]
   1.2.3.4
   1.2.3.5

   [all:vars]
   ansible_user=your_ssh_user
   ansible_python_interpreter=/usr/bin/python3

## Run the playbook:
```bash
ansible-playbook -i inventory.ini cluster.yaml
```

## Validate the playbook against the OPA policy:
```bash
opa eval --data proxmox.rego --input cluster.yaml "data.proxmox"
```


## OPA Policy
The proxmox.rego file contains rules to validate the playbook against best practices and security considerations. It checks for:

* Valid hosts
* Allowed tasks
* Proper use of become: yes
* Correct usage of pvecm commands
* Reasonable timeouts
* Proper setup for two-node clusters

To modify policy rules, edit the proxmox.rego file.

## Customization

* Adjust the qdevice_ip variable in the playbook for your QDevice setup
* Modify the playbook tasks as needed for your specific Proxmox environment