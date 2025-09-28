# PORTX Architecture

## System Overview

PORTX provides seamless access to Windows tools from Unix environments through intelligent wrapper generation and path conversion.

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   User Shell    │    │  PORTX Wrapper  │    │ Windows Tool    │
│                 │    │                 │    │                 │
│ $ git status    │───▶│ pathx.exe       │───▶│ git.exe         │
│                 │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
    Unix Path              Path Conversion         Windows Path
   /mnt/c/code         /mnt/c/code → C:\code      C:\code
```

## Core Components

### 1. Package System

**Structure**:
```
packages/
├── git/
│   ├── git.exe           # Windows executable
│   ├── portx.json        # Package metadata
│   └── [supporting files]
└── ripgrep/
    ├── rg.exe
    └── portx.json
```

**Package Configuration** (`portx.json`):
```json
{
  "name": "git",
  "version": "2.51.0",
  "description": "Git version control system",
  "importType": "wrap",
  "bin": {
    "git": {
      "path": "git.exe",
      "description": "Git command line tool"
    }
  }
}
```

### 2. Wrapper Generation System

**PowerShell Importer** (`ps/portx-import.ps1`):
- Scans package directory
- Generates cross-platform wrappers
- Creates PATH integration

**Generated Wrappers**:
```
wrappers/
├── posix/               # Unix-style bash scripts
│   ├── git              # calls pathx.exe
│   └── rg
└── windows/             # Windows CMD scripts
    ├── git.cmd          # direct executable call
    └── rg.cmd
```

**POSIX Wrapper Example**:
```bash
#!/bin/bash
# Auto-generated wrapper for git
PORTX_ROOT="/mnt/c/App/PORTX"
exec "$PORTX_ROOT/pathx/bin/pathx.exe" --platform=wsl \
     "$PORTX_ROOT/packages/git/git.exe" "$@"
```

### 3. PathX Conversion Engine

**Core Functionality**:
```
┌─────────────────────┐
│  PathX Components   │
├─────────────────────┤
│ • Input Converter   │────┐
│ • Output Converter  │    │
│ • Config Manager    │    │    ┌─────────────────┐
│ • Platform Detector │────────▶│  Windows Tool   │
└─────────────────────┘    │    └─────────────────┘
                           │
                    ┌─────────────┐
                    │ Path Rules  │
                    │ & Patterns  │
                    └─────────────┘
```

**PathX Execution Flow**:
```
1. Parse Arguments
   ├─ Extract PathX flags (--platform, --debug)
   └─ Identify executable and arguments

2. Input Conversion
   ├─ Convert Unix paths to Windows paths
   ├─ Apply tool-specific exclusion rules
   └─ Preserve regex patterns and flags

3. Execute Tool
   ├─ Convert executable path to Windows format
   ├─ Choose execution strategy (direct I/O vs pipe)
   └─ Run Windows executable

4. Output Processing
   ├─ Direct I/O: Preserve colors/TTY (default)
   └─ Pipe conversion: Convert paths in output (path tools only)
```

## Path Conversion Logic

### Input Path Conversion

**Platform Detection**:
```
┌─────────────┬─────────────────────┬─────────────────────┐
│ Environment │ Root Path           │ Detection Method    │
├─────────────┼─────────────────────┼─────────────────────┤
│ WSL         │ /mnt/c/App/PORTX    │ uname -sr (Linux)   │
│ MSYS2       │ /c/App/PORTX        │ uname -sr (MINGW)   │
│ Cygwin      │ /cygdrive/c/...     │ uname -sr (CYGWIN)  │
└─────────────┴─────────────────────┴─────────────────────┘
```

**Path Transformation**:
```go
WSL:    /mnt/c/code/file.txt      → C:\code\file.txt
MSYS2:  /c/code/file.txt          → C:\code\file.txt
Cygwin: /cygdrive/c/code/file.txt → C:\code\file.txt
```

### Output Path Conversion

**Strategy Matrix**:
```
┌──────────────┬─────────────────┬─────────────────────┐
│ Tool Type    │ I/O Strategy    │ Output Conversion   │
├──────────────┼─────────────────┼─────────────────────┤
│ Most Tools   │ Direct I/O      │ None (preserve)     │
│ (git, node)  │                 │                     │
├──────────────┼─────────────────┼─────────────────────┤
│ Path Tools   │ Pipe I/O        │ Windows → Unix      │
│ (rg, fd)     │                 │                     │
└──────────────┴─────────────────┴─────────────────────┘
```

## Configuration System

### Tool Exception Rules

**Input Exclusions** (prevent path conversion):
```json
{
  "input_exceptions": {
    "git": {
      "never_convert_after_flags": ["--grep", "--author"],
      "never_convert_patterns": ["^[a-f0-9]{4,40}$", "^HEAD~?[0-9]*$"]
    },
    "rg": {
      "never_convert_at_positions": [0],
      "never_convert_patterns": ["\\*\\.(txt|log)$"]
    }
  }
}
```

**Output Conversion** (enable for path tools):
```json
{
  "output_exceptions": {
    "path_output_tools": {
      "tools": ["rg", "fd", "find", "grep", "ls", "eza"],
      "conversion_enable": true
    }
  }
}
```

## Data Flow

### Package Import Flow

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Package Scan   │───▶│ Wrapper Generate│───▶│  PATH Update    │
│                 │    │                 │    │                 │
│ • Find portx.json│    │ • POSIX scripts │    │ • Add wrappers  │
│ • Validate JSON │    │ • Windows CMD   │    │ • Source paths  │
│ • Check binaries│    │ • Configure args│    │ • Export vars   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Tool Execution Flow

```
┌─────────────────┐
│  User Command   │
│  $ git status   │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐    Shell PATH resolution
│ POSIX Wrapper   │◀── finds /wrappers/posix/git
│ /wrappers/      │
│ posix/git       │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐    Execute with converted paths
│  PathX Engine   │◀── --platform=wsl C:\...\git.exe status
│ pathx.exe       │
└─────────┬───────┘
          │
          ▼
┌─────────────────┐    Direct I/O (preserves colors)
│ Windows Tool    │◀── C:\App\PORTX\packages\git\git.exe
│ git.exe         │
└─────────────────┘
```

## Design Decisions

### Why Direct I/O by Default?

**Problem**: Pipe-based I/O breaks:
- Terminal color output
- TTY detection
- Interactive prompts
- Progress indicators

**Solution**: Use direct I/O inheritance for most tools:
```go
cmd.Stdin = os.Stdin
cmd.Stdout = os.Stdout
cmd.Stderr = os.Stderr
```

**Exception**: Tools that output paths need pipe conversion:
- `rg` → needs path conversion in search results
- `fd` → needs path conversion in file listings

### Why Two-Layer Architecture?

**Layer 1: PowerShell Import**
- Cross-platform wrapper generation
- PATH management
- Package validation

**Layer 2: PathX Conversion**
- High-performance path conversion
- Tool-specific rule application
- Environment detection

**Benefits**:
- Separation of concerns
- Language-appropriate implementation
- Easy maintenance and debugging

## Performance Characteristics

### Wrapper Overhead
- **Cold start**: ~15ms (Go binary initialization)
- **Warm execution**: ~2ms (path conversion only)
- **Memory**: ~8MB (Go runtime + PathX)

### Scalability
- **Concurrent tools**: No interference between instances
- **Package count**: Tested with 200+ packages
- **Tool diversity**: Supports CLI, TUI, and daemon tools