# GPG Package Manual

## Package Information
- **Package Name**: gpg
- **Category**: Security
- **Type**: Cryptographic Suite
- **License**: GPL v3+

## Description
GNU Privacy Guard implementation for Windows providing complete cryptographic functionality.

Full-featured cryptographic suite for encryption, digital signatures, and key management.
Essential for secure communications, code signing, and data protection workflows.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| gpg.exe | Main GPG command-line interface | Encrypt, decrypt, sign, and verify data |
| gpg-agent.exe | Private key management daemon | Handle private key operations securely |
| gpg-connect-agent.exe | Agent communication tool | Interact with gpg-agent directly |
| gpgconf.exe | Configuration management | Manage GPG configuration settings |
| dirmngr.exe | Directory manager for certificates | Handle certificate and key retrieval |

## Common Usage Examples

### Key Management
```bash
# Generate new key pair
gpg --full-generate-key

# Generate key with specific parameters
gpg --generate-key

# List public keys
gpg --list-keys

# List private keys
gpg --list-secret-keys

# Export public key
gpg --export --armor user@example.com > public.key

# Export private key (backup)
gpg --export-secret-keys --armor user@example.com > private.key
```

### Key Import and Distribution
```bash
# Import public key
gpg --import public.key

# Import from keyserver
gpg --recv-keys KEYID

# Send key to keyserver
gpg --send-keys KEYID

# Search keyserver
gpg --search-keys user@example.com

# Refresh keys from keyserver
gpg --refresh-keys
```

### File Encryption and Decryption
```bash
# Encrypt file for recipient
gpg --encrypt --recipient user@example.com document.txt

# Encrypt with armor (ASCII output)
gpg --armor --encrypt --recipient user@example.com document.txt

# Encrypt for multiple recipients
gpg --encrypt -r user1@example.com -r user2@example.com document.txt

# Decrypt file
gpg --decrypt document.txt.gpg > document.txt

# Decrypt to stdout
gpg --decrypt document.txt.gpg
```

### Digital Signatures
```bash
# Sign file (detached signature)
gpg --detach-sign document.txt

# Sign with armor
gpg --armor --detach-sign document.txt

# Sign and encrypt
gpg --sign --encrypt --recipient user@example.com document.txt

# Verify signature
gpg --verify document.txt.sig document.txt

# Verify detached signature
gpg --verify document.txt.asc
```

### Symmetric Encryption
```bash
# Encrypt with passphrase
gpg --symmetric document.txt

# Encrypt with specific cipher
gpg --cipher-algo AES256 --symmetric document.txt

# Decrypt symmetric file
gpg --decrypt document.txt.gpg
```

### Key Trust and Validation
```bash
# Edit key trust
gpg --edit-key user@example.com
# In interactive mode: trust, then select trust level

# Sign someone's key
gpg --sign-key user@example.com

# Check key fingerprint
gpg --fingerprint user@example.com

# Verify key signatures
gpg --check-sigs user@example.com
```

### Advanced Operations
```bash
# Generate revocation certificate
gpg --gen-revoke user@example.com > revoke.asc

# Revoke key
gpg --import revoke.asc

# Delete public key
gpg --delete-key user@example.com

# Delete private key
gpg --delete-secret-key user@example.com

# Change passphrase
gpg --passwd user@example.com
```

### Batch Operations
```bash
# Batch key generation
gpg --batch --generate-key key-params.txt

# Example key-params.txt:
Key-Type: RSA
Key-Length: 4096
Subkey-Type: RSA
Subkey-Length: 4096
Name-Real: John Doe
Name-Email: john@example.com
Expire-Date: 0
Passphrase: your-passphrase
%commit
```

### Git Integration
```bash
# Configure Git to use GPG
git config --global user.signingkey KEYID
git config --global commit.gpgsign true

# Sign commit
git commit -S -m "Signed commit"

# Verify commit signatures
git log --show-signature

# Sign tag
git tag -s v1.0.0 -m "Signed tag"
```

### Agent Management
```bash
# Start gpg-agent
gpg-connect-agent /bye

# Check agent status
gpg-connect-agent 'getinfo pid' /bye

# Reload agent configuration
gpg-connect-agent reloadagent /bye

# Kill agent
gpg-connect-agent killagent /bye
```

### Configuration Management
```bash
# List configuration options
gpgconf --list-options gpg

# Change configuration
gpgconf --change-options gpg

# Check configuration
gpgconf --check-programs

# Runtime configuration
gpgconf --list-dirs
```

## Key Server Operations

### Popular Key Servers
```bash
# Ubuntu keyserver
gpg --keyserver keyserver.ubuntu.com --recv-keys KEYID

# MIT keyserver
gpg --keyserver pgp.mit.edu --recv-keys KEYID

# OpenPGP keyserver
gpg --keyserver keys.openpgp.org --recv-keys KEYID
```

### Key Server Configuration
```bash
# Set default keyserver in gpg.conf
echo "keyserver hkps://keys.openpgp.org" >> ~/.gnupg/gpg.conf

# Use specific keyserver
gpg --keyserver hkps://keys.openpgp.org --search-keys user@example.com
```

## Security Best Practices

### Key Generation
- Use 4096-bit RSA keys minimum
- Set reasonable expiration dates
- Generate strong passphrases
- Create revocation certificates immediately
- Store private keys securely

### Key Management
- Verify key fingerprints before trusting
- Sign keys only after proper verification
- Regularly update from keyservers
- Backup private keys securely
- Use hardware tokens when possible

### Operational Security
- Use secure systems for key operations
- Verify signatures on important communications
- Keep software updated
- Use strong passphrases
- Limit key exposure

## Configuration Files

### GPG Configuration (~/.gnupg/gpg.conf)
```
# Use strong preferences
personal-cipher-preferences AES256 AES192 AES
personal-digest-preferences SHA512 SHA384 SHA256
cert-digest-algo SHA512

# Security settings
no-emit-version
no-comments
keyid-format 0xlong
with-fingerprint
```

### Agent Configuration (~/.gnupg/gpg-agent.conf)
```
# Cache settings
default-cache-ttl 600
max-cache-ttl 7200

# Security settings
enable-ssh-support
```

## Installation
Complete GNU Privacy Guard cryptographic suite for secure communications.
Provides encryption, digital signatures, and comprehensive key management.

## Dependencies
- Windows Cryptographic APIs
- Network access for keyserver operations
- Terminal/console for interactive operations

## Use Cases
- Secure email communications
- File and document encryption
- Code signing and verification
- Git commit and tag signing
- Secure backup and storage
- Identity verification

---
*Part of PORTX Portable Development Environment*