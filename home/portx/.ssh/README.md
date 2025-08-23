# SSH Directory

This directory contains SSH configuration and keys for PORTX environment.

## Purpose
- SSH key management for Git and remote server access
- Configuration files for SSH connections
- Integration with Windows OpenSSH service

## Files (not in git)
- `id_*` - SSH private keys (ignored by git)
- `id_*.pub` - SSH public keys (ignored by git)
- `*.pem`, `*.key` - Certificate files (ignored by git)
- `known_hosts*` - Host verification files (ignored by git)

## Usage
PORTX automatically syncs keys between this location and Windows `%USERPROFILE%\.ssh\` for system-wide SSH access.

See `scripts/ssh-agent.sh` for SSH agent management.