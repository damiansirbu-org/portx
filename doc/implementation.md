# PORTX Implementation Guide

## Development Environment Setup

### Prerequisites
- Windows 10/11 or Windows Server 2019+
- PowerShell Core 5.1+ for package import
- Go 1.19+ for building PathX
- WSL, Cygwin, or MSYS2 for cross-platform testing

### Directory Structure
```
PORTX/
├── packages/               # Tool packages (200+ packages)
│   ├── git/
│   │   ├── git.exe
│   │   └── portx.json
│   └── ripgrep/
│       ├── rg.exe
│       └── portx.json
├── pathx/                  # PathX conversion engine
│   ├── bin/pathx.exe       # Compiled PathX tool
│   ├── src/                # Go source code
│   │   ├── main.go
│   │   ├── config.go
│   │   ├── input.go
│   │   ├── output.go
│   │   └── platform.go
│   └── config/
│       └── tool-exceptions.json
├── wrappers/               # Generated wrappers
│   ├── posix/              # Unix-style bash scripts
│   └── windows/            # Windows CMD scripts
├── ps/                     # PowerShell import system
│   └── portx-import.ps1
└── doc/                    # Documentation
```

## Building PathX

### Compile PathX Engine
```bash
cd pathx/src
go build -o ../bin/pathx.exe .

# Test PathX
../bin/pathx.exe --help
../bin/pathx.exe --platform=wsl C:\\App\\PORTX\\packages\\git\\git.exe --version
```

### Build Dependencies
```go
// go.mod
module pathx

go 1.19

require (
    github.com/spf13/pflag v1.0.5
)
```

## Package System

### Package Configuration (`portx.json`)
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

### Package Import Process
```powershell
# Import all packages
./portx-import.ps1

# Import specific package
./portx-import.ps1 -PackageName git

# Generate wrappers and update PATH
./portx-import.ps1 -UpdatePath
```

## Wrapper Generation

### POSIX Wrapper Template
```bash
#!/bin/bash
# Auto-generated wrapper for {tool}
PORTX_ROOT="/mnt/c/App/PORTX"
exec "$PORTX_ROOT/pathx/bin/pathx.exe" --platform=wsl \
     "$PORTX_ROOT/packages/{package}/{executable}" "$@"
```

### Windows Wrapper Template
```cmd
@echo off
rem Auto-generated wrapper for {tool}
set PORTX_ROOT=C:\App\PORTX
"%PORTX_ROOT%\packages\{package}\{executable}" %*
```

### Generation Flow
```
Package Scan → Wrapper Generation → PATH Integration
     ↓              ↓                   ↓
Find portx.json → POSIX + Windows → Add to PATH
Validate JSON   → Configure args  → Export vars
Check binaries  → Set permissions → Source paths
```

## PathX Core Implementation

### Main Execution Flow (`main.go`)
```go
func main() {
    // Parse PathX-specific flags
    var platform, debug bool
    flag.StringVar(&platformFlag, "platform", "", "Platform type")
    flag.BoolVar(&debug, "debug", false, "Enable debug output")
    flag.Parse()

    // Get executable and arguments
    args := flag.Args()
    executablePath := args[0]
    toolArgs := args[1:]

    // Convert executable path to Windows format
    convertedExecutablePath := pathConverter.convertPath(executablePath)

    // Process arguments with path conversion
    convertedArgs := pathConverter.convertArguments(toolArgs)

    // Execute with appropriate I/O strategy
    if outputConverter.ShouldUseDirectIO() {
        outputConverter.ExecuteDirect(cmd)
    } else {
        outputConverter.ExecuteWithOutput(cmd)
    }
}
```

### Path Conversion Logic (`input.go`)
```go
// Convert Unix paths to Windows paths for tool execution
func (pc *PathConverter) convertPath(path string) string {
    switch pc.platform {
    case PlatformWSL:
        return pc.wslToWindows(path)    // /mnt/c/code → C:\code
    case PlatformMSYS2:
        return pc.msys2ToWindows(path)  // /c/code → C:\code
    case PlatformCygwin:
        return pc.cygwinToWindows(path) // /cygdrive/c/code → C:\code
    }
    return path
}
```

### Output Processing (`output.go`)
```go
func (oc *OutputConverter) ShouldUseDirectIO() bool {
    // Use direct I/O unless tool needs output path conversion
    return !oc.shouldConvertOutput()
}

func (oc *OutputConverter) ExecuteDirect(cmd *exec.Cmd) error {
    // Direct I/O inheritance for TTY preservation
    cmd.Stdin = os.Stdin
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr
    return cmd.Run()
}
```

## Configuration System

### Tool Exception Rules (`tool-exceptions.json`)
```json
{
  "input_exceptions": {
    "git": {
      "never_convert_after_flags": ["--grep", "--author"],
      "never_convert_patterns": ["^[a-f0-9]{4,40}$", "^HEAD~?[0-9]*$"]
    },
    "rg": {
      "never_convert_at_positions": [0],
      "never_convert_patterns": ["\\.(txt|log)$"]
    }
  },
  "output_exceptions": {
    "path_output_tools": {
      "tools": ["rg", "fd", "find", "grep"],
      "conversion_enable": true
    }
  }
}
```

