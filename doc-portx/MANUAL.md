# PORTX Manual - Complete Tool Reference
**By Damian Sirbu**

**493 Command-Line Tools for Windows** | Portable • Corporate-Friendly • Zero Dependencies

---

## Quick Navigation

- [Modern Unix Tools](#modern-unix-tools) (45 tools) - Enhanced replacements for standard utilities
- [GNU/Linux Tools](#gnulinux-tools) (320 tools) - Standard POSIX utilities from MinGW64
- [Cloud & Infrastructure](#cloud--infrastructure) (24 tools) - AWS, Azure, Kubernetes, Terraform
- [Security & Analysis](#security--analysis) (18 tools) - Antivirus, malware detection, vulnerability scanning
- [Development Tools](#development-tools) (12 tools) - Editors, version control, build tools
- [System Monitoring](#system-monitoring) (8 tools) - Resource monitoring, network analysis
- [Database Management](#database-management) (3 tools) - SQL clients, schema migration
- [Mobile Development](#mobile-development) (8 tools) - Android tools, device control
- [File Management](#file-management) (3 tools) - Advanced file managers, cloud storage
- [Testing & API](#testing--api) (2 tools) - Load testing, API automation

---

## Modern Unix Tools
*Enhanced Unix utilities with improved performance and features*

### Search & Text Processing

**ripgrep** (`rg`) - v13.0.0
Ultra-fast text search tool, replacement for grep
```bash
rg "pattern" --type py          # Search in Python files
rg -i "todo" -A 3 -B 1         # Case-insensitive with context
rg "class \w+" --only-matching  # Show only matching parts
```

**ag** (`ag`) - v2.2.0  
The Silver Searcher - fast code search
```bash
ag "function" --python          # Search in Python files
ag -l "TODO"                   # List files containing pattern
ag -C 3 "import"               # Show 3 lines of context
```

**fzf** (`fzf`) - v0.30.0
Fuzzy finder for interactive selection
```bash
fzf                            # Interactive file finder  
git log --oneline | fzf        # Fuzzy search git commits
history | fzf                  # Search command history
```

**peco** (`peco`) - v0.5.10
Simplistic interactive filtering
```bash
ps aux | peco                  # Interactive process picker
ls | peco                      # Interactive file picker
```

### Data Processing

**jq** (`jq`) - v1.6
JSON processor and query tool
```bash
curl api.github.com/user | jq '.name'     # Extract field
jq '.[] | select(.age > 30)' data.json    # Filter objects
jq -r '.items[].name' data.json           # Raw string output
```

**yq** (`yq`) - v4.31.2
YAML processor (like jq for YAML)
```bash
yq '.services.web.image' docker-compose.yml  # Extract value
yq -i '.version = "2.0"' config.yml          # Update in-place
yq -o json config.yml                        # Convert to JSON
```

**fx** (`fx`) - v22.0.0
Interactive JSON viewer and processor
```bash
echo '{"name":"test"}' | fx                # Interactive JSON explorer
curl api.example.com/data | fx '.results' # Browse API response
```

### File Management & Archives

**7za** (`7za`) - v25.00
7-Zip archiver with high compression
```bash
7za a backup.7z folder/               # Create archive
7za x archive.7z                      # Extract archive
7za l archive.7z                      # List contents
```

**less** (`less`) - v381
Enhanced pager with search and navigation
```bash
less +F /var/log/app.log             # Follow mode (like tail -f)
less +/pattern file.txt              # Open and search for pattern
less -N file.txt                     # Show line numbers
```

**micro** (`micro`) - v2.0.10
Modern terminal editor with mouse support
```bash
micro file.txt                       # Edit file with modern interface
micro -colorscheme monokai file.py   # Use specific color scheme
micro +25 file.txt                   # Open at line 25
```

### Development Support

**navi** (`navi`) - v2.19.0
Interactive cheatsheet and command runner
```bash
navi                                  # Browse cheatsheets interactively
navi --query docker                  # Search for docker commands
navi --print | fzf                   # Use with fuzzy finder
```

**gitstatusd** (`gitstatusd`) - v1.5.1
Ultra-fast git status for shell prompts
```bash
gitstatusd --num-threads=8           # Multi-threaded git status
```

**make** (`make`) - GNU Make v3.80
Enhanced build automation
```bash
make -j4                             # Parallel build with 4 jobs
make -n                              # Dry run (show commands)
make VERBOSE=1                       # Verbose output
```

### GNU Text Utilities (Enhanced)

All tools from GNU Textutils v2.1 with enhanced features:

**Text Viewing**: `cat`, `head`, `tail`, `less`
**Text Processing**: `cut`, `grep`, `sed`, `sort`, `uniq`, `tr`, `wc`
**Text Formatting**: `fmt`, `fold`, `expand`, `unexpand`, `nl`, `pr`
**File Comparison**: `comm`, `join`, `paste`
**File Manipulation**: `split`, `csplit`, `tac`, `tsort`
**Checksums**: `md5sum`, `sha1sum`, `cksum`, `sum`
**Octal Dump**: `od`, `ptx` (permuted index)

---

## GNU/Linux Tools
*Standard POSIX utilities providing complete Unix environment*

### Core System (272 from usr/bin + 48 from mingw64/bin)

**File Operations**
- `ls`, `cp`, `mv`, `rm`, `mkdir`, `rmdir`, `chmod`, `chown`
- `find`, `locate`, `which`, `whereis`, `file`, `stat`
- `ln`, `readlink`, `basename`, `dirname`

**Text Processing**  
- `grep`, `sed`, `awk`, `sort`, `uniq`, `cut`, `tr`, `wc`
- `cat`, `head`, `tail`, `more`, `less`
- `diff`, `patch`, `cmp`, `comm`

**Archive & Compression**
- `tar`, `gzip`, `gunzip`, `bzip2`, `bunzip2`
- `zip`, `unzip`, `compress`, `uncompress`

**System Information**
- `ps`, `top`, `kill`, `killall`, `jobs`, `bg`, `fg`
- `df`, `du`, `fdisk`, `mount`, `umount`
- `whoami`, `id`, `groups`, `w`, `who`, `uptime`

**Network Tools**
- `curl`, `wget`, `ssh`, `scp`, `sftp`, `rsync`
- `ping`, `netstat`, `nslookup`, `dig`, `telnet`

**Development**
- `gcc`, `g++`, `gdb`, `make`, `ar`, `nm`, `objdump`
- `git`, `cvs`, `patch`, `diff3`

**Shell & Scripting**
- `bash`, `sh`, `zsh`, `env`, `export`, `alias`
- `test`, `expr`, `printf`, `echo`, `sleep`

---

## Cloud & Infrastructure
*Enterprise-grade cloud and infrastructure management tools*

### Amazon Web Services

**aws** - AWS CLI v2.7.13
Complete AWS management suite
```bash
aws s3 ls                            # List S3 buckets
aws ec2 describe-instances           # List EC2 instances  
aws configure                        # Setup credentials
aws s3 sync . s3://bucket/          # Sync local to S3
aws iam list-users                   # List IAM users
```

### Microsoft Azure

**az** - Azure CLI v2.28.0 (via Scripts/az.bat)
Full Azure management capabilities
```bash
az login                             # Authenticate to Azure
az vm list                           # List virtual machines
az storage account list              # List storage accounts
az group create --name rg --location eastus  # Create resource group
```

### Kubernetes Ecosystem

**kubectl** - v1.33.0
Kubernetes cluster management
```bash
kubectl get pods                     # List pods
kubectl describe service web         # Describe service
kubectl apply -f deployment.yaml     # Apply configuration
kubectl logs -f pod-name            # Follow pod logs
kubectl exec -it pod-name -- bash   # Shell into pod
```

**helm** - v3.11.2
Kubernetes package manager
```bash
helm install app stable/nginx       # Install chart
helm list                          # List releases
helm upgrade app stable/nginx       # Upgrade release
helm rollback app 1                 # Rollback to revision
```

**k9s** - v0.50.3
Interactive Kubernetes cluster management TUI
```bash
k9s                                 # Launch interactive TUI
k9s --context production           # Use specific context
k9s --namespace kube-system        # Focus on namespace
```

**helmfile** - Declarative Helm deployment management
```bash
helmfile sync                       # Deploy all releases
helmfile diff                       # Show planned changes
helmfile destroy                    # Remove all releases
```

**kustomize** - v5.6.0 (via kubectl)
Kubernetes configuration customization
```bash
kubectl apply -k ./overlay/prod     # Apply kustomization
kustomize build ./overlay/dev       # Build configuration
```

**minikube** - Local Kubernetes development
```bash
minikube start                      # Start local cluster
minikube dashboard                  # Open web dashboard
minikube service list              # List services
```

### Infrastructure as Code

**terraform** - v1.7.5
Multi-cloud infrastructure automation
```bash
terraform init                      # Initialize working directory
terraform plan                      # Show execution plan
terraform apply                     # Apply changes
terraform destroy                   # Destroy infrastructure
terraform fmt                       # Format configuration files
```

### Container Management

**docker-compose** - v2.24.6
Multi-container Docker applications
```bash
docker-compose up -d                # Start services in background
docker-compose logs -f web          # Follow service logs
docker-compose scale web=3          # Scale service
docker-compose down                 # Stop and remove containers
```

**lazydocker** - Interactive Docker management TUI
```bash
lazydocker                          # Launch Docker TUI
```

**skopeo** - Container image operations
```bash
skopeo inspect docker://nginx:latest      # Inspect image
skopeo copy docker://nginx:latest dir:/tmp/nginx  # Copy image
```

### Enterprise Platforms

**oc** - Red Hat OpenShift CLI
Enterprise Kubernetes management
```bash
oc login https://api.cluster.com    # Login to OpenShift
oc new-project myapp               # Create new project
oc new-app nginx                   # Deploy application
```

---

## Security & Analysis
*Comprehensive security tools for threat detection and system analysis*

### Antivirus & Malware Detection

**ClamAV Suite** - Open-source antivirus engine
- `clamscan` - On-demand malware scanning
- `clamd` - Antivirus daemon for real-time protection  
- `freshclam` - Automatic virus definition updates
- `clamconf` - Configuration display
- `clamdtop` - Monitor clamd performance
- `clamsubmit` - Submit samples to ClamAV
- `sigtool` - Signature database management

```bash
clamscan -r /path/to/scan           # Recursive directory scan
clamscan --infected --remove /file  # Scan and remove infected files
freshclam                           # Update virus definitions
clamd                              # Start daemon mode
```

**YARA** - v4.5.4
Pattern matching engine for malware identification
```bash
yara32.exe rules.yar target_file    # Scan file with rules
yarac32.exe rules.yar compiled.yac  # Compile rules
yara32.exe -s rules.yar file        # Show matching strings
```

### System Instrumentation

**osquery** - v5.18.1
SQL-based operating system instrumentation
```bash
osqueryi                           # Interactive SQL mode
osqueryi "SELECT * FROM processes" # Query running processes
osqueryi "SELECT * FROM users"     # List system users
osqueryd --config_path=osquery.conf # Run as daemon
```

### Vulnerability Assessment

**nuclei** - v3.2.0
Fast vulnerability scanner with community templates
```bash
nuclei -u https://example.com       # Scan single target
nuclei -l urls.txt                 # Scan multiple targets
nuclei -t cves/ -u target.com      # Use CVE templates
nuclei -update-templates           # Update template database
```

**subfinder** - Subdomain discovery
```bash
subfinder -d example.com           # Find subdomains
subfinder -dL domains.txt          # Scan multiple domains
subfinder -o results.txt -d domain.com  # Save results
```

**rustscan** - Ultra-fast port scanner
```bash
rustscan -a 192.168.1.1            # Scan IP address
rustscan -a 192.168.1.0/24         # Scan network range
rustscan -a target.com -p 80,443   # Scan specific ports
```

### File Integrity & Hashing

**hashdeep** - v4.4
Recursive file hashing and integrity verification
```bash
hashdeep -r /path/to/files > hashes.txt    # Create hash database
hashdeep -k hashes.txt -r /path/to/files   # Verify integrity
hashdeep -c md5,sha1 file.txt              # Multiple algorithms
```

**Hash Suite** (12 tools):
- `md5deep`, `sha1deep`, `sha256deep` - Deep hashing utilities
- `hashdeep` - Master hash verification tool
- `tigerdeep`, `whirlpooldeep` - Additional algorithms

**ssdeep** - Fuzzy hashing for malware similarity
```bash
ssdeep file1.exe file2.exe         # Compare file similarity
ssdeep -r directory/ > fuzzy.txt   # Generate fuzzy hashes
ssdeep -m fuzzy.txt suspicious.exe # Match against database
```

### Cryptography & Encryption

**age** - Modern file encryption
```bash
age-keygen > key.txt               # Generate keypair
age -r $(cat key.txt.pub) file.txt > file.age  # Encrypt
age -d -i key.txt file.age > file.txt           # Decrypt
```

**GNU Privacy Guard (GPG)** - PGP encryption and signing
- `gpg` - Main GPG binary
- `gpg-agent` - Key agent for key management
- `gpgconf` - Configuration management
- `gpg-connect-agent` - Agent communication

```bash
gpg --gen-key                      # Generate keypair
gpg --encrypt -r user@example.com file.txt     # Encrypt file
gpg --decrypt file.txt.gpg         # Decrypt file
gpg --sign file.txt                # Sign file
```

---

## Development Tools
*Modern editors and development utilities*

### Code Editors

**helix** (`hx`) - v25.07.1
Post-modern text editor with built-in LSP support
```bash
hx file.rs                         # Edit Rust file with LSP
hx --grammar fetch                 # Update tree-sitter grammars
hx --health rust                   # Check language server status
```

**micro** (`micro`) - v2.0.10
User-friendly terminal editor with mouse support
```bash
micro file.py                      # Edit with syntax highlighting
micro -colorscheme monokai file.js # Use specific theme
micro +25:10 file.txt              # Open at line 25, column 10
```

### Version Control Enhancement

**lazygit** - v0.44.1
Interactive Git operations TUI
```bash
lazygit                            # Launch Git TUI
lazygit --path /other/repo         # Open specific repository
```

**Enhanced Git Tools** (8 tools in bin-tools/git/):
- Standard Git for Windows executables
- Additional utilities for Git workflow enhancement

### Text Processing Enhanced

**bat** - Enhanced `cat` with syntax highlighting
```bash
bat file.py                        # View with syntax highlighting
bat -A file.txt                    # Show all characters
bat --style=numbers,changes file.py # Line numbers and git changes
```

---

## System Monitoring
*Advanced system and network monitoring tools*

### Resource Monitoring

**btop** - v1.0.4
Advanced system resource monitor (Windows native port)
```bash
btop                               # Launch interactive system monitor
btop --utf-force                   # Force UTF-8 mode
```

**bottom** (`btm`) - Cross-platform system monitor
```bash
btm                                # Launch system monitor with graphs
btm --battery                      # Show battery information
btm -r 1000                        # Refresh every 1000ms
```

### Network Analysis

**bandwhich** - Real-time network utilization by process
```bash
bandwhich                          # Monitor network usage by process
bandwhich --interface eth0         # Monitor specific interface
```

**gping** - Ping with interactive graphs
```bash
gping google.com                   # Ping with real-time graph
gping google.com cloudflare.com    # Ping multiple hosts
gping --cmd "curl -o /dev/null -s -w %{time_total} https://example.com"
```

**httpx** - Advanced HTTP toolkit
```bash
httpx -l urls.txt                  # Test multiple URLs
httpx -probe -title -tech-detect   # Probe with technology detection
httpx -mc 200,301,302 -l targets.txt  # Filter by status codes
```

### Metrics & Monitoring

**promtool** - Prometheus metrics validation
```bash
promtool query instant 'up'        # Execute instant query
promtool check config prometheus.yml # Validate config
promtool tsdb analyze /data        # Analyze TSDB data
```

**telegraf** - Metrics collection agent
```bash
telegraf --config telegraf.conf    # Run with specific config
telegraf --test                    # Test configuration
telegraf --input-filter cpu --test # Test specific input
```

---

## Database Management
*Universal database tools and migration utilities*

### SQL Clients

**usql** - v0.19.25
Universal SQL CLI supporting multiple databases
```bash
usql postgres://user:pass@host/db   # Connect to PostgreSQL
usql mysql://user:pass@host/db      # Connect to MySQL
usql sqlite:///path/to/db.sqlite    # Connect to SQLite
usql --command "SELECT * FROM users" postgres://...  # Execute query
```

**lazysql** - Interactive SQL database management TUI
```bash
lazysql                            # Launch database TUI
lazysql --driver postgres --dsn "postgres://..." # Connect to specific DB
```

### Schema Migration

**liquibase** - Enterprise database schema migration
```bash
liquibase update                   # Apply database changes
liquibase rollback tag_v1.0        # Rollback to specific tag
liquibase diff                     # Compare database schemas
liquibase generateChangeLog        # Generate initial changelog
```

---

## Mobile Development
*Android development and device control tools*

### Android SDK Tools

**Android Debug Bridge (ADB)**
```bash
adb devices                        # List connected devices
adb install app.apk                # Install APK
adb shell                          # Shell into device
adb logcat                         # View device logs
adb pull /sdcard/file.txt .        # Pull file from device
```

**Fastboot** - Bootloader interface
```bash
fastboot devices                   # List devices in fastboot mode
fastboot flash recovery recovery.img # Flash recovery image
fastboot reboot                    # Reboot device
```

**Filesystem Tools**
- `make_f2fs.exe` - F2FS filesystem creation
- `mke2fs.exe` - ext2/3/4 filesystem creation
- `sqlite3.exe` - SQLite database management

### Device Control

**scrcpy** - Real-time Android screen mirroring
```bash
scrcpy                             # Mirror Android screen
scrcpy --record file.mp4           # Record screen to file
scrcpy --turn-screen-off           # Turn off device screen
scrcpy --max-size 1024             # Limit resolution
```

**Utilities**
- `etc1tool.exe` - ETC1 texture tool
- `hprof-conv.exe` - HPROF file converter

---

## File Management
*Advanced file managers and cloud storage tools*

### File Managers

**far** - Advanced file manager with dual-pane interface
```bash
far                                # Launch Far Manager
far /e file.txt                    # Edit file
far /v file.txt                    # View file
```

### Cloud Storage

**rclone** - Universal cloud storage sync (40+ providers)
```bash
rclone config                      # Configure cloud storage
rclone sync /local/path remote:bucket # Sync to cloud
rclone ls remote:bucket            # List remote files
rclone mount remote:bucket /mnt/cloud # Mount as filesystem
```

Supported providers: Google Drive, Amazon S3, Microsoft OneDrive, Dropbox, Box, Azure Blob, and 35+ more.

---

## Testing & API
*Load testing and API automation tools*

### API Testing

**newman** - Postman collection runner
```bash
newman run collection.json         # Run Postman collection
newman run collection.json -e env.json # Use environment file
newman run collection.json --reporters cli,json # Multiple reporters
```

### Load Testing

**k6** - Modern load testing with JavaScript
```bash
k6 run script.js                   # Run load test
k6 run --vus 10 --duration 30s script.js # 10 users for 30 seconds
k6 run --out json=results.json script.js # Output to JSON
```

Example k6 script:
```javascript
import http from 'k6/http';
export default function() {
  http.get('https://test-api.example.com');
}
```

---

## Shell Integration

### Command Completion
Most tools support shell completion:
```bash
# Enable completions (add to ~/.bashrc)
source <(kubectl completion bash)
source <(helm completion bash)
eval "$(ag --completion-bash)"
```

### Environment Variables
Key environment variables for tool configuration:
```bash
export EDITOR=micro               # Default editor
export PAGER=less                # Default pager  
export BROWSER="cmd.exe /c start" # Default browser
export KUBECONFIG=~/.kube/config # Kubernetes config
export AWS_PROFILE=default       # AWS profile
```

### Path Priority
Tools are loaded in this order:
1. `$HOME/bin` - User tools (highest priority)
2. `bin-ext` - Enhanced Unix tools  
3. `bin-tools/*` - Professional tools
4. `usr/bin` - Core Unix tools
5. `mingw64/bin` - Development tools
6. System PATH - Windows tools (lowest priority)

---

## Getting Help

### Tool Documentation
```bash
man command                        # Manual page (for GNU tools)
command --help                     # Help message
command -h                         # Short help
info command                       # Info documentation
```

### PORTX Specific
```bash
portx                             # Display this manual
show_tools_info                   # Show tools cache information
regenerate_tools_cache            # Rebuild tool cache
list_tool_directories             # List current tool directories
```

### Online Resources
- Tool GitHub repositories for latest documentation
- Official project websites
- Community wikis and tutorials
- Stack Overflow for troubleshooting

---

*PORTX Manual - Comprehensive reference for 494 portable command-line tools*