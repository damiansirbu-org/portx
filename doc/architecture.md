# PORTX 2.0 Architecture

## System Overview

PORTX 2.0 implements a cross-platform package management system designed to provide seamless access to portable tools across Windows-based environments. The architecture solves fundamental compatibility challenges between Windows executables and Unix-like shells through intelligent wrapper generation and environment detection.

## Core Components

### 1. Entry Layer

#### Multi-Platform Entry Points
- **`portx.sh`**: Cross-platform bash entry point
- **`portx.cmd`**: Windows batch entry point
- **Function**: Environment detection and PowerShell Core delegation

#### Environment Detection Matrix
| Environment | Root Path | Detection Method |
|-------------|-----------|------------------|
| WSL | `/mnt/c/App/PORTX` | `$WSL_DISTRO_NAME` |
| Cygwin | `/cygdrive/c/App/PORTX` | `$CYGWIN` or `cygpath` |
| MSYS2/Git Bash | `/c/App/PORTX` | `$MSYSTEM` |
| Native Windows | `C:\App\PORTX` | PowerShell execution |

### 2. Core Engine

#### PowerShell Import Manager (`ps/portx-import.ps1`)
- **Size**: 26,000+ lines of production code
- **Language**: PowerShell 5.1+ (cross-platform compatible)
- **Dependencies**: None (self-contained)
- **Execution**: Via included PowerShell Core (`packages/powershell-core/`)

#### Key Subsystems
1. **Package Validation**: JSON schema compliance and integrity checks
2. **Wrapper Generation**: Cross-platform executable wrapper creation
3. **Environment Adaptation**: Platform-specific path and execution handling
4. **Logging System**: Structured logging with file persistence
5. **PATH Management**: Dynamic environment path construction

### 3. Package System

#### Package Structure
```
packages/
├── {package-name}/
│   ├── portx.json           # Package configuration
│   ├── {executables}        # Tool binaries
│   └── {supporting-files}   # Dependencies and assets
```

#### Configuration Schema (`portx.json`)
```json
{
  "name": "package-name",
  "version": "semver",
  "description": "package description",
  "importType": "wrap|path|wrapAndPath|none",
  "bin": {
    "tool-name": {
      "path": "relative/path/to/executable",
      "description": "tool description",
      "usage": "usage examples",
      "dependencies": "windows|linux|cross-platform"
    }
  },
  "tags": ["category", "keywords"]
}
```

#### Import Strategies
1. **`wrap`**: Generate wrappers only (default for most tools)
2. **`path`**: Add package root to PATH environment
3. **`wrapAndPath`**: Both wrapper generation and PATH addition
4. **`none`**: Documentation packages, no executable imports

### 4. Wrapper System

#### Dual Wrapper Architecture

**POSIX Wrapper** (`wrappers/posix/{tool}`):
- **Target**: bash, zsh, WSL, Cygwin, MSYS2
- **Features**: Environment detection, path resolution, direct execution
- **Format**: Executable bash script with shebang

**Windows Wrapper** (`wrappers/windows/{tool}.cmd`):
- **Target**: cmd.exe, PowerShell
- **Features**: Environment variables, batch execution
- **Format**: Windows batch file

#### Wrapper Generation Logic
```powershell
New-BashWrapper -PackageName $pkg -ToolName $tool -ExecutablePath $path
New-CmdWrapper -PackageName $pkg -ToolName $tool -ExecutablePath $path
```

#### Environment-Aware Execution
```bash
# Dynamic root detection
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    PORTX_ROOT="/mnt/c/App/PORTX"
elif [[ "$OSTYPE" == "cygwin" ]]; then
    PORTX_ROOT="/cygdrive/c/App/PORTX"
else
    PORTX_ROOT="/c/App/PORTX"
fi

# Direct executable invocation
exec "$PORTX_ROOT/packages/$PACKAGE/$EXECUTABLE" "$@"
```

## Advanced Features

### WSL Path Conversion

#### Problem Statement
Windows executables in WSL cannot process Unix-style paths (`/mnt/c/...`), requiring automatic path translation.

#### Solution Implementation
```bash
# WSL path conversion logic
if [[ "$WSL_ENV" == "true" ]]; then
    for arg in "$@"; do
        if [[ "$arg" =~ ^/[^-] ]]; then
            converted=$(wslpath -w "$arg" 2>/dev/null)
            args+=("${converted:-$arg}")
        else
            args+=("$arg")
        fi
    done
fi
```

