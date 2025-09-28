# PORTX Universal Wrapper Architecture

## System Overview

PORTX implements a high-performance Go-based wrapper system that provides seamless access to Windows tools from Unix-like environments. The architecture solves critical compatibility challenges including path conversion, TTY detection, and real-time I/O handling across WSL, MSYS2, Cygwin, and native Windows.

## Current Architecture (Go Wrapper Implementation)

### 1. Go Wrapper Core (`portx-wrap.exe`)

#### Primary Functions
- **Universal Tool Execution**: Single executable wraps 369 tools
- **Path Conversion**: Intelligent Unix↔Windows path transformation
- **Environment Detection**: Runtime platform identification
- **I/O Handling**: Direct I/O inheritance for TTY compatibility
- **Configuration Management**: Tool-specific behavior rules

#### Environment Detection Matrix
| Environment | Root Path | Detection Method | Status |
|-------------|-----------|------------------|---------|
| WSL | `/mnt/c/App/PORTX` | `$WSL_DISTRO_NAME` | ✅ Working |
| Cygwin | `/cygdrive/c/App/PORTX` | `$CYGWIN` or `cygpath` | ✅ Working |
| MSYS2/Git Bash | `/c/App/PORTX` | `$MSYSTEM` | ✅ Working |
| Native Windows | `C:\App\PORTX` | Go runtime detection | ✅ Working |

### 2. Configuration System (`go/config/`)

#### Tool Configuration (`tool-configs.json`)
- **Purpose**: Tool-specific behavior rules and exclusions
- **Format**: JSON configuration per tool
- **Features**: Parameter exclusion rules, output conversion settings
- **Management**: Centralized configuration for all 369 tools

#### Configuration Structure
```json
{
  "git": {
    "name": "git",
    "package": "git-extras",
    "windows_path": "git.exe",
    "exclusions": {
      "afterFlag": ["--grep", "--author"],
      "beforeFlag": [],
      "atPosition": [],
      "pattern": [".*\\.git.*"]
    }
  }
}
```

### 3. Package System

#### Package Structure
```
packages/
├── {package-name}/
│   ├── portx.json           # Package metadata (shell wrapper config)
│   ├── {executables}        # Windows executable binaries
│   └── {supporting-files}   # Dependencies and assets
```

#### Package Configuration (`portx.json`)
**Note**: Used by shell wrappers, not the Go wrapper. Go wrapper uses `tool-configs.json`.

```json
{
  "name": "node",
  "version": "22.19.0",
  "description": "Node.js JavaScript runtime",
  "importType": "path",
  "bin": {
    "node": {
      "path": "node.exe",
      "description": "Node.js runtime engine",
      "usage": "node app.js # Run JavaScript application"
    }
  }
}
```

#### Import Types (Shell Wrapper Legacy)
- **`wrap`**: Generate shell wrappers (not used by Go wrapper)
- **`path`**: Add to PATH (package directory scanning)
- **`wrapAndPath`**: Both approaches
- **`none`**: Documentation only

### 4. Go Wrapper Implementation

#### Core Components
```go
// Main execution flow
func ExecuteTool(wrapper *PortxWrapper, toolName string, args []string) error {
    // 1. Load tool configuration
    toolConfig := wrapper.Config.Tools[toolName]

    // 2. Build executable path
    executablePath := buildExecutablePath(toolConfig)

    // 3. Process arguments (path conversion)
    processedArgs := processArguments(args, toolConfig, wrapper.Config.PlatformEnv)

    // 4. Execute with direct I/O inheritance
    cmd := exec.Command(executablePath, processedArgs...)
    cmd.Stdin = os.Stdin   // Critical for TTY detection
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr

    return cmd.Run()
}
```

#### Critical I/O Handling
**Fixed Claude Code Bug (2025-09-27)**:
```go
// WORKING: Direct I/O inheritance
cmd.Stdin = os.Stdin
cmd.Stdout = os.Stdout
cmd.Stderr = os.Stderr
cmdErr := cmd.Run()

// BROKEN: Pipe-based I/O (breaks TTY detection)
// stdout, _ := cmd.StdoutPipe()
// stderr, _ := cmd.StderrPipe()
```

#### Path Conversion Logic
```go
func convertPath(arg string, platform PlatformEnvironment) string {
    if !isUnixAbsolutePath(arg) {
        return arg // No conversion needed
    }

    switch platform.Type {
    case "wsl":
        return convertWSLPath(arg)    // /mnt/c/... → C:\...
    case "msys2":
        return convertMSYS2Path(arg)  // /c/... → C:\...
    case "cygwin":
        return convertCygwinPath(arg) // /cygdrive/c/... → C:\...
    default:
        return arg
    }
}
```

## Advanced Features

### Intelligent Path Conversion

#### Problem Statement
Windows executables cannot process Unix-style paths (`/mnt/c/...`, `/c/...`), requiring automatic path translation while preserving regex patterns and command flags.

#### Current Implementation (Go Wrapper)
```go
func processArguments(args []string, toolConfig *ToolConfig, platform PlatformEnvironment) []string {
    processedArgs := make([]string, 0, len(args))

    for i, arg := range args {
        // Check exclusion rules
        if shouldExcludeFromConversion(arg, i, toolConfig.Exclusions) {
            processedArgs = append(processedArgs, arg)
            continue
        }

        // Apply path conversion if needed
        convertedArg := convertPathIfNeeded(arg, platform)
        processedArgs = append(processedArgs, convertedArg)
    }

    return processedArgs
}
```

#### Tool-Specific Rules
- **git**: Convert `--git-dir`, `--work-tree` embedded paths
- **ripgrep**: Convert paths but NEVER regex patterns
- **fd**: Convert search directories but preserve file patterns

### Structured Logging (Go Implementation)

#### Logging System
```go
// Using zap structured logger
logger.Info("Tool execution details",
    zap.String("tool", toolName),
    zap.String("executable", executablePath),
    zap.Strings("original_args", args),
    zap.Strings("processed_args", processedArgs),
    zap.String("platform", platform.Type))
```

#### Debug Mode
```bash
# Enable detailed logging
/c/App/PORTX/go/target/portx-wrap.exe --portxDebug node script.js
```

#### Log Output Format
```json
{"level":"info","timestamp":"2025-09-27T17:25:17.241+0300","caller":"go/wrapper.go:83","msg":"ExecuteTool called","tool":"node","args":["script.js"]}
```

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