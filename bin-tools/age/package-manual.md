# age Package Manual

## Package Information
- **Package Name**: age
- **Category**: Security
- **Type**: File Encryption
- **License**: BSD 3-Clause

## Description
Modern file encryption tool with small explicit keys, no config options, and UNIX-style composability.

Simple, secure file encryption focused on ease of use and modern cryptographic best practices.
Designed as a replacement for GPG for file encryption use cases.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| age.exe | File encryption and decryption tool | Encrypt and decrypt files with modern cryptography |
| age-keygen.exe | Key generation utility | Generate age key pairs |

## Common Usage Examples

### Key Management
```bash
# Generate a new key pair
age-keygen -o key.txt

# Generate key to stdout
age-keygen

# Generate multiple keys
age-keygen > alice.key
age-keygen > bob.key
```

### File Encryption
```bash
# Encrypt file with recipient's public key
age -r age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p file.txt > file.txt.age

# Encrypt with multiple recipients
age -r recipient1.txt -r recipient2.txt file.txt > file.txt.age

# Encrypt with passphrase
age -p file.txt > file.txt.age

# Encrypt from stdin
echo "secret data" | age -r public_key > secret.age
```

### File Decryption
```bash
# Decrypt with private key
age -d -i key.txt file.txt.age > file.txt

# Decrypt with passphrase
age -d file.txt.age > file.txt

# Decrypt to stdout
age -d -i key.txt file.txt.age

# Decrypt from stdin
cat file.txt.age | age -d -i key.txt
```

### Working with Public Keys
```bash
# Extract public key from private key
age-keygen -y key.txt

# Encrypt to public key file
age -R recipients.txt file.txt > file.txt.age
```

### SSH Key Integration
```bash
# Use SSH public key as recipient
age -R ~/.ssh/id_rsa.pub file.txt > file.txt.age

# Convert SSH private key for age
age -d -i ~/.ssh/id_rsa file.txt.age
```

### Batch Operations
```bash
# Encrypt multiple files
for file in *.txt; do
    age -r recipient.pub "$file" > "$file.age"
done

# Decrypt multiple files
for file in *.age; do
    age -d -i key.txt "$file" > "${file%.age}"
done
```

### Archive Encryption
```bash
# Encrypt directory as tar archive
tar czf - directory/ | age -r recipient.pub > directory.tar.gz.age

# Decrypt and extract
age -d -i key.txt directory.tar.gz.age | tar xzf -

# Encrypt with compression
gzip file.txt | age -r recipient.pub > file.txt.gz.age
```

## Key Format
```
# Private key example
AGE-SECRET-KEY-1GFPYYSJL8RA6GQLJTQK8DJEFRX4R5KT2WRWN8YJ9D6KPNCDQR8ZQ6T7J2K

# Public key example  
age1ql3z7hjy54pw3hyww5ayyfg7zqgvc7w3j2elw8zmrj2kg5sfn9aqmcac8p
```

## Best Practices
- Store private keys securely with proper file permissions
- Use multiple recipients for shared encrypted files
- Combine with compression for better efficiency
- Use SSH keys when available for convenience
- Always verify decryption before deleting original files

## Installation
Modern file encryption tool with simple interface and strong security.
Designed for easy integration into scripts and automation workflows.

## Dependencies
None - standalone executables with no external dependencies.

## Security Features
- ChaCha20-Poly1305 encryption
- X25519 key exchange
- scrypt for passphrase derivation
- No metadata leakage
- Forward secrecy support

---
*Part of PORTX Portable Development Environment*