# Ansible Controller Setup Guide

This document describes how to set up a standardized Ansible controller environment for running playbooks from this repository.

> **Why standardize?** Different Ansible, Python, and Jinja2 versions across controllers have historically caused inconsistent playbook behavior, hard-to-diagnose failures, and wasted debugging time. Following this guide ensures every controller produces identical results.

## Why virtualenv?

The default Python version shipped by the OS varies across distributions and releases (e.g. RHEL 9 ships Python 3.9, while other distros may ship 3.12). Relying on the system Python means:

- OS upgrades can silently change your Ansible runtime.
- Different controllers end up with different dependency versions.
- System-level `pip install` can conflict with OS-managed packages.

A **virtualenv** isolates the exact Python interpreter and package versions we need. Everyone who activates the same venv with the same `pip-requirements.txt` gets bit-for-bit identical behavior — regardless of what the underlying OS ships.

## Standardized Versions

| Component      | Version    | End of Life  |
|----------------|------------|--------------|
| Ansible core   | **2.19.x** | November 2026 |
| Python         | **3.11.x** | October 2027 |
| Jinja2         | **3.1.x**  | —            |

## Supported Controller Operating Systems

- AlmaLinux 9 / RHEL 9 (recommended)
- macOS (for local development)

## Prerequisites

- SSH access (preferably key-based) to all managed nodes
- Passwordless sudo on managed nodes for the provisioning user
- Ansible code copied to the controller

## `ansible-core` vs `ansible` (full package)

Our `pip-requirements.txt` installs **`ansible-core`**, not the full `ansible` package. The difference:

| Package | What it includes |
|---------|-----------------|
| `ansible-core` | Ansible engine only — no bundled collections |
| `ansible` | `ansible-core` + ~85 community collections bundled |

We use `ansible-core` and explicitly install only the collections we need via `requirements.yml`. This is lighter, gives us version control over each collection, and avoids pulling in unused collections.

## Step 1 — Install Python 3.11

First, check if Python 3.11 is already installed:

```bash
python3.11 --version
```

If you see `Python 3.11.x` in the output, **skip this step** and proceed to [Step 2](#step-2--create-the-virtualenv).

### AlmaLinux 9 / RHEL 9

```bash
sudo dnf install -y python3.11 python3.11-pip python3.11-devel
```

> **No sudo access?** The `dnf install` command above requires root privileges. If you do not have sudo access on the controller, contact your infra team to install `python3.11`, `python3.11-pip`, and `python3.11-devel`.

### macOS

```bash
brew install python@3.11
```

## Step 2 — Create the Virtualenv

We recommend placing the virtualenv **inside the repo checkout** so it lives alongside the playbooks. The `.gitignore` already excludes common venv directory names.

```bash
cd ~/connections-automation
python3.11 -m venv venv
```

This creates a `venv/` directory containing a dedicated Python 3.11 interpreter and an isolated `site-packages`.

### Activate the virtualenv

```bash
source venv/bin/activate
```

Your shell prompt will change (e.g. `(venv) [ansible@controller ~]$`). **You must activate the venv every time you open a new shell** before running any Ansible commands.

## Step 3 — Install Ansible and Python Dependencies

With the virtualenv activated:

```bash
pip install --upgrade pip
pip install -r pip-requirements.txt
```

See [pip-requirements.txt](../pip-requirements.txt) for the full list and version constraints.

## Step 4 — Install Ansible Galaxy Collections

```bash
ansible-galaxy collection install -r requirements.yml
```

See [requirements.yml](../requirements.yml) for version constraints.

## [OPTIONAL] Step 5 — Configure SSH

Create or update `~/.ssh/config`:

```
Host *
    User <your-provisioning-user>
    ForwardAgent yes
    StrictHostKeyChecking no
    UserKnownHostsFile /dev/null
    IgnoreUnknown AddKeysToAgent,UseKeychain
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_rsa
```

Generate a key pair if you don't already have one:

```bash
ssh-keygen -t rsa -b 4096
```

Copy your public key to all managed nodes:

```bash
ssh-copy-id <user>@<managed-node>
```

For more detailed SSH setup instructions, see [QUICKSTART.md](QUICKSTART.md#setting-up-the-user).

## Step 6 — Verify Installation

Activate the venv and run:

```bash
source venv/bin/activate
ansible --version
```

Expected output (minor patch version may differ):

```
ansible [core 2.19.x]
  config file = /path/to/connections-automation/ansible.cfg
  ansible python module location = /path/to/connections-automation/venv/lib/python3.11/site-packages/ansible
  python version = 3.11.x
  jinja version = 3.1.x
  pyyaml version = 6.0.x
```

Also verify key Python packages:

```bash
python -c "import boto3; print('boto3', boto3.__version__)"
python -c "import kubernetes; print('kubernetes', kubernetes.__version__)"
```

## Troubleshooting

### Recreating the virtualenv
If the venv becomes corrupted or you want a clean start:

```bash
deactivate              # if currently activated
rm -rf venv
python3.11 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r pip-requirements.txt
ansible-galaxy collection install -r requirements.yml
```
