# 🌐 Network Tools (25 tools)

[🏠 Back to Wiki Home](../index.md)

---

## Tools in this category:

- **[bandwhich](../tools/bandwhich.md)** - Network utilization by process
- **[curl](../tools/curl.md)** - HTTP client and file transfer tool
- **[ftp](../tools/ftp.md)** - File Transfer Protocol client
- **[gping](../tools/gping.md)** - Ping with graphical output
- **[httpx](../tools/httpx.md)** - HTTP toolkit for probing
- **[nc](../tools/nc.md)** - Network Swiss Army knife (netcat)
- **[netstat](../tools/netstat.md)** - Network connections and statistics
- **[nslookup](../tools/nslookup.md)** - DNS lookup utility
- **[ping](../tools/ping.md)** - Network reachability test
- **[rsync](../tools/rsync.md)** - Remote file synchronization
- **[scp](../tools/scp.md)** - Secure copy over SSH
- **[ssh](../tools/ssh.md)** - Secure Shell remote access
- **[tcpdump](../tools/tcpdump.md)** - Packet capture and analysis
- **[telnet](../tools/telnet.md)** - Telnet protocol client
- **[wget](../tools/wget.md)** - Web file downloader

### **wget** - Robust file downloader
Non-interactive network downloader with resume capability.
- **Features**: Recursive downloads, mirror websites, background operation
- **Usage**: `wget -r -np -k http://example.com/docs/`
- **Advanced**: `wget --continue --progress=bar large-file.iso`
- **Location**: `usr/bin/wget.exe`

### **httpx** - Modern HTTP toolkit
Fast HTTP toolkit for probing and analysis.
- **Features**: Technology detection, response analysis, pipeline support
- **Usage**: `httpx -l domains.txt -title -tech-detect -status-code`
- **Security**: Perfect for web reconnaissance and analysis
- **Location**: `bin-tools/httpx/httpx.exe`

---

## 🔐 Secure Remote Access

### **ssh** - Secure Shell ⭐ **Essential**
Secure protocol for remote login and command execution.
- **Features**: Public key auth, port forwarding, tunneling, X11 forwarding
- **Usage**: `ssh user@server.com`, `ssh -L 8080:localhost:80 user@server`
- **Advanced**: `ssh -o ProxyCommand="ssh gateway nc %h %p" target`
- **Location**: `usr/bin/ssh.exe`

### **scp** - Secure Copy Protocol
Copy files over SSH with full security.
- **Usage**: `scp file.txt user@server:/path/`, `scp -r directory/ user@server:`
- **Advanced**: `scp -o ProxyJump=gateway user@target:/file .`
- **Location**: `usr/bin/scp.exe`

### **rsync** - Remote synchronization
Efficient file synchronization over SSH.
- **Features**: Delta transfer, compression, preserve attributes
- **Usage**: `rsync -avz /local/path/ user@server:/remote/path/`
- **Advanced**: `rsync -avz --delete --exclude="*.log" src/ dest/`
- **Location**: `usr/bin/rsync.exe`

---

## 🔍 Network Diagnostics

### **ping** - Network reachability test
Test network connectivity and measure round-trip time.
- **Usage**: `ping -c 4 google.com`, `ping -i 0.2 192.168.1.1`
- **IPv6**: `ping6 ipv6.google.com`
- **Location**: `usr/bin/ping.exe`

### **netstat** - Network connections
Display network connections, routing tables, and interface statistics.
- **Usage**: `netstat -tuln` (listening ports), `netstat -rn` (routing table)
- **Advanced**: `netstat -i` (interface statistics)
- **Location**: `usr/bin/netstat.exe`

### **nc (netcat)** - Network Swiss Army knife
Read and write data across network connections.
- **Features**: Port scanning, banner grabbing, simple server/client
- **Usage**: `nc -l 8080` (listen), `nc -zv host 20-25` (port scan)
- **Advanced**: `nc -e /bin/bash -l 4444` (reverse shell for testing)
- **Location**: `usr/bin/nc.exe`

### **nslookup** - DNS lookup utility
Query DNS servers for domain name or IP address information.
- **Usage**: `nslookup google.com`, `nslookup 8.8.8.8`
- **Advanced**: `nslookup -type=MX domain.com` (mail servers)
- **Location**: `usr/bin/nslookup.exe`

---

## 📊 Network Analysis

### **tcpdump** - Packet capture
Command-line packet analyzer for network troubleshooting.
- **Usage**: `tcpdump -i eth0 port 80`, `tcpdump -w capture.pcap host 192.168.1.1`
- **Advanced**: `tcpdump -X -s 0 'tcp[tcpflags] & tcp-syn != 0'`
- **Location**: `usr/bin/tcpdump.exe` (if available)

