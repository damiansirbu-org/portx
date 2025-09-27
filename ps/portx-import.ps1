#Requires -Version 5.1

<#
.SYNOPSIS
PORTX 2.0 Package Import Manager - PowerShell Core Edition

.DESCRIPTION
Lightweight, dependency-free package importer for PORTX universal toolchain.
Replaces bash-based portx.sh with native PowerShell functionality.
Works identically on Windows, Linux containers, WSL, Cygwin, and CI/CD.

.PARAMETER PackageName
Import specific package by name. If not specified, imports all packages.

.PARAMETER Force
Force reimport even if package already imported.

.PARAMETER WhatIf
Show what would be imported without actually doing it.

.EXAMPLE
.\portx-import.ps1
Import all packages

.EXAMPLE
.\portx-import.ps1 -PackageName "git"
Import only the git package

.EXAMPLE
.\portx-import.ps1 -WhatIf
Preview import actions
#>

[CmdletBinding(SupportsShouldProcess)]
param(
    [string]$PackageName,
    [switch]$Clean
)

# ============================================================================
# CONFIGURATION & CONSTANTS
# ============================================================================

# PORTX root directory detection
$Script:PortxRoot = Split-Path -Parent $PSScriptRoot
$Script:PackagesDir = Join-Path $PortxRoot "packages"
$Script:WrappersDir = Join-Path $PortxRoot "wrappers"
$Script:LogsDir = Join-Path $PortxRoot "logs"

# Track PATH packages across functions
$Script:PathPackages = @()

# Environment detection - use different variable names to avoid conflicts
$Script:IsWindowsPlatform = $PSVersionTable.Platform -eq "Win32NT" -or $null -eq $PSVersionTable.Platform
$Script:IsWSL = $env:WSL_DISTRO_NAME -ne $null
$Script:IsCygwin = $env:CYGWIN -ne $null

# Logging configuration
$Script:LogFile = Join-Path $Script:LogsDir "portx-import.log"
$Script:VerboseLogging = $VerbosePreference -eq "Continue"

# ============================================================================
# LOGGING FUNCTIONS
# ============================================================================

function Write-PortxLog {
    param(
        [string]$Message,
        [ValidateSet("TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL")]
        [string]$Level = "INFO",
        [string]$Category = "PORTX"
    )

    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $logMessage = "$timestamp [$Level] $Category - $Message"

    # Always write detailed log to file
    if (-not (Test-Path $Script:LogsDir)) {
        New-Item -ItemType Directory -Path $Script:LogsDir -Force | Out-Null
    }
    try {
        Add-Content -Path $Script:LogFile -Value $logMessage -Encoding UTF8
    } catch {
        Write-Host "[LOG ERROR] Could not write to log file: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Console output - only important messages
    switch ($Level) {
        "INFO"  { if ($Message -match "(Processing:|Import completed|PATH cache|Created \d+ wrappers)") { Write-Host $Message -ForegroundColor Cyan } }
        "WARN"  { Write-Host "WARNING: $Message" -ForegroundColor Yellow }
        "ERROR" { Write-Host "ERROR: $Message" -ForegroundColor Red }
        "FATAL" { Write-Host "FATAL: $Message" -ForegroundColor Red -BackgroundColor Black }
        # DEBUG and TRACE only go to file, not console
    }
}

# Log4j style convenience functions
function Write-PortxTrace { param([string]$Message, [string]$Category = "PORTX") Write-PortxLog $Message "TRACE" $Category }
function Write-PortxDebug { param([string]$Message, [string]$Category = "PORTX") Write-PortxLog $Message "DEBUG" $Category }
function Write-PortxInfo { param([string]$Message, [string]$Category = "PORTX") Write-PortxLog $Message "INFO" $Category }
function Write-PortxWarn { param([string]$Message, [string]$Category = "PORTX") Write-PortxLog $Message "WARN" $Category }
function Write-PortxError { param([string]$Message, [string]$Category = "PORTX") Write-PortxLog $Message "ERROR" $Category }
function Write-PortxFatal { param([string]$Message, [string]$Category = "PORTX") Write-PortxLog $Message "FATAL" $Category }

# Legacy compatibility
function Write-PortxSuccess { param([string]$Message) Write-PortxInfo $Message }
function Write-PortxWarning { param([string]$Message) Write-PortxWarn $Message }

# ============================================================================
# FILE SANITIZATION UTILITIES
# ============================================================================

function Write-SanitizedFile {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,
        [Parameter(Mandatory)]
        [string]$Content
    )

    Write-PortxDebug "Sanitizing file: $FilePath" "SANITIZE"

    # Ensure directory exists
    $fileDir = Split-Path -Path $FilePath -Parent
    if (-not (Test-Path -Path $fileDir)) {
        New-Item -ItemType Directory -Path $fileDir -Force | Out-Null
    }

    # Force Unix line endings by writing bytes directly
    $contentUnix = $Content -replace "`r`n", "`n" -replace "`r", "`n"
    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    $bytes = $utf8NoBom.GetBytes($contentUnix)
    [System.IO.File]::WriteAllBytes($FilePath, $bytes)

    Write-PortxDebug "File sanitized: $FilePath" "SANITIZE"
}

# ============================================================================
# WRAPPER VALIDATION
# ============================================================================

