# 🚀 PORTX Interactive Wiki
**By Damian Sirbu**

**Your Complete Windows POSIX Toolkit - 493 Professional Tools**

Welcome to the PORTX Interactive Wiki! Navigate through our comprehensive tool collection using the categories below.

---

## 📚 Tool Categories

Choose a category to see all tools:

- **[🗂️ File System & Core Utilities](categories/filesystem.md)** (58 tools)
- **[🌐 Network Tools](categories/network.md)** (25 tools)  
- **[🛡️ Security & Cryptography](categories/security.md)** (22 tools)
- **[💻 Development Tools](categories/development.md)** (45 tools)
- **[☁️ Cloud & Infrastructure](categories/cloud.md)** (28 tools)
- **[📊 System Monitoring](categories/monitoring.md)** (18 tools)
- **[🗄️ Database Tools](categories/database.md)** (8 tools)
- **[📱 Mobile Development](categories/mobile.md)** (12 tools)
- **[🔍 Text Processing](categories/text.md)** (35 tools)
- **[🧪 Testing & Quality](categories/testing.md)** (15 tools)

## 🔍 Search & Navigation

### Quick Search
- **Press `/`** to search within current page
- **Type `portx search "keyword"`** for global search
- **Use `portx tool toolname`** for specific tool docs

### Popular Tools
- **[aws](tools/aws.md)** - AWS CLI v2.7.13 (Cloud management)
- **[kubectl](tools/kubectl.md)** - v1.33.0 (Kubernetes management)
- **[rg](tools/ripgrep.md)** - v13.0.0 (Ultra-fast text search)
- **[jq](tools/jq.md)** - v1.6 (JSON processing)
- **[docker-compose](tools/docker-compose.md)** - v2.24.6 (Container orchestration)
- **[nuclei](tools/nuclei.md)** - v3.2.0 (Vulnerability scanner)
- **[osquery](tools/osquery.md)** - v5.18.1 (System instrumentation)
- **[helix](tools/helix.md)** - v25.07.1 (Modern text editor)

## 📖 Guides & Documentation

| Guide | Description |
|-------|-------------|
| [Getting Started](guides/getting-started.md) | First steps with PORTX |
| [Configuration](guides/configuration.md) | Customize your environment |
| [Troubleshooting](guides/troubleshooting.md) | Common issues and solutions |
| [Examples](guides/examples.md) | Real-world usage scenarios |

## 🛠️ Tool Status

- **Total Tools**: 493 executables
- **Working**: 492 (99.6% success rate)
- **Categories**: 8 functional areas
- **Last Updated**: [Current Date]

### System Health
- ✅ **Core Unix Tools**: 320/320 working
- ✅ **Modern Tools**: 44/45 working (zsh removed)
- ✅ **Professional Tools**: 128/129 working (ClamAV issue noted)

## 🎯 TUI Navigation Tips

### Keyboard Shortcuts
| Key | Action |
|-----|--------|
| `↑/↓` | Scroll content |
| `/` | Search within page |
| `g` | Go to top |
| `G` | Go to bottom |
| `q` | Quit |
| `h` | Help |
| `b` | Bookmark (if supported) |

### Command Interface
```bash
# Interactive browsing
portx                    # Launch TUI browser
portx manual             # Browse this index

# Category browsing  
portx cloud              # Cloud & infrastructure tools
portx security           # Security & analysis tools
portx dev                # Development tools

# Tool-specific docs
portx tool aws           # AWS CLI documentation
portx tool kubectl      # Kubernetes documentation

# Search functionality
portx search "docker"    # Find Docker-related tools
portx search "security"  # Find security tools
```

## 🏗️ Architecture Overview

```
PORTX/
├── portx.bat              # Main launcher
├── bin-ext/               # 44 enhanced Unix tools
├── bin-tools/             # 129 professional tools  
├── usr/bin/               # 272 core Unix tools
├── mingw64/bin/           # 48 development tools
├── manual/                # Interactive documentation
│   ├── categories/        # Tool categories
│   ├── tools/            # Individual tool docs
│   └── guides/           # Usage guides
└── MANUAL.md             # Complete reference
```

## 🚀 What's New

### Recent Additions
- **Interactive TUI Manual** - Wiki-like browsing interface
- **Comprehensive Testing** - All 494 tools verified
- **Structured Documentation** - Organized by categories
- **Search Capabilities** - Find tools quickly

### Tool Highlights
- **AWS CLI v2.7.13** - Latest AWS management
- **Kubernetes v1.33.0** - Current K8s tooling
- **Security Suite** - 18 professional security tools
- **Modern Editors** - Helix v25.07.1, Micro v2.0.10

---

## 📋 Quick Reference

### Most Used Commands
```bash
# Development
git status && git diff
kubectl get pods
docker-compose up -d
terraform plan

# Security  
nuclei -u target.com
osqueryi "SELECT * FROM processes"
yara32 rules.yar malware.exe

# System
rg "pattern" --type py
jq '.field' data.json
btop
```

### Environment Status
Check PORTX health with these indicators:
- **PORTX**: Environment security ✅
- **TOOLS**: 494 tools loaded ✅  
- **SSH**: Agent running ✅

---

*Navigate with ↑/↓ arrows, search with `/`, quit with `q`*