# PORTX Go Wrapper Implementation Guide

## Development Environment Setup

### Prerequisites
- Windows 10/11 or Windows Server 2019+
- Go 1.19+ for building the wrapper
- WSL, Cygwin, or MSYS2 for cross-platform testing
- Git for version control

### Current Directory Structure
```
PORTX/
├── go/
│   ├── main.go             # Entry point and CLI handling
│   ├── wrapper.go          # Core wrapper logic
│   ├── config.go           # Configuration management
│   ├── platform.go         # Environment detection
│   ├── paths.go            # Path conversion utilities
│   ├── config/
│   │   └── tool-configs.json  # Tool configuration database
│   └── target/
│       └── portx-wrap.exe  # Compiled wrapper executable
├── packages/               # Tool packages (220 packages, 369 tools)
└── doc/                   # Documentation
```

## Go Wrapper Development

### Building the Wrapper

```bash
# Build the Go wrapper
cd go/
go build -o target/portx-wrap.exe .

# Test the wrapper
./target/portx-wrap.exe --help
./target/portx-wrap.exe --portxDebug git --version
```

### Core Implementation Files

#### `main.go` - Entry Point
```go
func main() {
    var portxDebug bool
    flag.BoolVar(&portxDebug, "portxDebug", false, "Enable debug logging")
    flag.Parse()

    // Initialize logger
    logger := initializeLogger(portxDebug)

    // Load configuration
    config, err := LoadConfig(logger)
    if err != nil {
        logger.Fatal("Failed to load configuration", zap.Error(err))
    }

    // Create wrapper and execute tool
    wrapper := &PortxWrapper{Config: config, Logger: logger}
    toolName := flag.Arg(0)
    args := flag.Args()[1:]

    err = ExecuteTool(wrapper, toolName, args)
    if err != nil {
        os.Exit(1)
    }
}
```

#### `wrapper.go` - Core Logic
```go
func ExecuteTool(wrapper *PortxWrapper, toolName string, args []string) error {
    // 1. Get tool configuration
    toolConfig, exists := wrapper.Config.Tools[toolName]
    if !exists {
        return fmt.Errorf("tool not found: %s", toolName)
    }

    // 2. Build executable path
    executablePath := filepath.Join(wrapper.Config.PortxRoot, "packages",
        toolConfig.Package, toolConfig.WindowsPath)

    // 3. Process arguments with path conversion
    processedArgs := processArguments(args, toolConfig, wrapper.Config.PlatformEnv)

    // 4. Execute with direct I/O inheritance (CRITICAL for TTY)
    cmd := exec.Command(executablePath, processedArgs...)
    cmd.Stdin = os.Stdin
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr

    return cmd.Run()
}
```

### Tool Configuration Management

#### Tool Configuration (`go/config/tool-configs.json`)
The Go wrapper uses a centralized configuration file for all tools:

```json
{
  "git": {
    "name": "git",
    "package": "git-extras",
    "windows_path": "git.exe",
    "exclusions": {
      "beforeFlag": [],
      "afterFlag": ["--grep", "--author", "--committer"],
      "atPosition": [],
      "pattern": [".*\\.git.*"]
    },
    "output_conversion": {
      "enabled": false,
      "type": "none",
      "patterns": []
    }
  },
  "rg": {
    "name": "rg",
    "package": "ripgrep",
    "windows_path": "rg.exe",
    "exclusions": {
      "beforeFlag": [],
      "afterFlag": ["--regexp", "--glob", "--type-add"],
      "atPosition": [0],
      "pattern": ["\\.", "\\*", "\\[", "\\]", "\\+", "\\?"]
    },
    "output_conversion": {
      "enabled": true,
      "type": "path_in_results",
      "patterns": ["C:\\\\([^:]+):(\\d+):(.*)"]
    }
  }
}
```

#### Configuration Fields
- **`name`**: Tool identifier (command name)
- **`package`**: Package directory name in `packages/`
- **`windows_path`**: Relative path to Windows executable
- **`exclusions`**: Rules for preventing path conversion
- **`output_conversion`**: Rules for converting tool output paths

#### Path Conversion Implementation

```go
// Path conversion logic in wrapper.go
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

func shouldExcludeFromConversion(arg string, position int, exclusions Exclusions) bool {
    // Check position-based exclusions
    for _, pos := range exclusions.AtPosition {
        if position == pos {
            return true
        }
    }

    // Check pattern-based exclusions (regex patterns)
    for _, pattern := range exclusions.Pattern {
        if matched, _ := regexp.MatchString(pattern, arg); matched {
            return true
        }
    }

    return false
}
```