function Test-WrapperIntegrity {
    param(
        [string]$WrapperPath,
        [string]$ExpectedExecutable
    )

    Write-PortxDebug "Validating wrapper: $WrapperPath" "VALIDATION"

    if (-not (Test-Path $WrapperPath)) {
        Write-PortxError "Wrapper not found: $WrapperPath" "VALIDATION"
        return $false
    }

    try {
        $content = Get-Content $WrapperPath -Raw

        # Check if wrapper contains expected executable reference
        if (-not ($content -match [regex]::Escape($ExpectedExecutable))) {
            Write-PortxError "Wrapper does not reference expected executable: $ExpectedExecutable" "VALIDATION"
            return $false
        }

        # Check for basic wrapper structure
        if ($WrapperPath -match "\.cmd$") {
            # CMD wrapper validation
            if (-not ($content -match "@echo off" -and $content -match "REM PORTX")) {
                Write-PortxError "Invalid CMD wrapper structure: $WrapperPath" "VALIDATION"
                return $false
            }
        } else {
            # Bash wrapper validation
            if (-not ($content -match "#!/bin/bash" -and $content -match "# PORTX")) {
                Write-PortxError "Invalid bash wrapper structure: $WrapperPath" "VALIDATION"
                return $false
            }
        }

        Write-PortxDebug "Wrapper validation passed: $WrapperPath" "VALIDATION"
        return $true

    } catch {
        Write-PortxError "Error validating wrapper $WrapperPath`: $($_.Exception.Message)" "VALIDATION"
        return $false
    }
}

function Test-WrapperPair {
    param(
        [string]$ToolName,
        [string]$PackageName
    )

    $posixWrapper = Join-Path $Script:PosixDir $ToolName
    $windowsWrapper = Join-Path $Script:WindowsDir "$ToolName.cmd"

    $posixValid = Test-Path $posixWrapper
    $windowsValid = Test-Path $windowsWrapper

    if (-not $posixValid) {
        Write-PortxError "Missing POSIX wrapper for $ToolName in package $PackageName" "VALIDATION"
    }

    if (-not $windowsValid) {
        Write-PortxError "Missing Windows wrapper for $ToolName in package $PackageName" "VALIDATION"
    }

    return ($posixValid -and $windowsValid)
}

# ============================================================================
# PACKAGE VALIDATION
# ============================================================================

function Test-PortxPackage {
    param([string]$PackagePath)

    $packageName = Split-Path -Leaf $PackagePath
    $configPath = Join-Path $PackagePath "portx.json"

    Write-PortxDebug "Validating package: $packageName"

    # Check if portx.json exists
    if (-not (Test-Path $configPath)) {
        Write-PortxError "Missing portx.json for package: $packageName"
        return $false
    }

    # Parse and validate JSON
    try {
        $config = Get-Content $configPath -Raw | ConvertFrom-Json
    }
    catch {
        Write-PortxError "Invalid JSON in $configPath`: $($_.Exception.Message)"
        return $false
    }

    # Validate required fields
    if (-not $config.name) {
        Write-PortxError "Package $packageName missing required 'name' field"
        return $false
    }

    # Validate package contents based on import type
    $importType = Get-ImportType $config

    if (-not $config.bin -and -not $config.tools) {
        if ($importType -eq "wrap" -or $importType -eq "wrapAndPath") {
            Write-PortxWarning "Package $packageName has no executables (documentation package?)"
        }

        # For path-type packages, validate that packagePaths exist
        if ($importType -eq "path" -or $importType -eq "wrapAndPath") {
            if ($config.packagePaths) {
                $missingPaths = @()
                foreach ($relativePath in $config.packagePaths) {
                    $fullPath = Join-Path $PackagePath $relativePath
                    if (-not (Test-Path $fullPath)) {
                        $missingPaths += $relativePath
                    }
                }

                if ($missingPaths.Count -gt 0) {
                    Write-PortxError "Package $packageName missing required paths: $($missingPaths -join ', ')"
                    return $false
                }
            }
        }

        return $true
    }

    # Validate executables exist
    $missingExecutables = @()

    if ($config.bin) {
        foreach ($toolName in $config.bin.PSObject.Properties.Name) {
            $toolConfig = $config.bin.$toolName
            $exePath = Join-Path $PackagePath $toolConfig.path

            if (-not (Test-Path $exePath)) {
                $missingExecutables += $toolConfig.path
            }
        }
    }

    if ($missingExecutables.Count -gt 0) {
        Write-PortxError "Package $packageName missing executables: $($missingExecutables -join ', ')"
        return $false
    }

    Write-PortxDebug "Package $packageName validation passed"
    return $true
}

# ============================================================================
# WRAPPER GENERATION
# ============================================================================

function Get-ImportType {
    param([PSObject]$Config)

    $importType = $Config.importType
    if (-not $importType) { return "auto" }

    switch ($importType) {
        "wrap" { return "wrap" }
        "path" { return "path" }
        "none" { return "none" }
        "wrapAndPath" { return "wrapAndPath" }
        default { return "auto" }
    }
}

function New-BashWrapper {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [string]$ToolName,
        [Parameter(Mandatory)]
        [string]$ExecutablePath,
        [string]$DefaultArgs = ""
    )

    Write-PortxDebug "New-BashWrapper called with PackageName='$PackageName', ToolName='$ToolName', ExecutablePath='$ExecutablePath', DefaultArgs='$DefaultArgs'"

    $wrapperPath = Join-Path -Path $Script:WrappersDir -ChildPath "posix" | Join-Path -ChildPath $ToolName
    $wrapperDir = Split-Path -Path $wrapperPath -Parent

    if (-not (Test-Path -Path $wrapperDir)) {
        New-Item -ItemType Directory -Path $wrapperDir -Force | Out-Null
    }

    # Generate enhanced cross-platform bash wrapper with universal path conversion and debug support
    $wrapperContent = @"