### **bandwhich** - Network utilization
Real-time network utilization by process and connection.
- **Features**: Process-based bandwidth usage, interactive TUI
- **Usage**: `bandwhich` (interactive mode)
- **Location**: `bin-tools/bandwhich/bandwhich.exe`

### **gping** - Graphical ping
Ping with a graph for visualizing network latency.
- **Features**: Real-time latency graphs, multiple hosts
- **Usage**: `gping google.com cloudflare.com`
- **Location**: `bin-tools/gping/gping.exe`

---

## 🌍 Protocol Utilities

### **telnet** - Telnet protocol client
Simple protocol for testing network services.
- **Usage**: `telnet smtp.gmail.com 587` (test SMTP)
- **Debugging**: `telnet localhost 80` (test HTTP)
- **Location**: `usr/bin/telnet.exe`

### **ftp** - File Transfer Protocol
Traditional file transfer client.
- **Usage**: `ftp ftp.example.com`, `ftp -p` (passive mode)
- **Location**: `usr/bin/ftp.exe`

---

## 🚀 Advanced Network Workflows

### HTTP API Testing
```bash
# REST API testing with curl
curl -X GET "https://api.github.com/user" \
     -H "Authorization: token YOUR_TOKEN" \
     -H "Accept: application/vnd.github.v3+json"

# POST with JSON data
curl -X POST "https://api.example.com/data" \
     -H "Content-Type: application/json" \
     -d '{"name": "test", "value": 123}'

# Upload file with progress
curl -X POST -F "file=@document.pdf" \
     --progress-bar "https://upload.example.com" | cat
```

### Network Troubleshooting
```bash
# Complete connectivity test
ping -c 4 target.com
nslookup target.com
nc -zv target.com 80 443
curl -I https://target.com

# Network path analysis
traceroute target.com
mtr --report target.com

# Port scanning
nc -zv target.com 20-25
nmap -sT -O target.com
```

### SSH Workflows
```bash
# SSH tunneling (local port forward)
ssh -L 3306:database:3306 user@gateway

# SSH tunneling (remote port forward)
ssh -R 8080:localhost:80 user@public-server

# SSH with jump host
ssh -J gateway user@internal-server

# SSH key management
ssh-keygen -t ed25519 -C "user@example.com"
ssh-copy-id user@server
```

### File Transfer Operations
```bash
# Secure file transfer
scp -r /local/directory/ user@server:/remote/path/
rsync -avz --progress /local/ user@server:/remote/

# Resume interrupted downloads
wget --continue https://large-file.iso
curl -C - -o file.zip https://example.com/file.zip

# Parallel downloads
curl -O https://example.com/file{1..10}.txt
```

---

## 🔧 Network Configuration

### Environment Variables
```bash
export HTTP_PROXY=http://proxy:8080
export HTTPS_PROXY=http://proxy:8080
export NO_PROXY=localhost,127.0.0.1,.local

export SSH_AUTH_SOCK=/tmp/ssh-agent.sock
export SSH_AGENT_PID=1234
```

### SSH Configuration (~/.ssh/config)
```
Host production
    HostName prod.example.com
    User deploy
    Port 22
    IdentityFile ~/.ssh/prod_key
    
Host *.internal
    ProxyJump gateway.example.com
    User internal-user
```

### Curl Configuration (~/.curlrc)
```
user-agent = "Custom-Agent/1.0"
connect-timeout = 10
max-time = 300
show-error
location
```

---

## 💡 Pro Tips

1. **Use SSH keys**: More secure than passwords, enable with `ssh-copy-id`
2. **Learn curl options**: Master `-H`, `-d`, `-X`, `-o`, `-L` flags
3. **SSH tunneling**: Access internal services securely through jump hosts
4. **Network debugging**: Combine `ping`, `traceroute`, and `nc` for diagnosis
5. **Parallel operations**: Use `xargs -P` for concurrent network operations
6. **Timeout settings**: Always set timeouts for network operations

---

## 🔗 Related Categories

- **[🛡️ Security & Cryptography](security.md)** - Security-focused network tools
- **[☁️ Cloud & Infrastructure](cloud.md)** - Cloud networking and load balancers
- **[📊 System Monitoring](monitoring.md)** - Network monitoring and analysis

---

*Use `portx network` to view this category | `portx search <term>` to find specific tools*

**[⬆️ Back to Top](#-network-tools-25-tools)** | **[🏠 Wiki Home](../index.md)**