### Testing and Validation

#### Testing the Go Wrapper
```bash
# Test specific tool
/c/App/PORTX/go/target/portx-wrap.exe --portxDebug git --version

# Test path conversion
/c/App/PORTX/go/target/portx-wrap.exe --portxDebug rg "pattern" /mnt/c/src/

# Test Claude Code (fixed TTY issue)
/c/App/PORTX/go/target/portx-wrap.exe node /c/App/PORTX/packages/node/node_modules/@anthropic-ai/claude-code/cli.js
```

#### Critical Test Cases
1. **TTY Detection**: Interactive tools (Claude Code, less, vim)
2. **Path Conversion**: Unix paths in arguments
3. **Regex Preservation**: Search patterns with metacharacters
4. **Environment Detection**: WSL, MSYS2, Cygwin compatibility

## Build and Deployment

### Building the Go Wrapper

#### Build Process
```bash
# Standard build
cd go/
go build -o target/portx-wrap.exe .

# Build with optimizations
go build -ldflags="-s -w" -o target/portx-wrap.exe .

# Cross-compilation (if needed)
GOOS=windows GOARCH=amd64 go build -o target/portx-wrap.exe .
```

#### Dependencies
```go
// go.mod
module portx-wrapper

go 1.19

require (
    go.uber.org/zap v1.24.0
    github.com/spf13/pflag v1.0.5
)
```

### Wrapper Generation Implementation

#### POSIX Wrapper Template
```bash
#!/bin/bash
# PORTX-WRAPPER: Auto-generated wrapper for {package}/{tool}

# Environment detection
if [[ -n "${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
    PORTX_ROOT="/mnt/c/App/PORTX"
elif [[ "$OSTYPE" == "cygwin" ]]; then
    PORTX_ROOT="/cygdrive/c/App/PORTX"
else
    PORTX_ROOT="/c/App/PORTX"
fi

PACKAGE_NAME="{package}"
EXE_RELATIVE_PATH="{path}"
EXECUTABLE_PATH="$PORTX_ROOT/packages/$PACKAGE_NAME/$EXE_RELATIVE_PATH"

# Optional: WSL path conversion
if [[ "$WSL_ENV" == "true" ]]; then
    # Path conversion logic for WSL-specific tools
fi

exec "$EXECUTABLE_PATH" "$@"
```

#### Windows Wrapper Template
```cmd
@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for {package}/{tool}
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME={package}
set EXE_RELATIVE_PATH={path}
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
```

### Environment Detection Logic

#### Cross-Platform Path Resolution
```powershell
function Get-PortxRoot {
    if ($env:WSL_DISTRO_NAME) {
        return "/mnt/c/App/PORTX"
    }
    elseif ($env:CYGWIN -or (Get-Command cygpath -ErrorAction SilentlyContinue)) {
        return "/cygdrive/c/App/PORTX"
    }
    elseif ($env:MSYSTEM) {
        return "/c/App/PORTX"
    }
    else {
        return "C:\App\PORTX"
    }
}
```

#### Platform Feature Detection
```powershell
$Script:IsWindowsPlatform = $PSVersionTable.Platform -eq "Win32NT" -or $null -eq $PSVersionTable.Platform
$Script:IsWSL = $env:WSL_DISTRO_NAME -ne $null
$Script:IsCygwin = $env:CYGWIN -ne $null
```

## Advanced Implementation Details

### WSL Path Conversion Enhancement

#### Implementation Strategy
```bash
# Function to detect Unix absolute paths
is_unix_absolute_path() {
    local arg="$1"
    if [[ "$arg" =~ ^/[^-] ]]; then
        return 0  # true - is absolute Unix path
    else
        return 1  # false - not absolute Unix path
    fi
}

# WSL path conversion wrapper extension
if [[ "$WSL_ENV" == "true" ]]; then
    args=()
    for arg in "$@"; do
        if is_unix_absolute_path "$arg"; then
            converted=$(wslpath -w "$arg" 2>/dev/null)
            if [[ $? -eq 0 && -n "$converted" ]]; then
                args+=("$converted")
            else
                args+=("$arg")  # fallback to original
            fi
        else
            args+=("$arg")  # pass through unchanged
        fi
    done
    exec "$EXECUTABLE_PATH" "${args[@]}"
else
    exec "$EXECUTABLE_PATH" "$@"
fi
```

#### Deployment Checklist
- [ ] Identify tools requiring path conversion
- [ ] Test with absolute paths: `/mnt/c/Work/project`
- [ ] Test with relative paths: `./file.txt`
- [ ] Test with options containing paths: `--exclude /pattern/`
- [ ] Test with mixed arguments: `tool /abs/path rel/path --opt`
- [ ] Verify fallback behavior on conversion failure