#### Deployment Status
- **Completed**: fd wrapper
- **Planned**: rg, es, dust, duf, shellcheck, dprint

### Logging Architecture

#### Multi-Level Logging System
```powershell
# Structured logging levels
Write-PortxTrace   # Detailed debug information
Write-PortxDebug   # Development debugging
Write-PortxInfo    # General information
Write-PortxWarn    # Warning conditions
Write-PortxError   # Error conditions
Write-PortxFatal   # Fatal errors
```

#### Log Destinations
1. **File Logging**: `logs/portx-import.log` (all levels)
2. **Console Output**: Filtered for user relevance
3. **Structured Format**: ISO timestamp, level, category, message

### Package Validation

#### Multi-Stage Validation Process
1. **Schema Validation**: JSON structure compliance
2. **File Integrity**: Executable existence verification
3. **Cross-Reference**: Package metadata consistency
4. **Platform Compatibility**: Environment-specific validation

#### Validation Implementation
```powershell
function Test-PortxPackage {
    # JSON schema validation
    # Executable path verification
    # Package integrity checks
    # Platform dependency validation
}
```

### PATH Management

#### Dynamic PATH Construction
```bash
# Environment-aware PATH generation
export PATH="$PATH:$PORTX_ROOT/wrappers/posix"

# Package-specific PATH additions
PACKAGES_PATH="$PORTX_ROOT/packages/pkg1:$PORTX_ROOT/packages/pkg2"
export PORTX_PACKAGES_PATH="$PACKAGES_PATH"
```

## Data Flow Architecture

### Package Import Sequence
1. **Entry Point** → Environment detection and PowerShell delegation
2. **Package Discovery** → Scan packages directory for configurations
3. **Validation** → Schema and integrity verification
4. **Wrapper Generation** → Cross-platform wrapper creation
5. **PATH Integration** → Environment path construction
6. **Verification** → Wrapper functionality validation

### Wrapper Execution Flow
1. **Tool Invocation** → User executes wrapper
2. **Environment Detection** → Determine platform and paths
3. **Path Resolution** → Calculate executable location
4. **Argument Processing** → WSL path conversion if needed
5. **Direct Execution** → `exec` to target executable

## Security Model

### Execution Safety
- **No Code Injection**: Only validated package configurations processed
- **Path Sanitization**: All paths validated and sanitized
- **Privilege Isolation**: Executables run with user privileges
- **Configuration Validation**: JSON schema prevents malicious configs

### File System Security
- **Read-Only Packages**: Package contents not modified during execution
- **Controlled Writes**: Only wrappers and logs written to controlled locations
- **Path Validation**: All file operations use validated absolute paths

## Performance Characteristics

### Wrapper Overhead
- **Startup Time**: < 10ms per wrapper invocation
- **Memory Usage**: Minimal bash/cmd process overhead
- **I/O Impact**: Direct executable execution, no intermediate processing

### Scalability Factors
- **Package Count**: Tested with 200+ packages
- **Concurrent Execution**: Multiple wrappers execute independently
- **Import Performance**: Parallel package processing capabilities

## Platform Compatibility Matrix

| Feature | Windows | WSL | Cygwin | MSYS2 | Linux |
|---------|---------|-----|--------|-------|-------|
| Package Import | ✓ | ✓ | ✓ | ✓ | ✓* |
| POSIX Wrappers | - | ✓ | ✓ | ✓ | ✓ |
| Windows Wrappers | ✓ | - | - | - | - |
| Path Conversion | - | ✓ | Partial | Partial | - |
| PowerShell Core | ✓ | ✓ | ✓ | ✓ | ✓ |

*Linux support requires Windows package access via network or mount

## Extension Points

### Custom Package Integration
1. Create `packages/{name}/portx.json`
2. Place executables in package directory
3. Run `portx import {name}`

### Wrapper Customization
- **Default Arguments**: Specified in package configuration
- **Environment Variables**: Set in wrapper generation
- **Custom Logic**: Extended wrapper templates

### Platform Extensions
- **New Environments**: Add detection logic to entry points
- **Custom Paths**: Extend environment detection matrix
- **Special Handling**: Platform-specific wrapper modifications