#!/bin/bash
# PORTX-WRAPPER: Auto-generated enhanced wrapper for $PackageName/$ToolName
# Universal path conversion for WSL/Cygwin/MSYS2 + --portxDebug support

# Universal environment detection using uname -sr (clean and reliable)
uname_output="`$(uname -sr)"
case "`$uname_output" in
    [Ll]inux*[Mm]icrosoft*)
        PORTX_ROOT="/mnt/c/App/PORTX"
        PORTX_ENV="WSL"
        ;;
    [Mm][Ii][Nn][Gg][Ww]*|[Mm][Ss][Yy][Ss]*)
        PORTX_ROOT="/c/App/PORTX"
        PORTX_ENV="MSYS2"
        ;;
    [Cc][Yy][Gg][Ww][Ii][Nn]*)
        PORTX_ROOT="/cygdrive/c/App/PORTX"
        PORTX_ENV="CYGWIN"
        ;;
    *)
        PORTX_ROOT="/c/App/PORTX"
        PORTX_ENV="UNKNOWN"
        ;;
esac

# Package configuration
PORTX_PACKAGE="$PackageName"
PORTX_TOOL="$ToolName"
PORTX_EXE_PATH="$ExecutablePath"
PORTX_EXECUTABLE="`$PORTX_ROOT/packages/`$PORTX_PACKAGE/`$PORTX_EXE_PATH"

# Universal path conversion function
convert_unix_path() {
    local path="`$1"
    case "`$PORTX_ENV" in
        "WSL")
            if command -v wslpath >/dev/null 2>&1; then
                wslpath -w "`$path" 2>/dev/null || echo "`$path"
            else
                echo "`$path"
            fi
            ;;
        "CYGWIN")
            if command -v cygpath >/dev/null 2>&1; then
                cygpath -w "`$path" 2>/dev/null || echo "`$path"
            else
                echo "`$path"
            fi
            ;;
        "MSYS2")
            # Convert /c/path to C:\path, /d/path to D:\path, etc.
            echo "`$path" | sed 's|^/\([a-zA-Z]\)/|\U\1:/|g; s|/|\\|g' 2>/dev/null || echo "`$path"
            ;;
        *)
            echo "`$path"
            ;;
    esac
}

