# PORTX - Portable POSIX for Windows

**Your complete POSIX toolkit that corporate security actually likes.**

Zero installation. Zero dependencies. Zero problems. Just pure Unix power on Windows.

## 📚 Table of Contents
- [What is PORTX?](#-what-is-portx)
- [Why PORTX?](#why-portx)
- [Architecture](#️-architecture)
- [Tool Ecosystem](#️-tool-ecosystem)
- [Key Features](#-key-features)
- [Quick Start](#-quick-start)
- [Important Notes](#️-important-notes)
- [Philosophy](#-philosophy)

## 🎯 What is PORTX?

PORTX transforms Git for Windows into a complete, portable POSIX environment. It combines Git Bash as the trusted foundation with an architecture inspired by Cygwin and MSYS2, plus over 100+ carefully selected Windows-native command-line tools, all pre-configured to work together seamlessly. 

**PORTX = Portable + POSIX + Git Bash + 100+ Tools + Zero Hassle**

### 🔧 100% Windows Native
- **No DLL dependencies** - No cygwin1.dll, no msys-2.0.dll
- **Pure Windows executables** - All tools run directly on Windows
- **No emulation layers** - Native performance, no overhead
- **No registry entries** - Completely self-contained
- **No installation required** - Just extract and run

### ✅ Perfect for:
- Developers stuck on locked-down corporate Windows machines
- DevOps engineers who need real Unix tools
- Anyone who wants a consistent environment across different Windows PCs
- Teams who need to share the same toolset without installation hassles

### 📦 What's Included:
- Full Git Bash (MinGW64) environment with all Unix commands
- **100+ additional tools** from the best open source projects
- **Industry-standard DevOps**: AWS CLI, Azure CLI, Terraform, Kubernetes, Docker tools
- **Modern CLI tools**: Rust-based utilities (ripgrep, bat, fd), Go tools (fzf, lazygit)
- **Security & networking**: nmap, nuclei, age encryption, SSH suite
- Best utilities cherry-picked from Cygwin, MSYS2, and GitHub releases
- Complete POSIX/Unix environment: proper home directory, .bashrc, .bash_profile, etc.
- Pre-configured portable home with SSH, Git config, custom prompt
- **Zero external dependencies** - every tool is a standalone Windows-native executable

## Why PORTX?

### The POSIX on Windows Problem

For running Linux-style tools and POSIX environments on Windows, you have limited options:

**Cygwin**
- Heavy runtime with cygwin1.dll dependency for every tool
- Tools must be compiled specifically for Cygwin
- Performance overhead from POSIX emulation layer
- Often blocked by corporate security due to DLL injection concerns
- Requires installation and registry modifications

**MSYS2**
- Better than Cygwin but still requires msys-2.0.dll
- Package management adds complexity
- Multiple subsystems (MSYS, MINGW32, MINGW64) cause confusion
- Also frequently blocked by corporate security policies
- Requires administrative privileges for proper setup

**WSL/WSL2**
- Requires Windows features and admin rights
- Virtual machine overhead
- File system performance issues
- Network complexity
- Often disabled in corporate environments

### The Git Bash Advantage

**Git for Windows (Git Bash)** is different:
- **Corporate Approved**: Almost universally accepted because it's "just Git"
- **Native Windows**: MinGW-based tools run as native Windows executables
- **No Special DLLs**: Most tools are standalone executables
- **Trusted**: Microsoft themselves bundle Git Bash with Visual Studio
- **Lightweight**: No heavy emulation layers or virtual machines

### The Remaining Problems

Even Git Bash has issues:
- Standard Git Bash uses Windows user-specific paths (`C:\Users\%USERNAME%`)
- Limited tool selection out of the box
- Tools scattered across different installers pollute your system PATH
- Configuration files get lost in user profiles
- Moving between machines means reconfiguring everything

### The PORTX Solution

PORTX solves ALL these problems:
- **Corporate Friendly**: Built on Git Bash, which security teams already trust
- **100% Windows Native**: Every tool is a native Windows executable - no DLL dependencies
- **True Portability**: Everything runs from a single directory that can be moved/copied anywhere
- **Zero Installation**: No installers, no registry modifications, no admin rights needed
- **No Emulation**: Direct Windows execution means native performance
- **Unified Environment**: All tools use the same portable home directory
- **Developer Ready**: Everything a modern developer needs, pre-configured and ready to use

## 🏗️ Architecture

```
C:\App\Git\                    # Can be placed anywhere
├── git-bash-portable.bat      # Launcher that sets portable environment
├── bin\                       # Core Git Bash binaries
├── usr\                       # Unix system files
├── etc\                       # System configuration
├── home\
│   └── portable\              # Portable home directory
│       ├── .bashrc            # Shell configuration (DO NOT set USER/HOME here!)
│       ├── .gitconfig         # Git configuration
│       ├── .ssh\              # SSH keys and config
│       └── scripts\           # Custom shell scripts
├── bin-ext\                   # Additional core Unix tools
└── bin-tools\                 # Extended toolset organized by category
```

### How It Works

1. **True POSIX Environment**: Complete Unix-like file system hierarchy
   - Proper home directory with `.bashrc`, `.bash_profile`, `.gitconfig`
   - Unix-style configuration files and scripts
   - Full shell environment just like Linux/macOS

2. **Environment Override**: `portx.bat` (or `git-bash-portable.bat`) sets:
   - `HOME=/home/portable` (not user-specific)
   - `USER=portable`
   - `USERNAME=portable`

3. **Best of All Worlds**: 
   - Core system from Git Bash (trusted by corporate)
   - Architecture inspired by Cygwin and MSYS2's Unix-like hierarchy
   - Hundreds of tools from open source repositories - best in industry
   - Cherry-picked from Cygwin, MSYS2, and standalone projects
   - Industry-leading tools: Rust utilities (ripgrep, bat, delta), Go tools (lazygit, lazydocker), and more
   - But WITHOUT any DLL dependencies - everything runs as Windows-native executables

4. **Intelligent Tool Discovery**: Advanced PATH management with smart scanning
   - **Dynamic executable counting**: Real-time counts displayed as `TOOLS(122+45+118)`
   - **Scoped directory scanning**: Only searches within PORTX structure (prevents Cygwin64 pollution)
   - **Smart filtering**: Excludes temp, cache, uninstall, and setup-only directories
   - **Performance caching**: Daily cache regeneration with configurable scan depth
   - **Minimum executable threshold**: Only adds directories with sufficient tool density

## 🛠️ Tool Ecosystem

### Core System Tools (bin/)
All standard POSIX/Unix tools from MinGW64:
- **File Operations**: `ls`, `rm`, `cp`, `mv`, `mkdir`, `rmdir`, `find`, `locate`
- **Text Processing**: `cat`, `grep`, `sed`, `awk`, `sort`, `uniq`, `wc`, `cut`, `tr`
- **File Viewing**: `less`, `more`, `head`, `tail`, `nano`, `vim`
- **System**: `ps`, `kill`, `top`, `df`, `du`, `chmod`, `chown`, `which`, `whereis`
- **Network**: `curl`, `wget`, `ssh`, `scp`, `rsync`, `ping`, `netstat`
- **Archives**: `tar`, `gzip`, `gunzip`, `zip`, `unzip`
- **Development**: `git`, `gcc`, `make`, `diff`, `patch`
- Plus hundreds more standard Unix utilities

### Extended Unix Tools (bin-ext/)
Enhanced versions of Unix utilities:

**Text Processing & Search**
- `ag` - The Silver Searcher (faster code search)
- `rg` - Ripgrep (fastest grep replacement)
- `jq` - JSON processor and query tool
- `yq` - YAML processor and query tool
- `fx` - Interactive JSON viewer and processor
- Enhanced versions of `sed`, `grep`, `head`, `tail`

**File Management & Navigation**
- `fzf` - Fuzzy file finder with interactive interface
- `peco` - Interactive filtering for any list
- `navi` - Interactive cheatsheet and command runner
- `less`, `cat` - Enhanced file viewers
- `7za` - 7-Zip archive manager

**Development Tools**
- `make` - Enhanced build automation
- `micro` - Modern, user-friendly terminal editor
- `gitstatusd` - Ultra-fast git status for prompts
- `zsh` - Z shell (alternative to bash)

**System Utilities**
- Enhanced checksum tools: `md5sum`, `sha1sum`
- Text processing: `cut`, `sort`, `uniq`, `wc`, `tr`, `comm`, `join`
- File formatting: `fmt`, `fold`, `expand`, `unexpand`, `nl`, `pr`

### Professional Development Tools (bin-tools/)

**Cloud & Infrastructure**
- `aws` - AWS CLI v2 (complete AWS management)
- `azure-cli` - Microsoft Azure CLI (full Azure integration)
- `terraform` - Infrastructure as Code automation
- `helm` - Kubernetes package manager
- `helmfile` - Declarative Helm deployment management
- `kubectl` - Kubernetes cluster management CLI
- `kustomize` - Kubernetes configuration customization
- `k9s` - Interactive Kubernetes cluster management TUI
- `minikube` - Local Kubernetes development clusters
- `oc` - Red Hat OpenShift CLI
- `skopeo` - Container image operations and registry management

**Container & Orchestration**
- `docker-compose` - Multi-container Docker application management
- `lazydocker` - Interactive Docker management TUI
- Container image tools integrated with Kubernetes ecosystem

**Database Management**
- `usql` - Universal SQL CLI (supports PostgreSQL, MySQL, SQLite, etc.)
- `lazysql` - Interactive SQL database management TUI
- `liquibase` - Database schema migration and versioning

**System Monitoring & Analysis**
- `btop` - Advanced system resource monitor (Windows native port)
- `bottom` (`btm`) - Cross-platform system monitor with graphs
- `bandwhich` - Real-time network utilization by process
- `gping` - Ping with interactive graphs and statistics
- `httpx` - Advanced HTTP toolkit for testing and analysis
- `promtool` - Prometheus metrics validation and querying tools
- `telegraf` - Metrics collection agent for monitoring systems

**Security & Threat Detection**
- `age` - Modern file encryption (successor to GPG for files)
- `gpg` - GNU Privacy Guard (PGP encryption and signing)
- `nuclei` - Fast vulnerability scanner with community templates
- `subfinder` - Subdomain discovery for reconnaissance
- `rustscan` - Ultra-fast port scanner (faster than Nmap)
- `clamav` - Complete open-source antivirus engine with real-time scanning
- `yara` - Pattern matching engine for malware detection and analysis
- `osquery` - SQL-based operating system instrumentation and monitoring
- `hashdeep` - Recursive file hashing and integrity verification
- `ssdeep` - Fuzzy hashing for malware similarity detection

**Version Control & Git Enhancement**
- `lazygit` - Interactive Git operations TUI
- Enhanced git integration with custom prompt showing branch/status
- `git/` directory contains additional Git utilities:
  - `git-bash.exe`, `git-cmd.exe` - Standard Git for Windows launchers (archived)
  - Additional tools planned: `delta`, `difftastic`, `tig`, `gitui`, `gh`, `git-lfs`

**Code Editors & Text Processing**
- `helix` (`hx`) - Post-modern text editor with built-in LSP support
- `micro` - User-friendly terminal editor with mouse support
- `bat` - Enhanced `cat` with syntax highlighting and Git integration
- `ag` - The Silver Searcher (also in bin-ext for enhanced search)
- `ripgrep` (`rg`) - Fastest text search tool (also in bin-ext)

**Mobile & Android Development**
- `android-tools` - Complete Android SDK tools (ADB, Fastboot, etc.)
- `scrcpy` - Real-time Android device screen mirroring and control

**File Management & Cloud Storage**
- `far` - Advanced file manager with dual-pane interface
- `rclone` - Universal cloud storage sync (supports 40+ cloud providers)

**Testing & Load Generation**
- `newman` - Postman collection runner for API testing automation
- `k6` - Modern load testing tool with JavaScript scripting


## ✨ Key Features

### 1. Environment Status
On startup, you'll see:
```
✅ PORTX(MSYS2-MINGW64/xterm-256color) ✅ TOOLS(122+45+118) ✅ SSH(user@example.com)
/c/Work/Projects [main]
$
```

### 2. Custom Prompt
Two-line prompt showing:
- Current directory path
- Git branch and status (when in a repository)
- Clean command line on the second line

### 3. Status Indicators
Visual status indicators show system health at a glance:
- **✅** Green checkmark = Component working properly
- **🛑** Red stop sign = Component has issues
- **PORTX**: Environment security and compatibility
- **TOOLS**: Dynamic PATH loading with real-time executable counts (e.g., `TOOLS(122+45+118)`)
  - Shows core MinGW tools + bin-ext tools + bin-tools discoveries
  - Smart directory scanning with configurable depth and filtering
  - Cached for performance with automatic daily regeneration
- **SSH**: Agent status and loaded keys

### 4. SSH Agent Management
Automatic SSH agent startup with key loading from `~/.ssh/`

### 5. Environment Security
Detects and warns about PATH conflicts with other MSYS2/Cygwin installations

## 🚀 Quick Start

1. **Download**: Get PORTX and extract to any location (e.g., `C:\PORTX` or USB drive)
2. **Launch**: Run `portx.bat`
3. **Work**: All 100+ tools are immediately available in your PATH
4. **Move**: Copy the entire PORTX folder anywhere - it just works

That's it. No installation, no admin rights, no PATH pollution.

## ⚠️ Important Notes

⚠️ **Never modify USER or HOME in .bashrc!** The portable functionality depends on these being set by the launcher.

To update tools:
- Git: Download new portable Git and replace core files
- Individual tools: Replace executables in `bin-ext` or `bin-tools`

## 💡 Philosophy

PORTX follows the Unix philosophy:
- Each tool does one thing well
- Tools work together through standard interfaces
- Configuration is plain text
- No hidden magic or complex installers

This is not a package manager or a framework. It's a curated, pre-configured environment that just works.