### Logging System Implementation

#### Log Level Configuration
```powershell
enum LogLevel {
    TRACE = 0
    DEBUG = 1
    INFO = 2
    WARN = 3
    ERROR = 4
    FATAL = 5
}

function Write-PortxLog {
    param(
        [string]$Message,
        [LogLevel]$Level = [LogLevel]::INFO,
        [string]$Category = "PORTX"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $logMessage = "$timestamp [$Level] $Category - $Message"

    # File logging (all levels)
    Add-Content -Path $Script:LogFile -Value $logMessage -Encoding UTF8

    # Console filtering
    switch ($Level) {
        ([LogLevel]::INFO) {
            if ($Message -match "(Processing:|Import completed|PATH cache)") {
                Write-Host $Message -ForegroundColor Cyan
            }
        }
        ([LogLevel]::WARN) { Write-Host "WARNING: $Message" -ForegroundColor Yellow }
        ([LogLevel]::ERROR) { Write-Host "ERROR: $Message" -ForegroundColor Red }
        ([LogLevel]::FATAL) { Write-Host "FATAL: $Message" -ForegroundColor Red -BackgroundColor Black }
    }
}
```

### Package Discovery and Processing

#### Package Enumeration
```powershell
function Get-PortxPackages {
    param([string]$PackageName = $null)

    if ($PackageName) {
        $packagePath = Join-Path $Script:PackagesDir $PackageName
        if (Test-Path $packagePath) {
            return @($packagePath)
        }
        else {
            throw "Package not found: $PackageName"
        }
    }
    else {
        return Get-ChildItem $Script:PackagesDir -Directory |
               Where-Object { Test-Path (Join-Path $_.FullName "portx.json") } |
               ForEach-Object { $_.FullName }
    }
}
```

#### Parallel Processing Support
```powershell
function Import-PortxPackages {
    param([string[]]$PackagePaths)

    $jobs = @()
    foreach ($packagePath in $PackagePaths) {
        $job = Start-Job -ScriptBlock {
            param($Path, $Functions)
            # Import functions into job context
            . $Functions
            Import-PortxPackage $Path
        } -ArgumentList $packagePath, $functionsScript
        $jobs += $job
    }

    # Wait for completion and collect results
    $results = $jobs | Wait-Job | Receive-Job
    $jobs | Remove-Job

    return $results
}
```

## Testing and Quality Assurance

### Unit Testing Framework

#### Package Validation Tests
```powershell
Describe "Package Validation" {
    Context "JSON Schema Compliance" {
        It "Should validate required fields" {
            $config = @{
                name = "test-tool"
                version = "1.0.0"
                description = "Test tool description"
                importType = "wrap"
            }
            Test-PortxPackage $config | Should -Be $true
        }

        It "Should reject invalid import types" {
            $config = @{
                importType = "invalid"
            }
            { Test-PortxPackage $config } | Should -Throw
        }
    }
}
```

#### Wrapper Generation Tests
```powershell
Describe "Wrapper Generation" {
    Context "Cross-Platform Compatibility" {
        It "Should generate POSIX wrapper" {
            New-BashWrapper -PackageName "test" -ToolName "tool" -ExecutablePath "tool.exe"
            $wrapperPath = Join-Path $Script:WrappersDir "posix/tool"
            Test-Path $wrapperPath | Should -Be $true
        }

        It "Should generate Windows wrapper" {
            New-CmdWrapper -PackageName "test" -ToolName "tool" -ExecutablePath "tool.exe"
            $wrapperPath = Join-Path $Script:WrappersDir "windows/tool.cmd"
            Test-Path $wrapperPath | Should -Be $true
        }
    }
}
```

### Integration Testing

#### End-to-End Import Test
```bash
#!/bin/bash
# Test complete import workflow

# Clean environment
rm -rf wrappers/ logs/

# Import test package
./portx.sh import test-package

# Verify wrapper creation
test -f wrappers/posix/test-tool
test -f wrappers/windows/test-tool.cmd

# Verify wrapper execution
wrappers/posix/test-tool --version
```

#### Cross-Platform Validation
```bash
# Test on multiple environments
environments=("wsl" "cygwin" "msys2" "powershell")

for env in "${environments[@]}"; do
    echo "Testing in $env environment..."
    case $env in
        "wsl")
            wsl -d Ubuntu ./portx.sh import git
            wsl -d Ubuntu wrappers/posix/git --version
            ;;
        "cygwin")
            # Cygwin-specific testing
            ;;
        # Additional environment tests
    esac
done
```