# Unix absolute path detection
is_unix_absolute_path() {
    [[ "`$1" =~ ^/(mnt|cygdrive|[a-zA-Z]|home|usr|var|tmp|opt|root|bin|sbin|lib|etc|dev|proc|sys)(/.*|`$) ]]
}

# Debug mode and argument processing
PORTX_DEBUG=false
PORTX_ORIGINAL_ARGS=("`$@")
PORTX_PROCESSED_ARGS=()

# Extract --portxDebug and build processed args
for arg in "`$@"; do
    if [[ "`$arg" == "--portxDebug" ]]; then
        PORTX_DEBUG=true
    else
        PORTX_PROCESSED_ARGS+=("`$arg")
    fi
done

# Path conversion processing
PORTX_FINAL_ARGS=()
if [[ "`$PORTX_ENV" != "UNKNOWN" ]]; then
    for arg in "`${PORTX_PROCESSED_ARGS[@]}"; do
        if is_unix_absolute_path "`$arg"; then
            converted=`$(convert_unix_path "`$arg")
            PORTX_FINAL_ARGS+=("`$converted")
        else
            PORTX_FINAL_ARGS+=("`$arg")
        fi
    done
else
    PORTX_FINAL_ARGS=("`${PORTX_PROCESSED_ARGS[@]}")
fi

# Add default arguments if specified
if [[ -n "$DefaultArgs" ]]; then
    # Insert default args at the beginning of final args
    PORTX_DEFAULT_ARGS=($DefaultArgs)
    PORTX_FINAL_ARGS=("`${PORTX_DEFAULT_ARGS[@]}" "`${PORTX_FINAL_ARGS[@]}")
fi

# Debug output
if [[ "`$PORTX_DEBUG" == "true" ]]; then
    echo "uname_output: `$uname_output"
    echo "PORTX_ENV: `$PORTX_ENV"
    echo "PORTX_ROOT: `$PORTX_ROOT"
    echo "WSL_DISTRO_NAME: `${WSL_DISTRO_NAME:-unset}"
    echo "WSLENV: `${WSLENV:-unset}"
    echo "WSL_INTEROP: `${WSL_INTEROP:-unset}"
    echo "MSYSTEM: `${MSYSTEM:-unset}"
    echo "MSYSTEM_CARCH: `${MSYSTEM_CARCH:-unset}"
    echo "MSYSTEM_PREFIX: `${MSYSTEM_PREFIX:-unset}"
    echo "CYGWIN: `${CYGWIN:-unset}"
    echo "OSTYPE: `${OSTYPE:-unset}"
    echo "HOSTTYPE: `${HOSTTYPE:-unset}"
    echo "SHELL: `${SHELL:-unset}"
    echo "TERM: `${TERM:-unset}"
    echo "DISPLAY: `${DISPLAY:-unset}"
    echo "USER: `${USER:-unset}"
    echo "USERNAME: `${USERNAME:-unset}"
    echo "PWD: `${PWD:-unset}"
    echo "PORTX_PACKAGE: `$PORTX_PACKAGE"
    echo "PORTX_TOOL: `$PORTX_TOOL"
    echo "PORTX_EXECUTABLE: `$PORTX_EXECUTABLE"
    echo "PORTX_ORIGINAL_ARGS: `${PORTX_ORIGINAL_ARGS[*]}"
    echo "PORTX_PROCESSED_ARGS: `${PORTX_PROCESSED_ARGS[*]}"
    echo "PORTX_FINAL_ARGS: `${PORTX_FINAL_ARGS[*]}"
    if [[ "`$PORTX_ENV" != "UNKNOWN" ]]; then
        conversion_count=0
        for i in "`${!PORTX_PROCESSED_ARGS[@]}"; do
            if is_unix_absolute_path "`${PORTX_PROCESSED_ARGS[i]}"; then
                echo "PATH_CONVERSION_`$i: '`${PORTX_PROCESSED_ARGS[i]}' -> '`${PORTX_FINAL_ARGS[i]}'"
                ((conversion_count++))
            fi
        done
        [[ `$conversion_count -eq 0 ]] && echo "PATH_CONVERSIONS: none"
    else
        echo "PATH_CONVERSIONS: skipped"
    fi
    echo "FINAL_COMMAND: `$PORTX_EXECUTABLE `${PORTX_FINAL_ARGS[*]}"
fi

# Execute the tool with processed arguments
exec "`$PORTX_EXECUTABLE" "`${PORTX_FINAL_ARGS[@]}"
"@

    # Use sanitized file writing to ensure proper line endings
    Write-SanitizedFile -FilePath $wrapperPath -Content $wrapperContent

    # Make executable on Unix systems
    if (-not $Script:IsWindowsPlatform) {
        try {
            & chmod +x $wrapperPath
        } catch {
            Write-PortxWarn "Could not set executable permission on $wrapperPath"
        }
    }

    Write-PortxDebug "Created enhanced bash wrapper: $wrapperPath"
}

function New-CmdWrapper {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [string]$ToolName,
        [Parameter(Mandatory)]
        [string]$ExecutablePath,
        [string]$DefaultArgs = ""
    )

    Write-PortxDebug "New-CmdWrapper called with PackageName='$PackageName', ToolName='$ToolName', ExecutablePath='$ExecutablePath', DefaultArgs='$DefaultArgs'"

    $wrapperPath = Join-Path -Path $Script:WrappersDir -ChildPath "windows" | Join-Path -ChildPath "$ToolName.cmd"
    $wrapperDir = Split-Path -Path $wrapperPath -Parent

    if (-not (Test-Path -Path $wrapperDir)) {
        New-Item -ItemType Directory -Path $wrapperDir -Force | Out-Null
    }

    # Generate Windows CMD wrapper with variables (bash style)
    if ($DefaultArgs) {
        $wrapperContent = @"
@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for $PackageName/$ToolName with defaultArgs
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=$PackageName
set EXE_RELATIVE_PATH=$ExecutablePath
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" $DefaultArgs %*
"@
    } else {
        $wrapperContent = @"
@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for $PackageName/$ToolName
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=$PackageName
set EXE_RELATIVE_PATH=$ExecutablePath
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
"@
    }

    Set-Content -Path $wrapperPath -Value $wrapperContent -Encoding ASCII
    Write-PortxDebug "Created CMD wrapper: $wrapperPath"
}

function New-PowerShellWrapper {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [string]$ToolName,
        [Parameter(Mandatory)]
        [string]$ExecutablePath,
        [string]$DefaultArgs = ""
    )

    Write-PortxDebug "New-PowerShellWrapper called with PackageName='$PackageName', ToolName='$ToolName', ExecutablePath='$ExecutablePath', DefaultArgs='$DefaultArgs'"

    $wrapperPath = Join-Path -Path $Script:WrappersDir -ChildPath "windows" | Join-Path -ChildPath "$ToolName.ps1"
    $wrapperDir = Split-Path -Path $wrapperPath -Parent

    if (-not (Test-Path -Path $wrapperDir)) {
        New-Item -ItemType Directory -Path $wrapperDir -Force | Out-Null
    }

    # Generate cross-platform PowerShell wrapper
    if ($DefaultArgs) {
        $wrapperContent = @"
# PORTX-WRAPPER: Auto-generated wrapper for $PackageName/$ToolName
`$PortxRoot = if (`$env:WSL_DISTRO_NAME) { "/mnt/c/App/PORTX" } elseif (`$env:CYGWIN) { "/cygdrive/c/App/PORTX" } else { "C:\App\PORTX" }
`$ExecutablePath = Join-Path `$PortxRoot "packages\$PackageName\$ExecutablePath"
`$DefaultArgs = "$DefaultArgs" -split " "
& `$ExecutablePath @DefaultArgs @args
"@
    } else {
        $wrapperContent = @"
# PORTX-WRAPPER: Auto-generated wrapper for $PackageName/$ToolName
`$PortxRoot = if (`$env:WSL_DISTRO_NAME) { "/mnt/c/App/PORTX" } elseif (`$env:CYGWIN) { "/cygdrive/c/App/PORTX" } else { "C:\App\PORTX" }
`$ExecutablePath = Join-Path `$PortxRoot "packages\$PackageName\$ExecutablePath"
& `$ExecutablePath @args
"@
    }

    # Use sanitized file writing to ensure proper line endings
    Write-SanitizedFile -FilePath $wrapperPath -Content $wrapperContent
    Write-PortxDebug "Created PowerShell wrapper: $wrapperPath"
}

function New-GoWrapper {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [string]$ToolName,
        [Parameter(Mandatory)]
        [string]$ExecutablePath,
        [string]$DefaultArgs = ""
    )

    Write-PortxDebug "New-GoWrapper called with PackageName='$PackageName', ToolName='$ToolName', ExecutablePath='$ExecutablePath', DefaultArgs='$DefaultArgs'"

    $goWrapperDir = Join-Path -Path $Script:WrappersDir -ChildPath "go"
    $wrapperExePath = Join-Path $goWrapperDir "$ToolName.exe"
    $goSourcePath = Join-Path $goWrapperDir "$ToolName.go"

    if (-not (Test-Path -Path $goWrapperDir)) {
        New-Item -ItemType Directory -Path $goWrapperDir -Force | Out-Null
    }

    # Generate Go source for individual tool wrapper
    $goSource = @"
package main

import (
    "fmt"
    "os"
    "os/exec"
    "path/filepath"
    "runtime"
    "strings"
)

func main() {
    // Package configuration
    packageName := "$PackageName"
    toolName := "$ToolName"
    executablePath := "$ExecutablePath"
    defaultArgs := "$DefaultArgs"

    // Environment detection
    var portxRoot string
    if runtime.GOOS == "windows" {
        portxRoot = "C:\\App\\PORTX"
    } else {
        // WSL/Unix environments
        portxRoot = "/mnt/c/App/PORTX"
    }

    // Build full executable path
    fullExePath := filepath.Join(portxRoot, "packages", packageName, executablePath)

    // Process arguments
    args := os.Args[1:]
    debugMode := false

    // Extract --portxDebug
    filteredArgs := make([]string, 0, len(args))
    for _, arg := range args {
        if arg == "--portxDebug" {
            debugMode = true
        } else {
            filteredArgs = append(filteredArgs, arg)
        }
    }

    // Add default args if specified
    var finalArgs []string
    if defaultArgs != "" {
        defaultArgsList := strings.Fields(defaultArgs)
        finalArgs = append(defaultArgsList, filteredArgs...)
    } else {
        finalArgs = filteredArgs
    }

    // Debug output
    if debugMode {
        fmt.Fprintf(os.Stderr, "[PORTX DEBUG] Tool: %s\n", toolName)
        fmt.Fprintf(os.Stderr, "[PORTX DEBUG] Package: %s\n", packageName)
        fmt.Fprintf(os.Stderr, "[PORTX DEBUG] Executable: %s\n", fullExePath)
        fmt.Fprintf(os.Stderr, "[PORTX DEBUG] Arguments: %v\n", finalArgs)
        fmt.Fprintf(os.Stderr, "[PORTX DEBUG] GOOS: %s\n", runtime.GOOS)
        fmt.Fprintf(os.Stderr, "[PORTX DEBUG] GOARCH: %s\n", runtime.GOARCH)
    }

    // Execute the tool
    cmd := exec.Command(fullExePath, finalArgs...)
    cmd.Stdin = os.Stdin
    cmd.Stdout = os.Stdout
    cmd.Stderr = os.Stderr

    if err := cmd.Run(); err != nil {
        if exitError, ok := err.(*exec.ExitError); ok {
            os.Exit(exitError.ExitCode())
        }
        fmt.Fprintf(os.Stderr, "Error executing %s: %v\n", toolName, err)
        os.Exit(1)
    }
}
"@

    # Write Go source
    Write-SanitizedFile -FilePath $goSourcePath -Content $goSource

    # Build the Go executable
    $goExe = Join-Path $Script:PortxRoot "packages\go\bin\go.exe"
    if (-not (Test-Path $goExe)) {
        Write-PortxError "Go compiler not found at $goExe"
        return $false
    }

    try {
        $buildArgs = @("build", "-o", $wrapperExePath, $goSourcePath)
        Write-PortxDebug "Building Go wrapper: $goExe $($buildArgs -join ' ')"

        $process = Start-Process -FilePath $goExe -ArgumentList $buildArgs -Wait -PassThru -WindowStyle Hidden
        if ($process.ExitCode -ne 0) {
            Write-PortxError "Go build failed for $ToolName with exit code $($process.ExitCode)"
            return $false
        }

        # Remove source file after successful build
        Remove-Item $goSourcePath -Force

        # Also create no-extension version for WSL/Unix
        $noExtensionPath = Join-Path $goWrapperDir $ToolName
        try {
            Copy-Item $wrapperExePath $noExtensionPath -Force
            Write-PortxDebug "Created Go wrapper (no extension): $noExtensionPath"
        }
        catch {
            Write-PortxWarn "Failed to create no-extension wrapper for $ToolName`: $($_.Exception.Message)"
        }

        Write-PortxDebug "Created Go wrapper: $wrapperExePath"
        return $true
    }
    catch {
        Write-PortxError "Failed to build Go wrapper for $ToolName`: $($_.Exception.Message)"
        return $false
    }
}

# ============================================================================
# UNIVERSAL GO WRAPPER FUNCTIONS
# ============================================================================

# Global variable to track if universal wrapper is built
$Script:UniversalWrapperBuilt = $false

function Build-UniversalGoWrapper {
    param()

    if ($Script:UniversalWrapperBuilt) {
        return $true
    }

    Write-PortxInfo "Building universal PORTX Go wrapper..."

    $goDir = Join-Path $Script:PortxRoot "go"
    $goExe = Join-Path $Script:PortxRoot "packages\go\bin\go.exe"
    $goWrapperDir = Join-Path $Script:WrappersDir "go"
    $universalWrapperPath = Join-Path $goDir "target\portx-wrap.exe"

    # Ensure go wrapper directory exists
    if (-not (Test-Path $goWrapperDir)) {
        New-Item -ItemType Directory -Path $goWrapperDir -Force | Out-Null
    }

    if (-not (Test-Path $goExe)) {
        Write-PortxError "Go compiler not found at $goExe"
        return $false
    }

    if (-not (Test-Path $goDir)) {
        Write-PortxError "Go source directory not found at $goDir"
        return $false
    }

    try {
        # Build the universal wrapper directly with Go
        $buildArgs = @("build", "-o", $universalWrapperPath, ".")
        Write-PortxDebug "Building universal wrapper: $goExe with args: $($buildArgs -join ', ') (from directory: $goDir)"

        # Capture stdout and stderr for better error reporting
        $processInfo = New-Object System.Diagnostics.ProcessStartInfo
        $processInfo.FileName = $goExe
        foreach ($arg in $buildArgs) {
            $processInfo.ArgumentList.Add($arg)
        }
        $processInfo.WorkingDirectory = $goDir
        $processInfo.RedirectStandardOutput = $true
        $processInfo.RedirectStandardError = $true
        $processInfo.UseShellExecute = $false
        $processInfo.CreateNoWindow = $true

        $process = New-Object System.Diagnostics.Process
        $process.StartInfo = $processInfo
        $process.Start() | Out-Null

        $stdout = $process.StandardOutput.ReadToEnd()
        $stderr = $process.StandardError.ReadToEnd()
        $process.WaitForExit()

        if ($process.ExitCode -ne 0) {
            Write-PortxError "Universal wrapper build failed with exit code $($process.ExitCode)"
            if ($stderr) { Write-PortxError "Build stderr: $stderr" }
            if ($stdout) { Write-PortxError "Build stdout: $stdout" }
            return $false
        }

        if ($stdout -and $Script:VerboseLogging) {
            Write-PortxDebug "Build stdout: $stdout"
        }

        # Copy config directory to wrapper location
        $sourceConfigDir = Join-Path $goDir "config"
        $targetConfigDir = Join-Path $goWrapperDir "config"

        if (Test-Path $sourceConfigDir) {
            if (Test-Path $targetConfigDir) {
                Remove-Item $targetConfigDir -Recurse -Force
            }
            Copy-Item $sourceConfigDir $targetConfigDir -Recurse -Force
            Write-PortxDebug "Copied config directory to wrapper location"
        }

        $Script:UniversalWrapperBuilt = $true
        Write-PortxSuccess "Universal Go wrapper built successfully: $universalWrapperPath"
        return $true
    }
    catch {
        Write-PortxError "Failed to build universal wrapper: $($_.Exception.Message)"
        return $false
    }
}

function New-UniversalBashWrapper {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [string]$ToolName,
        [Parameter(Mandatory)]
        [string]$ExecutablePath,
        [string]$DefaultArgs = ""
    )

    Write-PortxDebug "New-UniversalBashWrapper called with PackageName='$PackageName', ToolName='$ToolName'"

    # Build universal wrapper if not already built
    if (-not (Build-UniversalGoWrapper)) {
        Write-PortxError "Failed to build universal wrapper"
        return $false
    }

    $wrapperPath = Join-Path -Path $Script:WrappersDir -ChildPath "posix" | Join-Path -ChildPath $ToolName
    $wrapperDir = Split-Path -Path $wrapperPath -Parent

    if (-not (Test-Path -Path $wrapperDir)) {
        New-Item -ItemType Directory -Path $wrapperDir -Force | Out-Null
    }

    # Generate lightweight bash wrapper that calls universal Go wrapper
    $wrapperContent = @"
#!/bin/bash
# PORTX Universal Wrapper for $PackageName/$ToolName
# Calls universal portx-wrap.exe with intelligent path conversion

# Universal environment detection
if [[ -n "`${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
    PORTX_ROOT="/mnt/c/App/PORTX"
elif [[ "`$OSTYPE" == "cygwin" ]]; then
    PORTX_ROOT="/cygdrive/c/App/PORTX"
else
    PORTX_ROOT="/c/App/PORTX"
fi

# Execute universal wrapper with tool name and all arguments
exec "`$PORTX_ROOT/go/target/portx-wrap.exe" "$ToolName" "`$@"
"@

    # Use sanitized file writing to ensure proper line endings
    Write-SanitizedFile -FilePath $wrapperPath -Content $wrapperContent

    # Make executable on Unix systems
    if (-not $Script:IsWindowsPlatform) {
        try {
            & chmod +x $wrapperPath
        } catch {
            Write-PortxWarn "Could not set executable permission on $wrapperPath"
        }
    }

    Write-PortxDebug "Created universal bash wrapper: $wrapperPath"
    return $true
}

function New-UniversalCmdWrapper {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [string]$ToolName,
        [Parameter(Mandatory)]
        [string]$ExecutablePath,
        [string]$DefaultArgs = ""
    )

    Write-PortxDebug "New-UniversalCmdWrapper called with PackageName='$PackageName', ToolName='$ToolName'"

    # Build universal wrapper if not already built
    if (-not (Build-UniversalGoWrapper)) {
        Write-PortxError "Failed to build universal wrapper"
        return $false
    }

    $wrapperPath = Join-Path -Path $Script:WrappersDir -ChildPath "windows" | Join-Path -ChildPath "$ToolName.cmd"
    $wrapperDir = Split-Path -Path $wrapperPath -Parent

    if (-not (Test-Path -Path $wrapperDir)) {
        New-Item -ItemType Directory -Path $wrapperDir -Force | Out-Null
    }

    # Generate lightweight CMD wrapper that calls universal Go wrapper
    $wrapperContent = @"
@echo off
rem PORTX Universal Wrapper for $PackageName/$ToolName
rem Calls universal portx-wrap.exe with intelligent path conversion

set PORTX_ROOT=C:\App\PORTX

"%PORTX_ROOT%\go\target\portx-wrap.exe" "$ToolName" %*
"@

    Set-Content -Path $wrapperPath -Value $wrapperContent -Encoding ASCII
    Write-PortxDebug "Created universal CMD wrapper: $wrapperPath"
    return $true
}

function New-UniversalGoWrapper {
    param(
        [Parameter(Mandatory)]
        [string]$PackageName,
        [Parameter(Mandatory)]
        [string]$ToolName,
        [Parameter(Mandatory)]
        [string]$ExecutablePath,
        [string]$DefaultArgs = ""
    )

    # This function ensures the universal wrapper is built (called once per import)
    # Individual tools don't need separate Go wrappers - they all use the universal one
    return (Build-UniversalGoWrapper)
}

# ============================================================================
# PACKAGE IMPORT LOGIC
# ============================================================================

function Import-PortxPackage {
    param([string]$PackagePath)

    $packageName = Split-Path -Leaf $PackagePath
    $configPath = Join-Path $PackagePath "portx.json"

    Write-PortxInfo "Processing: $packageName"

    # Validate package
    if (-not (Test-PortxPackage $PackagePath)) {
        Write-PortxError "Package validation failed: $packageName"
        return $false
    }

    # Load configuration
    $config = Get-Content $configPath -Raw | ConvertFrom-Json
    $importType = Get-ImportType $config

    Write-PortxInfo "  Import type: $importType"

    switch ($importType) {
        "none" {
            Write-PortxInfo "  SKIP: $packageName (documentation only)"
            return $true
        }

        "path" {
            Write-PortxInfo "  PATH: $packageName"
            $Script:PathPackages += $PackagePath
            return $true
        }

        { $_ -in @("wrap", "auto", "wrapAndPath") } {
            Write-PortxInfo "  WRAP: $packageName"

            if (-not $config.bin) {
                Write-PortxWarning "Package $packageName has no bin configuration"
                return $true
            }

            # Generate wrappers for each tool
            $wrapperCount = 0
            foreach ($toolName in $config.bin.PSObject.Properties.Name) {
                $toolConfig = $config.bin.$toolName

                Write-PortxDebug "Processing tool: $toolName, path: $($toolConfig.path)"

                if ($PSCmdlet.ShouldProcess("$packageName/$toolName", "Create wrapper")) {
                    try {
                        # Ensure defaultArgs is never null
                        $defaultArgs = if ($toolConfig.defaultArgs) { $toolConfig.defaultArgs } else { "" }

                        # Create bash wrapper that calls universal Go wrapper
                        Write-PortxDebug "About to create bash wrapper with: PackageName=$packageName, ToolName=$toolName, ExecutablePath=$($toolConfig.path), DefaultArgs='$defaultArgs'"
                        New-UniversalBashWrapper -PackageName $packageName -ToolName $toolName -ExecutablePath $toolConfig.path -DefaultArgs $defaultArgs

                        # Create CMD wrapper that calls universal Go wrapper (Windows only)
                        if ($Script:IsWindowsPlatform) {
                            New-UniversalCmdWrapper -PackageName $packageName -ToolName $toolName -ExecutablePath $toolConfig.path -DefaultArgs $defaultArgs
                        }

                        # Create Go wrapper (build universal wrapper once, then create lightweight wrappers)
                        Write-PortxDebug "About to create Go wrapper with: PackageName=$packageName, ToolName=$toolName, ExecutablePath=$($toolConfig.path), DefaultArgs='$defaultArgs'"
                        New-UniversalGoWrapper -PackageName $packageName -ToolName $toolName -ExecutablePath $toolConfig.path -DefaultArgs $defaultArgs

                        $wrapperCount++
                    }
                    catch {
                        Write-PortxError "Failed to create wrapper for $toolName`: $($_.Exception.Message)"
                        throw
                    }
                }
            }

            Write-PortxSuccess "  Created $wrapperCount wrappers for $packageName"

            # Validate created wrappers
            Write-PortxDebug "Starting wrapper validation for package: $packageName" "VALIDATION"
            $validationErrors = 0
            foreach ($toolName in $config.tools.PSObject.Properties.Name) {
                if (-not (Test-WrapperPair -ToolName $toolName -PackageName $packageName)) {
                    $validationErrors++
                }
            }

            if ($validationErrors -gt 0) {
                Write-PortxError "  Validation failed: $validationErrors errors in $packageName wrappers" "VALIDATION"
            } else {
                Write-PortxDebug "  Wrapper validation passed for $packageName" "VALIDATION"
            }

            # Also add to PATH if wrapAndPath
            if ($importType -eq "wrapAndPath") {
                Write-PortxInfo "  Also adding to PATH"
                $Script:PathPackages += $PackagePath
            }

            return $true
        }
    }

    return $false
}

# ============================================================================
# MAIN IMPORT FUNCTION
# ============================================================================

function Invoke-PortxImport {
    param(
        [string]$SpecificPackage,
        [switch]$Force
    )

    Write-PortxInfo "PORTX 2.0 Package Import Starting..."
    Write-PortxInfo "Packages directory: $Script:PackagesDir"

    # Verify packages directory exists
    if (-not (Test-Path $Script:PackagesDir)) {
        Write-PortxError "Packages directory not found: $Script:PackagesDir"
        return $false
    }

    # Clear old wrappers if Clean
    if ($Clean) {
        Write-PortxInfo "Clean mode: Removing all existing wrappers..."
        if (Test-Path $Script:WrappersDir) {
            Remove-Item $Script:WrappersDir -Recurse -Force
        }
    }

    # Create wrapper directories
    @("posix", "windows", "go") | ForEach-Object {
        $dir = Join-Path $Script:WrappersDir $_
        if (-not (Test-Path $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }
    }

    # Track PATH packages
    $pathPackages = @()

    # Get packages to import
    $packagesToImport = if ($SpecificPackage) {
        $packagePath = Join-Path $Script:PackagesDir $SpecificPackage
        if (Test-Path $packagePath) { @($packagePath) } else { @() }
    } else {
        Get-ChildItem $Script:PackagesDir -Directory | ForEach-Object { $_.FullName }
    }

    if ($packagesToImport.Count -eq 0) {
        if ($SpecificPackage) {
            Write-PortxError "Package not found: $SpecificPackage"
        } else {
            Write-PortxError "No packages found in: $Script:PackagesDir"
        }
        return $false
    }

    # Import packages
    $successCount = 0
    $totalCount = $packagesToImport.Count
    $failedPackages = @()

    foreach ($packagePath in $packagesToImport) {
        if (Import-PortxPackage $packagePath) {
            $successCount++
        } else {
            $packageName = Split-Path -Leaf $packagePath
            $failedPackages += $packageName
        }
    }

    # Generate summary
    $failedCount = $totalCount - $successCount
    if ($failedCount -gt 0) {
        Write-PortxWarning "Import completed: $successCount/$totalCount packages processed ($failedCount failed)"
        Write-PortxWarning "Failed packages: $($failedPackages -join ', ')"
    } else {
        Write-PortxSuccess "Import completed: $successCount/$totalCount packages processed"
    }

    # Generate packages path if we have PATH packages
    if ($Script:PathPackages.Count -gt 0) {
        New-PathCache -PathPackages $Script:PathPackages
    }

    return $successCount -eq $totalCount
}

# ============================================================================
# PATH CACHE MANAGEMENT
# ============================================================================

function New-PathCache {
    param([string[]]$PathPackages)

    $cacheFile = Join-Path $Script:PortxRoot "path\portx_pkg_path"

    Write-PortxInfo "Generating packages path: $cacheFile"

    $packagesContent = @"
#!/bin/bash
# PORTX 2.0 Packages Path
# Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
# This file is automatically sourced to add PORTX packages to PATH

# Detect environment and set package root
if [[ -n "`${WSL_DISTRO_NAME:-}" ]] || grep -qi microsoft /proc/version 2>/dev/null; then
    PORTX_ROOT="/mnt/c/App/PORTX"
elif [[ "`$OSTYPE" == "cygwin" ]]; then
    PORTX_ROOT="/cygdrive/c/App/PORTX"
else
    PORTX_ROOT="/c/App/PORTX"
fi

# Add PORTX Go wrappers to PATH (universal wrappers for all environments)
export PATH="`$PATH:`$PORTX_ROOT/wrappers/go"

# Build PORTX PACKAGES PATH
PACKAGES_PATH=""
"@

    foreach ($packagePath in $PathPackages) {
        $packageName = Split-Path -Leaf $packagePath
        $packagesContent += "`nif [[ -z `"`$PACKAGES_PATH`" ]]; then`n    PACKAGES_PATH=`"`$PORTX_ROOT/packages/$packageName`"`nelse`n    PACKAGES_PATH=`"`$PACKAGES_PATH:`$PORTX_ROOT/packages/$packageName`"`nfi  # $packageName"
    }

    $packagesContent += @"


# PORTX packages path statistics
export PORTX_PATH_PACKAGES="$($PathPackages.Count)"
export PORTX_LAST_IMPORT="$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"

# Export PACKAGES_PATH for shell integration
export PORTX_PACKAGES_PATH="`$PACKAGES_PATH"
"@

    # Use sanitized file writing to ensure proper line endings
    Write-SanitizedFile -FilePath $cacheFile -Content $packagesContent
    Write-PortxSuccess "Packages path created with $($PathPackages.Count) packages"
}

# ============================================================================
# SCRIPT ENTRY POINT
# ============================================================================

# Initialize logging
if (Test-Path $Script:LogFile) {
    Remove-Item $Script:LogFile -Force
}

Write-PortxInfo "PORTX 2.0 PowerShell Import Manager"
Write-PortxInfo "PowerShell Version: $($PSVersionTable.PSVersion)"
Write-PortxInfo "Platform: $($PSVersionTable.Platform)"

# Execute import
try {
    $result = Invoke-PortxImport -SpecificPackage $PackageName -Force:$Force

    if ($result) {
        Write-PortxSuccess "Import completed successfully!"
        exit 0
    } else {
        Write-PortxError "Import failed!"
        exit 1
    }
}
catch {
    Write-PortxError "Unexpected error: $($_.Exception.Message)"
    Write-PortxDebug $_.ScriptStackTrace
    exit 1
}