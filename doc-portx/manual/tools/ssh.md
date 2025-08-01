# ssh - Secure Shell Remote Access

[🏠 Back to Wiki Home](../index.md) | [🌐 Network Tools](../categories/network.md)

---

## Overview

Secure protocol for remote login and command execution over encrypted connections.

**Location**: `usr/bin/ssh.exe`  
**Category**: Network Tools

---

## Basic Usage

```bash
# Connect to remote server
ssh user@hostname

# Connect on specific port
ssh -p 2222 user@hostname

# Execute single command
ssh user@hostname 'ls -la /var/log'
```

---

## Key Management

```bash
# Generate SSH key pair
ssh-keygen -t ed25519 -C "your-email@example.com"

# Copy public key to server
ssh-copy-id user@hostname

# Add key to SSH agent
ssh-add ~/.ssh/id_ed25519
```

---

## Port Forwarding

```bash
# Local port forward (access remote service locally)
ssh -L 8080:localhost:80 user@hostname

# Remote port forward (expose local service remotely)
ssh -R 8080:localhost:3000 user@hostname

# Dynamic port forward (SOCKS proxy)
ssh -D 1080 user@hostname
```

---

## Common Options

- **-p PORT** - Connect to specific port
- **-i keyfile** - Use specific private key
- **-L port:host:port** - Local port forwarding
- **-R port:host:port** - Remote port forwarding
- **-D port** - Dynamic port forwarding
- **-X** - Enable X11 forwarding
- **-v** - Verbose output

---

## Configuration

Edit `~/.ssh/config`:

```
Host myserver
    HostName server.example.com
    User myuser
    Port 2222
    IdentityFile ~/.ssh/myserver_key
    
Host *.internal
    ProxyJump gateway.example.com
```