### Configuration Loading (`config.go`)
```go
func (cm *ConfigManager) LoadConfig() error {
    configPaths := []string{
        "config/tool-exceptions.json",
        "../config/tool-exceptions.json",
        "/App/PORTX/pathx/config/tool-exceptions.json"
    }

    // Find and load first available config
    for _, path := range configPaths {
        if data, err := os.ReadFile(path); err == nil {
            return json.Unmarshal(data, cm.config)
        }
    }
    return fmt.Errorf("config not found")
}
```

## Platform Detection

### Environment Detection (`platform.go`)
```go
func DetectPlatform() Platform {
    if runtime.GOOS == "windows" {
        return PlatformWindows
    }

    unameOutput := getUnameOutput()
    switch {
    case strings.Contains(unameOutput, "Microsoft"):
        return PlatformWSL
    case strings.Contains(unameOutput, "MINGW"):
        return PlatformMSYS2
    case strings.Contains(unameOutput, "CYGWIN"):
        return PlatformCygwin
    default:
        return PlatformLinux
    }
}
```

### Path Mapping
```
┌─────────────┬─────────────────────┬─────────────────────┐
│ Environment │ Unix Path           │ Windows Path        │
├─────────────┼─────────────────────┼─────────────────────┤
│ WSL         │ /mnt/c/code         │ C:\code             │
│ MSYS2       │ /c/code             │ C:\code             │
│ Cygwin      │ /cygdrive/c/code    │ C:\code             │
└─────────────┴─────────────────────┴─────────────────────┘
```

## I/O Strategy Decision Matrix

```
┌──────────────┬─────────────────┬─────────────────────┐
│ Tool Type    │ I/O Strategy    │ Output Conversion   │
├──────────────┼─────────────────┼─────────────────────┤
│ Most Tools   │ Direct I/O      │ None (preserve TTY) │
│ (git, node)  │                 │                     │
├──────────────┼─────────────────┼─────────────────────┤
│ Path Tools   │ Pipe I/O        │ Windows → Unix      │
│ (rg, fd)     │                 │                     │
└──────────────┴─────────────────┴─────────────────────┘
```

## Testing and Validation

### PathX Testing
```bash
# Test path conversion
pathx.exe --platform=wsl --debug C:\\code\\git.exe status /mnt/c/project

# Test I/O strategies
pathx.exe C:\\packages\\git\\git.exe log --oneline    # Direct I/O
pathx.exe C:\\packages\\rg\\rg.exe "pattern" .        # Pipe conversion

# Test tool-specific rules
pathx.exe C:\\packages\\git\\git.exe --grep "commit"  # No path conversion
```

### Integration Testing
```bash
#!/bin/bash
# Test complete workflow

# Test wrapper execution
git --version                    # Via POSIX wrapper
rg "pattern" /mnt/c/code        # With output conversion

# Test cross-platform paths
fd ".txt" /mnt/c/documents      # WSL paths
node /c/scripts/test.js         # MSYS2 paths
```

### Critical Test Cases
1. **TTY Preservation**: `git log --oneline` (colors preserved)
2. **Path Conversion**: `rg "pattern" /mnt/c/src` (paths converted)
3. **Regex Safety**: `rg "*.txt"` (patterns not converted)
4. **Mixed Arguments**: `git log --grep "fix" /mnt/c/repo`

## Build and Deployment

### Build Process
```bash
# Build PathX
cd pathx/src
go build -ldflags="-s -w" -o ../bin/pathx.exe .

# Import packages and generate wrappers
cd ../../ps
./portx-import.ps1 -UpdatePath

# Verify installation
which git    # Should find POSIX wrapper
git --version
```

### Deployment Checklist
- [ ] PathX compiled and tested
- [ ] All package portx.json files validated
- [ ] Wrappers generated for all platforms
- [ ] PATH integration verified
- [ ] Tool-specific rules tested
- [ ] Cross-platform compatibility confirmed

## Performance Characteristics

### Execution Overhead
- **Cold start**: ~15ms (Go binary initialization)
- **Warm execution**: ~2ms (path conversion only)
- **Memory usage**: ~8MB (Go runtime + PathX)

### Optimization Strategies
```go
// Pre-compile regex patterns
var windowsPathRegex = regexp.MustCompile(`[A-Za-z]:[\\\\/][^\\s]*`)

// Efficient path building
result := make([]byte, 0, len(path)+10)

// Direct I/O for performance
cmd.Stdin = os.Stdin
cmd.Stdout = os.Stdout
cmd.Stderr = os.Stderr
```

## Troubleshooting

### Common Issues

#### PathX Execution Errors
```bash
# Debug PathX
pathx.exe --debug C:\\packages\\tool\\tool.exe args

# Check executable path conversion
echo "Original: C:\\packages\\git\\git.exe"
echo "Should exist: $(ls -la /mnt/c/App/PORTX/packages/git/git.exe)"
```

#### Wrapper Generation Problems
```powershell
# Debug package import
$VerbosePreference = "Continue"
./portx-import.ps1 -PackageName git

# Check generated wrappers
Get-Content wrappers/posix/git
Test-Path packages/git/git.exe
```

#### Path Conversion Issues
```bash
# Test platform detection
uname -sr                        # Should show Linux/MINGW/CYGWIN
echo $WSL_DISTRO_NAME           # WSL detection

# Manual path testing
pathx.exe --platform=wsl --debug echo /mnt/c/test
```

This implementation guide covers the essential aspects of building, configuring, and deploying the current PathX-based PORTX system while maintaining simplicity and focus on practical implementation details.