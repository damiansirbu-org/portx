# PORTX TUI Manual Design

## 🎯 Goal
Transform the static MANUAL.md into an interactive TUI wiki-like interface with browsing, search, and navigation capabilities.

## 🛠️ Implementation Options

### Option 1: Enhanced `portx` Command with Existing Tools
**Use Glow or Frogmouth for TUI markdown viewing**

#### Glow (Recommended)
- **Built with**: Go + Bubble Tea framework
- **Features**: TUI navigation, search, bookmarks, file browser
- **Advantages**: Fast, lightweight, excellent markdown rendering
- **Integration**: Easy to embed as PORTX tool

#### Frogmouth 
- **Built with**: Python + Textual framework
- **Features**: Browser-like navigation, history, bookmarks, TOC
- **Advantages**: More wiki-like features, good UX
- **Disadvantages**: Python dependency

### Option 2: Custom PORTX TUI Manual
**Build custom Go application using Bubble Tea**

## 📋 Proposed Solution: Enhanced `portx` with Glow Integration

### Architecture
```
PORTX TUI Manual System
├── portx (enhanced launcher script)
├── glow.exe (TUI markdown browser)
├── MANUAL.md (source content)
├── manual/ (structured content directory)
│   ├── modern-unix.md
│   ├── gnu-linux.md  
│   ├── cloud-infrastructure.md
│   ├── security-analysis.md
│   ├── development.md
│   ├── monitoring.md
│   ├── database.md
│   ├── mobile.md
│   ├── files.md
│   └── testing.md
└── portx-manual.conf (configuration)
```

### Features to Implement

#### 1. Interactive Navigation
```bash
portx                    # Launch TUI manual browser
portx cloud              # Direct to cloud tools section
portx search "docker"    # Search within manual
portx bookmarks          # Manage bookmarks
```

#### 2. Wiki-like Features
- **Search**: Full-text search across all sections
- **Cross-references**: Links between related tools
- **Bookmarks**: Save frequently accessed tools
- **History**: Recently viewed sections
- **TOC**: Interactive table of contents

#### 3. Enhanced Content Structure
- **Section-based**: Split MANUAL.md into focused files
- **Examples**: Interactive code examples
- **Tool Status**: Real-time tool availability check
- **Version Info**: Live version detection

## 🚀 Implementation Plan

### Phase 1: Basic TUI Integration
1. **Add Glow to bin-tools**
   ```bash
   bin-tools/glow/glow.exe
   ```

2. **Enhance portx command**
   ```bash
   #!/bin/bash
   # Enhanced PORTX Manual with TUI
   
   case "$1" in
       "")
           # Launch interactive TUI browser
           glow -p /c/App/PORTX/manual/
           ;;
       "search")
           # Search within manual
           glow -s "$2" /c/App/PORTX/MANUAL.md
           ;;
       *)
           # Section-specific viewing
           glow /c/App/PORTX/manual/${1}.md 2>/dev/null || 
           glow /c/App/PORTX/MANUAL.md
           ;;
   esac
   ```

3. **Split MANUAL.md into sections**
   - Create `/manual/` directory
   - Split content by categories
   - Add cross-references

### Phase 2: Advanced Features
1. **Custom Glow configuration**
   ```yaml
   # ~/.config/glow/glow.yml
   style: "dark"
   mouse: true
   pager: true
   width: 120
   ```

2. **Enhanced search and bookmarks**
3. **Tool status integration**
4. **Cross-reference system**

### Phase 3: Custom Enhancements
1. **Real-time tool checking**
2. **Interactive examples**
3. **Bookmark system**
4. **Usage analytics**

## 📁 Content Structure Design

