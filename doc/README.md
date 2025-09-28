# PORTX Universal Toolchain

Cross-platform wrapper system providing seamless access to 200+ Windows tools from Unix environments using intelligent path conversion.

## Quick Start

```bash
# Tools work automatically via PATH
git --version
node --version
rg "pattern" /mnt/c/code

# Direct pathx usage
pathx --platform=wsl C:\App\PORTX\packages\git\git.exe status
```

## Architecture

```
User Command → POSIX Wrapper → PathX → Windows Executable
     ↓              ↓           ↓           ↓
   git status → /wrappers/posix/git → pathx.exe → git.exe
```

PORTX uses a two-layer approach:
- **PowerShell Package Import**: Generates cross-platform wrappers
- **PathX Go Tool**: Handles path conversion and execution

## Components

### 1. Package System
```
packages/
├── git/
│   ├── git.exe           # Windows executable
│   └── portx.json        # Package metadata
└── node/
    ├── node.exe
    └── portx.json
```

### 2. Wrapper Generation
```
ps/portx-import.ps1       # PowerShell package importer
wrappers/
├── posix/               # Unix-style wrappers
│   ├── git
│   └── node
└── windows/             # Windows CMD wrappers
    ├── git.cmd
    └── node.cmd
```

### 3. PathX Converter
```
pathx/
├── bin/pathx.exe        # Path conversion tool
├── src/                 # Go source code
└── config/tool-exceptions.json  # Conversion rules
```

## How It Works

### Input Path Conversion
- Unix paths → Windows paths for tool execution
- `/mnt/c/code` → `C:\code` (WSL)
- `/c/code` → `C:\code` (MSYS2)
- `/cygdrive/c/code` → `C:\code` (Cygwin)

### Output Path Conversion
- **Default**: No conversion (preserves colors/formatting)
- **Path tools only**: Convert Windows paths back to Unix
- Tools like `rg`, `fd`, `find` get output conversion
- Tools like `git`, `node` keep original output

### Configuration
Tool-specific rules in `pathx/config/tool-exceptions.json`:
```json
{
  "output_exceptions": {
    "path_output_tools": {
      "tools": ["rg", "fd", "find", "grep"],
      "conversion_enable": true
    }
  }
}
```

## Key Features

✅ **Preserves TTY/Colors**: Uses direct I/O for compatible tools
✅ **Smart Path Detection**: Only converts actual paths, not patterns
✅ **Cross-Platform**: WSL, Cygwin, MSYS2 support
✅ **Zero Configuration**: Works out of the box
✅ **High Performance**: Native Go path conversion

## Requirements

- Windows environment (native, WSL, Cygwin, MSYS2)
- PowerShell Core 5.1+ (for package import)
- Go 1.19+ (for building PathX)

## Documentation

- **[Architecture](architecture.md)**: System design and data flow
- **[Implementation](implementation.md)**: Development and building guide