# PORTX - Portable POSIX for Windows
**By Damian Sirbu**

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

PORTX transforms Git for Windows into a complete, portable POSIX environment. It combines Git Bash as the trusted foundation with an architecture inspired by Cygwin and MSYS2, plus 494 carefully selected Windows-native command-line tools, all pre-configured to work together seamlessly. 

**PORTX = Portable + POSIX + Git Bash + 494 Tools + Zero Hassle**

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
- **493 total executables** across all categories:
  - **272 Core Unix tools** (usr/bin) - ls, grep, awk, sed, tar, curl, ssh, etc.
  - **48 MinGW64 tools** (mingw64/bin) - gcc, git core, development libraries  
  - **44 Enhanced Unix tools** (bin-ext) - ripgrep, bat, fzf, jq, micro, 7za
  - **127 Professional tools** (bin-tools) - AWS, Azure, Kubernetes, security, Glow TUI
  - **2 System tools** (bin) - core shell executables
- **Industry-standard DevOps**: AWS CLI, Azure CLI, Terraform, Kubernetes, Docker tools
- **Security & malware detection**: ClamAV, YARA, osquery, hashdeep, ssdeep, nuclei
- **Modern CLI tools**: Rust-based utilities (ripgrep, bat), Go tools (lazygit, k9s)
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

4. **Tool Integration**: Additional tools in `bin-ext` and `bin-tools` are automatically available in PATH

## 🛠️ Tool Ecosystem

**493 Total Tools** organized in 8 categories. Use `portx` command for interactive TUI manual with Glow.

### Modern Unix Tools (44 tools - bin-ext/)
Enhanced replacements for standard Unix utilities:
- **Search**: `rg` (ripgrep v13.0.0), `ag` (Silver Searcher v2.2.0), `fzf` (fuzzy finder v0.30.0)
- **Data**: `jq` (JSON v1.6), `yq` (YAML v4.31.2), `fx` (interactive JSON v22.0.0)
- **Text**: Enhanced GNU textutils v2.1 - `cat`, `grep`, `sed`, `head`, `tail`, `cut`, `sort`, `wc`
- **Files**: `7za` (7-Zip v25.00), `less` (pager v381), `micro` (editor v2.0.10)
- **Dev**: `make` (GNU v3.80), `gawk` (v3.1.3), `gitstatusd` (v1.5.1), `navi` (cheatsheets v2.19.0)

### GNU/Linux Tools (320 tools - usr/bin + mingw64/bin)
Complete POSIX environment with all standard Unix utilities:
- **File Operations**: `ls`, `cp`, `mv`, `rm`, `mkdir`, `chmod`, `find`, `locate`
- **Text Processing**: `grep`, `sed`, `awk`, `sort`, `uniq`, `cut`, `tr`, `diff`
- **System Management**: `ps`, `top`, `kill`, `df`, `du`, `mount`, `crontab`
- **Network Tools**: `curl`, `wget`, `ssh`, `scp`, `rsync`, `ping`, `netstat`
- **Development**: `gcc`, `git`, `make`, `gdb`, `ar`, `nm`, `objdump`
- **Archives**: `tar`, `gzip`, `zip`, `bzip2` and compression utilities

### Professional Tools (127 tools - bin-tools/)
Enterprise-grade development and infrastructure tools including Glow TUI:

**Cloud & Infrastructure (24 tools)**: `aws` (v2.7.13), `az` (Azure v2.61.0), `kubectl` (v1.33.0), `helm` (v3.11.2), `k9s` (v0.50.3), `terraform` (v1.7.5), `docker-compose` (v2.24.6), `minikube`, `oc` (OpenShift)

**Security & Analysis (18 tools)**: `nuclei` (v3.2.0), `yara32` (v4.5.4), `osquery` (v5.18.1), `hashdeep` (v4.4), `gpg`, `age`, `rustscan`, `subfinder`, `ssdeep`

**Development (12 tools)**: `helix` (v25.07.1), `lazygit` (v0.44.1), `micro` (v2.0.10), `bat`, enhanced Git tools

**System Monitoring (8 tools)**: `btop` (v1.0.4), `bottom`, `bandwhich`, `gping`, `httpx`, `promtool`, `telegraf`

**Database (3 tools)**: `usql` (v0.19.25), `lazysql`, `liquibase`

**Mobile Development (8 tools)**: `adb`, `fastboot`, `scrcpy`, `sqlite3`, Android filesystem tools

**File Management (3 tools)**: `far`, `rclone` (40+ cloud providers)

**Testing & API (2 tools)**: `newman` (Postman), `k6` (load testing)

## 📖 Documentation

- **`portx`** - Interactive TUI wiki browser with Glow v2.1.1 rendering
- **`doc-portx/MANUAL.md`** - Complete tool reference with categories and examples  
- **`doc-portx/TOOL_STATUS.md`** - Full testing results (492/493 tools working - 99.8% success rate)
- **`doc-portx/manual/`** - Interactive wiki structure with categories and guides

Quick access:
```bash
portx                    # Interactive wiki browser  
portx wiki               # Same enhanced browsing
portx man                # Classical manual view
portx cloud              # Cloud & infrastructure tools
portx security           # Security & analysis tools
portx dev                # Development tools
```


## ✨ Key Features

### 1. Environment Status
On startup, you'll see:
```
✅ PORTX(MSYS2-MINGW64/xterm-256color) ✅ TOOLS ✅ SSH(user@example.com)
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
- **TOOLS**: PATH loading and tool availability (494 executables)
- **SSH**: Agent status and loaded keys

### 4. SSH Agent Management
Automatic SSH agent startup with key loading from `~/.ssh/`

### 5. Environment Security
Detects and warns about PATH conflicts with other MSYS2/Cygwin installations

## 🚀 Quick Start

1. **Download**: Get PORTX and extract to any location (e.g., `C:\PORTX` or USB drive)
2. **Launch**: Run `portx.bat`
3. **Work**: All 494 tools are immediately available in your PATH
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