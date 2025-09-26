# PORTX 2.0 Implementation Guide

## Development Environment Setup

### Prerequisites
- Windows 10/11 or Windows Server 2019+
- PowerShell Core 5.1+ (included in `packages/powershell-core/`)
- WSL, Cygwin, or MSYS2 for cross-platform testing
- Git for version control

### Directory Structure
```
PORTX/
├── portx.sh                 # Cross-platform entry point
├── portx.cmd                # Windows entry point
├── ps/
│   └── portx-import.ps1     # Core import engine
├── packages/                # Package repository
├── wrappers/               # Generated wrappers
│   ├── posix/              # Unix-style wrappers
│   └── windows/            # Windows wrappers
├── schema/
│   └── portx.schema.json   # Package validation schema
├── doc/                    # Documentation
├── logs/                   # Runtime logs
└── path/                   # PATH integration scripts
```

## Package Development

### Creating a New Package

1. **Create Package Directory**
```bash
mkdir packages/my-tool
cd packages/my-tool
```

2. **Add Executable(s)**
```bash
# Place your tool's executables
cp /path/to/my-tool.exe .
```

3. **Create Configuration**
```json
{
  "name": "my-tool",
  "version": "1.0.0",
  "description": "Description of my tool (minimum 10 characters)",
  "importType": "wrap",
  "bin": {
    "my-tool": {
      "path": "my-tool.exe",
      "description": "Main executable description",
      "usage": "my-tool [options] <args>",
      "dependencies": "windows"
    }
  },
  "tags": ["category", "tool", "utility", "portable", "command-line", "development"]
}
```

### Package Configuration Reference

#### Required Fields
- **`name`**: Package identifier (lowercase, alphanumeric with hyphens)
- **`version`**: Semantic version (major.minor.patch)
- **`description`**: Package description (minimum 10 characters)
- **`importType`**: Import strategy (`wrap`, `path`, `wrapAndPath`, `none`)

#### Import Types Explained

**`wrap`** (Recommended)
- Creates cross-platform wrappers
- Best for single executables
- Example: ripgrep, fd, helm

**`path`**
- Adds package directory to PATH
- Best for packages with multiple executables
- Example: node (includes npm, npx, etc.)

**`wrapAndPath`**
- Creates wrappers AND adds to PATH
- Maximum compatibility approach
- Example: complex toolchains

**`none`**
- Documentation packages only
- No executable imports
- Example: documentation, templates

#### Binary Configuration
```json
"bin": {
  "tool-name": {
    "path": "relative/path/from/package/root.exe",
    "description": "Tool description (minimum 10 chars)",
    "usage": "Usage examples and patterns",
    "dependencies": "windows|linux|cross-platform",
    "defaultArgs": "--option value"  // Optional
  }
}
```

#### Tags System
Minimum 6 tags required for categorization:
```json
"tags": [
  "primary-category",    // development, security, system
  "secondary-category",  // tool-type or functionality
  "language",           // rust, go, python, etc.
  "platform",          // windows, cross-platform
  "interface",          // cli, gui, api
  "domain"              // search, compression, etc.
]
```

### Package Validation

#### JSON Schema Validation
```bash
# Validate package configuration
powershell -Command "
  $schema = Get-Content schema/portx.schema.json | ConvertFrom-Json
  $config = Get-Content packages/my-tool/portx.json | ConvertFrom-Json
  # Validation logic runs automatically during import
"
```

#### Manual Validation Steps
1. **Syntax Check**: Valid JSON structure
2. **Schema Compliance**: All required fields present
3. **File References**: All executables exist at specified paths
4. **Naming Convention**: Package name follows pattern `^[a-z0-9]([a-z0-9-])*[a-z0-9]?$`

## Core Engine Implementation

### PowerShell Module Structure

#### Main Functions
```powershell
# Package Management
Import-PortxPackage         # Import single package
Invoke-PortxImport         # Import all packages
Test-PortxPackage          # Validate package

# Wrapper Generation
New-BashWrapper            # Create POSIX wrapper
New-CmdWrapper             # Create Windows wrapper
New-PowerShellWrapper      # Create PS1 wrapper (future)

# Validation
Test-WrapperIntegrity      # Verify wrapper contents
Test-WrapperPair           # Check wrapper pair exists

# Utilities
Write-PortxLog            # Structured logging
Write-SanitizedFile       # Cross-platform file writing
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