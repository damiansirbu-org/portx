# SSH Keys Directory

This directory is where SSH keys should be placed for PORTX to use them.

## Required Files (to be added by user):

- `id_ed25519` - Private SSH key
- `id_ed25519.pub` - Public SSH key  
- `known_hosts` - Known SSH hosts (auto-generated)
- `agent.env` - SSH agent environment (auto-generated)

## Security Notice:

⚠️ **SSH keys are NOT included in this repository for security reasons.**

After setting up PORTX, you need to:

1. **Generate SSH keys** (if you don't have them):
   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

2. **Copy your existing SSH keys** to this directory

3. **Add public key to GitHub/GitLab** etc.

4. **Set proper permissions**:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/id_ed25519
   chmod 644 ~/.ssh/id_ed25519.pub
   ```

## Auto-generated Files:

The following files will be created automatically when you use SSH:
- `known_hosts` - Trusted host fingerprints
- `agent.env` - SSH agent process information

---

**Note**: This README exists to remind users that SSH keys need to be manually added to this directory for SSH functionality to work properly.