## Performance Optimization

### Wrapper Execution Optimization
```bash
# Use exec to replace shell process (faster startup)
exec "$EXECUTABLE_PATH" "$@"

# Instead of subshell invocation
# "$EXECUTABLE_PATH" "$@"
```

### File I/O Optimization
```powershell
# Batch file operations
$wrappers = @()
foreach ($tool in $tools) {
    $wrappers += New-WrapperContent -Tool $tool
}

# Single write operation
$wrappers | Out-File -Path $outputFile -Encoding UTF8
```

### Memory Management
```powershell
# Explicit cleanup for large operations
$largeDataSet = Get-LargeData
try {
    Process-Data $largeDataSet
}
finally {
    $largeDataSet = $null
    [System.GC]::Collect()
}
```

## Deployment and Distribution

### Package Distribution Strategy
1. **Local Development**: Direct directory structure
2. **CI/CD Integration**: Automated package validation
3. **Version Control**: Git-based package management
4. **Artifact Distribution**: Compressed package bundles

### Continuous Integration
```yaml
# Example GitHub Actions workflow
name: PORTX Package Validation
on: [push, pull_request]

jobs:
  validate:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v2

      - name: Validate Package Schema
        run: |
          $packages = Get-ChildItem packages -Directory
          foreach ($pkg in $packages) {
            $configPath = Join-Path $pkg.FullName "portx.json"
            if (Test-Path $configPath) {
              # Schema validation logic
            }
          }
        shell: powershell

      - name: Test Package Import
        run: |
          ./portx.cmd import test-package
          Test-Path wrappers/posix/test-tool
```

### Production Deployment Checklist
- [ ] All packages validate against schema
- [ ] Wrapper generation tested across platforms
- [ ] Logging configuration appropriate for environment
- [ ] PATH integration verified
- [ ] Performance benchmarks within acceptable range
- [ ] Security review completed
- [ ] Documentation updated
- [ ] Backup and rollback procedures verified

## Troubleshooting and Debugging

### Common Issues and Solutions

#### Package Import Failures
```powershell
# Debug package validation
$VerbosePreference = "Continue"
Test-PortxPackage "packages/problematic-package"

# Check logs
Get-Content "logs/portx-import.log" | Select-String "ERROR|FATAL"
```

#### Wrapper Execution Issues
```bash
# Debug wrapper with verbose output
bash -x wrappers/posix/tool-name --version

# Check environment detection
echo "PORTX_ROOT: $PORTX_ROOT"
echo "WSL_DISTRO_NAME: $WSL_DISTRO_NAME"
echo "OSTYPE: $OSTYPE"
```

#### Path Conversion Problems
```bash
# Test path conversion manually
wslpath -w "/mnt/c/Work/project"

# Debug WSL environment
grep -qi microsoft /proc/version && echo "WSL detected"
```

### Diagnostic Tools
```powershell
# System diagnostic function
function Get-PortxDiagnostics {
    $diagnostics = @{
        PSVersion = $PSVersionTable.PSVersion
        Platform = $PSVersionTable.Platform
        PortxRoot = $Script:PortxRoot
        PackageCount = (Get-ChildItem $Script:PackagesDir -Directory).Count
        WrapperCount = @{
            Posix = (Get-ChildItem (Join-Path $Script:WrappersDir "posix") -ErrorAction SilentlyContinue).Count
            Windows = (Get-ChildItem (Join-Path $Script:WrappersDir "windows") -ErrorAction SilentlyContinue).Count
        }
    }
    return $diagnostics | ConvertTo-Json -Depth 3
}
```

## Extension and Customization

### Custom Import Types
```powershell
# Extend import type handling
function Import-CustomPackage {
    param($PackagePath, $CustomType)

    switch ($CustomType) {
        "container" {
            # Container-specific import logic
        }
        "service" {
            # Service installation logic
        }
        default {
            # Standard import fallback
            Import-PortxPackage $PackagePath
        }
    }
}
```

### Wrapper Templates
```powershell
# Custom wrapper generation
function New-CustomWrapper {
    param($TemplateName, $PackageConfig)

    $templatePath = "templates/$TemplateName.template"
    $template = Get-Content $templatePath -Raw

    # Template variable substitution
    $wrapper = $template -replace '\{package\}', $PackageConfig.name
    $wrapper = $wrapper -replace '\{tool\}', $ToolName

    return $wrapper
}
```

This implementation guide provides comprehensive technical details for developing, testing, and extending the PORTX 2.0 system while maintaining its cross-platform compatibility and performance characteristics.