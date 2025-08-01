# curl - HTTP Client and File Transfer Tool

[🏠 Back to Wiki Home](../index.md) | [🌐 Network Tools](../categories/network.md)

---

## Overview

Swiss Army knife for HTTP requests and file transfers. Supports 20+ protocols including HTTP, HTTPS, FTP, SFTP, SCP, and LDAP.

**Version**: 7.88.1  
**Location**: `usr/bin/curl.exe`  
**Category**: Network Tools

---

## Basic Usage

```bash
# Simple GET request
curl https://api.github.com/users/octocat

# Download file
curl -O https://example.com/file.zip

# POST with JSON data
curl -X POST -H "Content-Type: application/json" \
     -d '{"key":"value"}' https://api.example.com/data

# Follow redirects and save to file
curl -L -o output.html https://example.com
```

---

## Authentication

```bash
# Basic auth
curl -u username:password https://api.example.com

# Bearer token
curl -H "Authorization: Bearer TOKEN" https://api.example.com

# API key header
curl -H "X-API-Key: your-key" https://api.example.com
```

---

## Common Options

- **-X METHOD** - HTTP method (GET, POST, PUT, DELETE)
- **-H "Header"** - Add custom header
- **-d "data"** - POST data
- **-o file** - Write output to file
- **-O** - Write output to file (use remote name)
- **-L** - Follow redirects
- **-v** - Verbose output
- **-s** - Silent mode

---

## Examples

```bash
# Upload file
curl -X POST -F "file=@document.pdf" https://upload.example.com

# Check response headers only
curl -I https://example.com

# Test API endpoint
curl -X GET "https://api.example.com/users?page=1&limit=10"

# Download with progress bar
curl --progress-bar -O https://releases.ubuntu.com/20.04/ubuntu-20.04.iso
```