### Manual Directory Layout
```
manual/
├── index.md                 # Main index with quick navigation
├── categories/
│   ├── modern-unix.md       # 45 enhanced Unix tools
│   ├── gnu-linux.md         # 320 standard POSIX tools  
│   ├── cloud.md             # 24 cloud & infrastructure
│   ├── security.md          # 18 security & analysis
│   ├── development.md       # 12 development tools
│   ├── monitoring.md        # 8 system monitoring
│   ├── database.md          # 3 database management
│   ├── mobile.md            # 8 mobile development
│   ├── files.md             # 3 file management
│   └── testing.md           # 2 testing & API
├── tools/
│   ├── aws.md              # Individual tool pages
│   ├── kubectl.md
│   ├── docker-compose.md
│   └── [490+ individual tools]
├── guides/
│   ├── getting-started.md
│   ├── configuration.md
│   ├── troubleshooting.md
│   └── examples.md
└── assets/
    ├── screenshots/
    └── examples/
```

### Navigation Features
```markdown
# Cross-references in content
See also: [kubectl](tools/kubectl.md) | [helm](tools/helm.md)

# Quick links
🔗 Related: Cloud Tools | Container Management | Kubernetes

# Interactive elements  
💡 **Try it**: `kubectl get pods --all-namespaces`
🔍 **Search**: Type `/docker` to find Docker-related tools
⭐ **Bookmark**: Press `b` to bookmark this section
```

## 🎨 User Experience Design

### TUI Interface Layout
```
┌─ PORTX Manual ─────────────────────────────────────────────────────┐
│ [Search] [Bookmarks] [History] [Help]                              │
├─────────────────────────────────────────────────────────────────────┤
│ Table of Contents    │ Content Area                                 │
│                      │                                             │
│ • Modern Unix Tools  │ # AWS CLI (aws) - v2.7.13                  │
│   - Search & Text    │                                             │
│   - Data Processing  │ Complete AWS management suite for cloud     │
│   - File Management  │ infrastructure operations.                  │
│                      │                                             │
│ • GNU/Linux Tools    │ ## Basic Usage                              │
│ • Cloud Tools        │ ```bash                                     │
│ • Security Tools     │ aws s3 ls                 # List buckets    │
│ • Development        │ aws configure             # Setup creds     │
│                      │ ```                                         │
│ [494 tools total]    │                                             │
├─────────────────────────────────────────────────────────────────────┤
│ Navigation: ↑/↓ scroll | / search | b bookmark | q quit           │
└─────────────────────────────────────────────────────────────────────┘
```

### Command Interface
```bash
# Launch modes
portx                        # Interactive TUI browser
portx cloud                  # Jump to cloud tools
portx search "kubernetes"    # Search for k8s tools
portx tool aws               # Specific tool documentation  
portx bookmarks              # Manage bookmarks
portx recent                 # Recently viewed tools

# Navigation within TUI
/                           # Search mode
b                           # Bookmark current page
h                           # History
g                           # Go to section
q                           # Quit
```

## 🔧 Technical Implementation

### Required Tools
1. **glow.exe** - TUI markdown browser (Go, ~10MB)
2. **Enhanced portx script** - Navigation logic
3. **Manual structure** - Organized markdown files

### Dependencies
- Existing: Git Bash environment
- New: glow binary (Windows-compatible)
- Optional: fzf for enhanced search

### Performance
- **Startup time**: <1 second
- **Memory usage**: <50MB
- **File size**: Manual content ~2MB, Glow ~10MB

## ✅ Success Criteria

### User Experience
- **Intuitive**: Wiki-like browsing with familiar controls
- **Fast**: Sub-second navigation between sections
- **Comprehensive**: All 494 tools documented with examples
- **Searchable**: Find any tool or concept quickly

### Technical
- **Portable**: Works in any PORTX installation
- **Maintainable**: Easy to update tool documentation
- **Extensible**: Simple to add new tools and sections
- **Compatible**: Works in Git Bash environment

## 🚀 Next Steps

1. **Download and test Glow** for Windows compatibility
2. **Create manual directory structure** with split content
3. **Implement enhanced portx command** with TUI integration
4. **Test navigation and search features**
5. **Add cross-references and bookmarks**
6. **Document TUI manual usage**

This design provides a modern, interactive manual system that transforms PORTX from a simple tool collection into a comprehensive, browsable development environment with professional documentation.