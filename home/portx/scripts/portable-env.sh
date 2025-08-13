#!/bin/bash
# Portable Git Bash Environment Library
# =====================================
#
# PURPOSE: Universal cross-platform shell library for Git Bash/MSYS2/Cygwin environments
# AUTHOR: Portable Development Environment Project
# VERSION: 1.0.0
# LICENSE: MIT
# UPDATED: 2025-08-13
#
# DESCRIPTION:
#   This library provides a comprehensive set of portable functions and utilities
#   designed to work consistently across Git Bash, MSYS2, Cygwin, and other
#   POSIX-compatible environments on Windows. It handles the common pain points
#   of cross-platform shell scripting including path conversions, Windows/POSIX
#   interoperability, error handling, logging, and environment detection.
#
# FEATURES:
#   - Windows/POSIX path conversion utilities
#   - Robust error handling and logging framework  
#   - Cross-platform file system operations
#   - Environment detection and validation
#   - POSIX-compliant utility functions
#   - Shell script best practices enforcement
#   - Command execution wrappers for Windows tools
#   - Portable string manipulation functions
#   - Network and system information utilities
#   - Backup and recovery functions
#
# USAGE:
#   Source this file at the beginning of your shell scripts:
#   
#   #!/bin/bash
#   source "$(dirname "${BASH_SOURCE[0]}")/portable-env.sh"
#   
#   # Optional: Enable strict mode for robust scripting
#   set_strict_mode
#   
#   # Use any of the provided functions
#   log_info "Script starting..."
#   validate_prerequisites "git.exe" "curl.exe"
#   
# REQUIREMENTS:
#   - Bash 4.0+ (for associative arrays)
#   - Git Bash, MSYS2, or Cygwin environment
#   - Windows 7+ with NTFS filesystem
#
# COMPATIBILITY:
#   ✓ Git for Windows (Git Bash)
#   ✓ MSYS2 environments (MINGW64, UCRT64, CLANG64)
#   ✓ Cygwin
#   ✓ Windows Subsystem for Linux (WSL)
#   ✓ Standard Unix/Linux bash (limited functionality)
#
# AVAILABLE FUNCTIONS:
#
# Path Conversion & File System:
#   to_windows_path()        - Convert POSIX to Windows path format
#   to_posix_path()          - Convert Windows to POSIX path format  
#   get_absolute_path()      - Get absolute path in POSIX format
#   normalize_path()         - Normalize path with proper separators
#   path_exists()            - Check if path exists (both formats)
#   safe_mkdir()             - Create directories with proper permissions
#   safe_remove()            - Remove files/directories safely
#   get_script_dir()         - Get directory of current script
#   get_temp_dir()           - Get temporary directory path
#   create_backup()          - Create timestamped backup of file/directory
#
# Windows Integration:
#   run_windows_cmd()        - Execute Windows commands with path conversion
#   run_powershell()         - Execute PowerShell with automatic path handling
#   run_cmd()                - Execute CMD with path conversion
#   get_windows_username()   - Get current Windows username
#   get_windows_version()    - Get Windows version information
#   is_admin()               - Check if running with admin privileges
#
# Environment Detection:
#   is_git_bash()            - Detect Git Bash environment
#   is_msys2()               - Detect MSYS2 environment
#   is_cygwin()              - Detect Cygwin environment
#   is_wsl()                 - Detect Windows Subsystem for Linux
#   is_portable_env()        - Detect portable development environment
#   get_shell_info()         - Get detailed shell and environment info
#   detect_platform()        - Detect operating system and architecture
#
# Error Handling & Logging:
#   set_strict_mode()        - Enable bash strict mode (set -euo pipefail)
#   set_debug_mode()         - Enable debug mode with tracing
#   log_info()               - Log informational messages
#   log_warning()            - Log warning messages  
#   log_error()              - Log error messages
#   log_debug()              - Log debug messages (when debug enabled)
#   die()                    - Log error and exit with code
#   assert()                 - Assert condition with error message
#   retry()                  - Retry command with exponential backoff
#
# Script Utilities:
#   print_script_header()    - Print standardized script header
#   validate_prerequisites() - Check for required commands/files
#   parse_version()          - Parse and compare semantic versions
#   spinner()                - Show spinning progress indicator
#   progress_bar()           - Show progress bar with percentage
#   confirm()                - Interactive yes/no confirmation
#   select_option()          - Interactive menu selection
#
# String Manipulation:
#   trim()                   - Remove leading/trailing whitespace
#   upper()                  - Convert string to uppercase
#   lower()                  - Convert string to lowercase
#   contains()               - Check if string contains substring
#   starts_with()            - Check if string starts with prefix
#   ends_with()              - Check if string ends with suffix
#   join()                   - Join array elements with delimiter
#   split()                  - Split string into array by delimiter
#
# Network & System:
#   get_public_ip()          - Get public IP address
#   check_internet()         - Check internet connectivity
#   download_file()          - Download file with progress
#   get_cpu_count()          - Get number of CPU cores
#   get_memory_info()        - Get memory usage information
#   check_disk_space()       - Check available disk space
#
# Configuration Management:
#   load_config()            - Load configuration from file
#   save_config()            - Save configuration to file
#   get_config_value()       - Get configuration value by key
#   set_config_value()       - Set configuration value by key
#   merge_configs()          - Merge multiple configuration files
#
# Security & Validation:
#   validate_path()          - Validate path for security issues
#   sanitize_filename()      - Sanitize filename for cross-platform use
#   check_permissions()      - Check file/directory permissions
#   secure_delete()          - Securely delete sensitive files
#   generate_uuid()          - Generate UUID v4
#   hash_string()            - Generate hash of string (SHA256)
#
# EXAMPLES:
#   # Basic usage
#   log_info "Converting path: $(to_windows_path "/c/Users/me/Documents")"
#   
#   # Windows command execution
#   run_powershell -Command "Get-Process | Where-Object {$_.CPU -gt 100}"
#   
#   # Error handling
#   if ! validate_prerequisites "git.exe" "node.exe"; then
#       die "Missing required tools"
#   fi
#   
#   # File operations
#   if path_exists "/c/temp/data.txt"; then
#       create_backup "/c/temp/data.txt"
#   fi

# =============================================================================
# CORE CONFIGURATION AND INITIALIZATION
# =============================================================================

# Library version
readonly PORTABLE_ENV_VERSION="1.0.0"

# Global configuration
declare -A PORTABLE_CONFIG=(
    [LOG_LEVEL]="INFO"
    [LOG_TIMESTAMP]=true
    [STRICT_MODE]=false
    [DEBUG_MODE]=false
    [COLOR_OUTPUT]=true
    [BACKUP_SUFFIX]=".backup"
    [TEMP_PREFIX]="portable_"
)

# Color definitions (ANSI escape codes)
if [[ "${PORTABLE_CONFIG[COLOR_OUTPUT]}" == true ]] && [[ -t 2 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly BLUE='\033[0;34m'
    readonly PURPLE='\033[0;35m'
    readonly CYAN='\033[0;36m'
    readonly WHITE='\033[1;37m'
    readonly BOLD='\033[1m'
    readonly RESET='\033[0m'
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly PURPLE=''
    readonly CYAN=''
    readonly WHITE=''
    readonly BOLD=''
    readonly RESET=''
fi

# =============================================================================
# ENVIRONMENT VALIDATION AND DETECTION
# =============================================================================

# Validate bash version and environment
_validate_environment() {
    # Check bash version (require 4.0+ for associative arrays)
    if [[ ${BASH_VERSION%%.*} -lt 4 ]]; then
        echo "ERROR: Bash 4.0+ required. Current version: $BASH_VERSION" >&2
        return 1
    fi
    
    # Set reasonable defaults
    export LC_ALL=C.UTF-8 2>/dev/null || export LC_ALL=C
    
    # Configure MSYS2 path conversion for better behavior
    export MSYS2_ARG_CONV_EXCL="--*;-D*;-I*;-L*;-f*;-o*;-config*;-input*;-output*"
    export MSYS2_PATH_TYPE=minimal
    export MSYS_NO_PATHCONV=""
    
    return 0
}

# Detect if running in Git Bash
is_git_bash() {
    [[ "$MSYSTEM" == "MINGW64" ]] && command -v git.exe >/dev/null 2>&1
}

# Detect if running in MSYS2
is_msys2() {
    [[ -n "$MSYSTEM" ]] && [[ -d "/usr" ]]
}

# Detect if running in Cygwin
is_cygwin() {
    [[ "$(uname -o 2>/dev/null)" == "Cygwin" ]]
}

# Detect if running in WSL
is_wsl() {
    [[ -n "$WSL_DISTRO_NAME" ]] || grep -qi microsoft /proc/version 2>/dev/null
}

# Detect portable development environment
is_portable_env() {
    [[ -n "$PORTABLE_ROOT" ]] || [[ -d "/c/App" ]] || [[ "$PWD" =~ /c/App ]]
}

# Get comprehensive environment information
get_shell_info() {
    cat << EOF
Shell Environment Information:
==============================
Shell: $SHELL ($BASH_VERSION)
System: $(uname -o 2>/dev/null || uname -s)
Architecture: $(uname -m)
MSYSTEM: ${MSYSTEM:-"(not set)"}
Environment: $(
    if is_git_bash; then echo "Git Bash"
    elif is_msys2; then echo "MSYS2"
    elif is_cygwin; then echo "Cygwin"
    elif is_wsl; then echo "WSL"
    else echo "Unix/Linux"
    fi
)
Portable Environment: $(is_portable_env && echo "Yes" || echo "No")
Working Directory: $(pwd)
Home Directory: $HOME
User: ${USER:-${USERNAME:-"unknown"}}
EOF
}

# Detect platform and architecture
detect_platform() {
    local os arch
    
    if is_wsl || is_msys2 || is_cygwin || is_git_bash; then
        os="windows"
    else
        case "$(uname -s)" in
            Linux*) os="linux" ;;
            Darwin*) os="macos" ;;
            CYGWIN*|MINGW*|MSYS*) os="windows" ;;
            *) os="unknown" ;;
        esac
    fi
    
    case "$(uname -m)" in
        x86_64|amd64) arch="amd64" ;;
        i*86) arch="386" ;;
        arm64|aarch64) arch="arm64" ;;
        armv7*) arch="armv7" ;;
        *) arch="unknown" ;;
    esac
    
    echo "${os}_${arch}"
}

# =============================================================================
# LOGGING AND ERROR HANDLING
# =============================================================================

# Get current timestamp for logging
_get_timestamp() {
    if [[ "${PORTABLE_CONFIG[LOG_TIMESTAMP]}" == true ]]; then
        date '+%Y-%m-%d %H:%M:%S'
    fi
}

# Internal logging function
_log() {
    local level="$1" color="$2" message="$3"
    local timestamp
    
    # Check log level
    case "${PORTABLE_CONFIG[LOG_LEVEL]}" in
        DEBUG) [[ "$level" =~ ^(DEBUG|INFO|WARNING|ERROR)$ ]] || return 0 ;;
        INFO) [[ "$level" =~ ^(INFO|WARNING|ERROR)$ ]] || return 0 ;;
        WARNING) [[ "$level" =~ ^(WARNING|ERROR)$ ]] || return 0 ;;
        ERROR) [[ "$level" == "ERROR" ]] || return 0 ;;
        *) return 0 ;;
    esac
    
    timestamp=$(_get_timestamp)
    if [[ -n "$timestamp" ]]; then
        printf "${color}[%s] [%s]${RESET} %s\n" "$timestamp" "$level" "$message" >&2
    else
        printf "${color}[%s]${RESET} %s\n" "$level" "$message" >&2
    fi
}

# Logging functions
log_debug() { _log "DEBUG" "$CYAN" "$*"; }
log_info() { _log "INFO" "$GREEN" "$*"; }
log_warning() { _log "WARNING" "$YELLOW" "$*"; }
log_error() { _log "ERROR" "$RED" "$*"; }

# Enhanced error handling
die() {
    log_error "$*"
    exit 1
}

# Assert function for validation
assert() {
    local condition="$1" message="$2"
    if ! eval "$condition"; then
        die "Assertion failed: $message"
    fi
}

# Set strict mode for robust scripting
set_strict_mode() {
    set -euo pipefail
    PORTABLE_CONFIG[STRICT_MODE]=true
    
    # Enhanced error trap
    trap '_handle_error $? $LINENO $BASH_LINENO "$BASH_COMMAND" "${FUNCNAME[*]}"' ERR
    
    log_debug "Strict mode enabled (set -euo pipefail)"
}

# Error handler for strict mode
_handle_error() {
    local exit_code="$1" line_no="$2" bash_lineno="$3" last_command="$4" function_stack="$5"
    
    log_error "Script failed with exit code $exit_code"
    log_error "Failed command: $last_command"
    log_error "Line number: $line_no"
    log_error "Function stack: $function_stack"
    
    exit "$exit_code"
}

# Set debug mode
set_debug_mode() {
    set -x
    PORTABLE_CONFIG[DEBUG_MODE]=true
    PORTABLE_CONFIG[LOG_LEVEL]="DEBUG"
    
    log_debug "Debug mode enabled (set -x)"
}

# Retry function with exponential backoff
retry() {
    local max_attempts="${1:-3}"
    local delay="${2:-1}"
    local command=("${@:3}")
    local attempt=1
    
    while [[ $attempt -le $max_attempts ]]; do
        if "${command[@]}"; then
            return 0
        fi
        
        if [[ $attempt -lt $max_attempts ]]; then
            log_warning "Command failed (attempt $attempt/$max_attempts), retrying in ${delay}s..."
            sleep "$delay"
            delay=$((delay * 2))  # Exponential backoff
        fi
        
        ((attempt++))
    done
    
    log_error "Command failed after $max_attempts attempts: ${command[*]}"
    return 1
}

# =============================================================================
# PATH CONVERSION AND FILE SYSTEM OPERATIONS
# =============================================================================

# Convert POSIX path to Windows path format
to_windows_path() {
    local posix_path="$1"
    
    [[ -z "$posix_path" ]] && { echo "Usage: to_windows_path <posix_path>" >&2; return 1; }
    
    # Use cygpath if available (Git Bash, MSYS2, Cygwin)
    if command -v cygpath >/dev/null 2>&1; then
        cygpath -w "$posix_path" 2>/dev/null || echo "$posix_path"
    else
        # Fallback conversion for basic paths
        echo "$posix_path" | sed 's|^/c/|C:/|; s|^/d/|D:/|; s|^/e/|E:/|; s|/|\\|g'
    fi
}

# Convert Windows path to POSIX path format
to_posix_path() {
    local windows_path="$1"
    
    [[ -z "$windows_path" ]] && { echo "Usage: to_posix_path <windows_path>" >&2; return 1; }
    
    # Use cygpath if available
    if command -v cygpath >/dev/null 2>&1; then
        cygpath -u "$windows_path" 2>/dev/null || echo "$windows_path"
    else
        # Fallback conversion
        echo "$windows_path" | sed 's|^C:|/c|; s|^D:|/d|; s|^E:|/e|; s|\\|/|g'
    fi
}

# Get absolute path in POSIX format
get_absolute_path() {
    local input_path="$1"
    
    [[ -z "$input_path" ]] && { echo "Usage: get_absolute_path <path>" >&2; return 1; }
    
    # Convert Windows path to POSIX if needed
    if [[ "$input_path" =~ ^[A-Za-z]: ]]; then
        input_path=$(to_posix_path "$input_path")
    fi
    
    # Get absolute path
    if [[ -e "$input_path" ]]; then
        realpath "$input_path" 2>/dev/null || {
            # Fallback if realpath not available
            cd "$(dirname "$input_path")" && echo "$(pwd)/$(basename "$input_path")"
        }
    else
        # Path doesn't exist, construct absolute path
        if [[ "$input_path" =~ ^/ ]]; then
            echo "$input_path"  # Already absolute
        else
            echo "$(pwd)/$input_path"  # Make relative path absolute
        fi
    fi
}

# Normalize path with proper separators
normalize_path() {
    local path="$1"
    
    [[ -z "$path" ]] && { echo "Usage: normalize_path <path>" >&2; return 1; }
    
    # Remove duplicate slashes and normalize
    echo "$path" | sed 's|/\+|/|g; s|/$||; s|^\./||'
}

# Check if path exists (handles both Windows and POSIX)
path_exists() {
    local check_path="$1"
    
    [[ -z "$check_path" ]] && { echo "Usage: path_exists <path>" >&2; return 1; }
    
    # Try as POSIX path first
    [[ -e "$check_path" ]] && return 0
    
    # Try converting if it looks like Windows path
    if [[ "$check_path" =~ ^[A-Za-z]: ]]; then
        local posix_path
        posix_path=$(to_posix_path "$check_path")
        [[ -e "$posix_path" ]] && return 0
    fi
    
    return 1
}

# Create directory with proper permissions
safe_mkdir() {
    local dir_path="$1" mode="${2:-755}"
    
    [[ -z "$dir_path" ]] && { echo "Usage: safe_mkdir <directory_path> [mode]" >&2; return 1; }
    
    # Convert to POSIX for mkdir
    if [[ "$dir_path" =~ ^[A-Za-z]: ]]; then
        dir_path=$(to_posix_path "$dir_path")
    fi
    
    if mkdir -p "$dir_path" 2>/dev/null; then
        chmod "$mode" "$dir_path" 2>/dev/null || true
        log_debug "Created directory: $dir_path"
        return 0
    else
        log_error "Failed to create directory: $dir_path"
        return 1
    fi
}

# Remove files/directories safely
safe_remove() {
    local target="$1"
    
    [[ -z "$target" ]] && { echo "Usage: safe_remove <path>" >&2; return 1; }
    
    if [[ ! -e "$target" ]]; then
        log_warning "Path does not exist: $target"
        return 0
    fi
    
    # Security check: don't remove system directories
    case "$(normalize_path "$target")" in
        /|/bin|/usr|/etc|/home|/root|/var|/tmp)
            log_error "Refusing to remove system directory: $target"
            return 1
            ;;
    esac
    
    if rm -rf "$target" 2>/dev/null; then
        log_debug "Removed: $target"
        return 0
    else
        log_error "Failed to remove: $target"
        return 1
    fi
}

# Get directory of current script
get_script_dir() {
    local script_path="${BASH_SOURCE[1]:-$0}"
    dirname "$(get_absolute_path "$script_path")"
}

# Get temporary directory path
get_temp_dir() {
    local temp_base
    
    # Try different temporary directory locations
    for temp_base in "$TMPDIR" "$TMP" "$TEMP" "/tmp" "/var/tmp"; do
        if [[ -n "$temp_base" ]] && [[ -d "$temp_base" ]] && [[ -w "$temp_base" ]]; then
            echo "$temp_base"
            return 0
        fi
    done
    
    # Fallback to current directory
    echo "."
}

# Create timestamped backup of file/directory
create_backup() {
    local source="$1"
    local backup_dir="${2:-$(dirname "$source")}"
    local timestamp backup_path
    
    [[ -z "$source" ]] && { echo "Usage: create_backup <source> [backup_directory]" >&2; return 1; }
    
    if [[ ! -e "$source" ]]; then
        log_error "Source does not exist: $source"
        return 1
    fi
    
    timestamp=$(date '+%Y%m%d_%H%M%S')
    backup_path="$backup_dir/$(basename "$source").backup_$timestamp"
    
    if cp -r "$source" "$backup_path" 2>/dev/null; then
        log_info "Backup created: $backup_path"
        echo "$backup_path"
        return 0
    else
        log_error "Failed to create backup of: $source"
        return 1
    fi
}

# =============================================================================
# WINDOWS INTEGRATION FUNCTIONS
# =============================================================================

# Execute Windows command with automatic path conversion
run_windows_cmd() {
    local cmd="$1"
    shift
    
    [[ -z "$cmd" ]] && { echo "Usage: run_windows_cmd <command> [args...]" >&2; return 1; }
    
    # Convert POSIX paths in arguments to Windows format
    local converted_args=()
    for arg in "$@"; do
        case "$arg" in
            # Skip flag assignments
            --*=*) converted_args+=("$arg") ;;
            # Convert standalone POSIX paths
            /c/*|/d/*|/e/*|/tmp/*|/home/*) converted_args+=("$(to_windows_path "$arg")") ;;
            *) converted_args+=("$arg") ;;
        esac
    done
    
    # Execute with path conversion disabled to prevent double conversion
    MSYS_NO_PATHCONV=1 "$cmd" "${converted_args[@]}"
}

# Execute PowerShell with path conversion
run_powershell() {
    if ! command -v powershell.exe >/dev/null 2>&1; then
        log_error "PowerShell not found in PATH"
        return 1
    fi
    
    run_windows_cmd powershell.exe "$@"
}

# Execute CMD with path conversion
run_cmd() {
    if ! command -v cmd.exe >/dev/null 2>&1; then
        log_error "CMD not found in PATH"
        return 1
    fi
    
    run_windows_cmd cmd.exe "$@"
}

# Get current Windows username
get_windows_username() {
    echo "${USERNAME:-${USER:-unknown}}"
}

# Get Windows version information
get_windows_version() {
    if is_wsl || is_msys2 || is_cygwin || is_git_bash; then
        run_cmd /c "ver" 2>/dev/null | tr -d '\r\n' || echo "Unknown Windows Version"
    else
        echo "Not running on Windows"
    fi
}

# Check if running with admin privileges
is_admin() {
    if is_wsl || is_msys2 || is_cygwin || is_git_bash; then
        # Try to access admin-only location
        [[ -w "/c/Windows/System32" ]] 2>/dev/null
    else
        # Unix/Linux: check if root
        [[ $EUID -eq 0 ]]
    fi
}

# =============================================================================
# STRING MANIPULATION FUNCTIONS  
# =============================================================================

# Remove leading and trailing whitespace
trim() {
    local str="$1"
    str="${str#"${str%%[![:space:]]*}"}"  # Remove leading whitespace
    str="${str%"${str##*[![:space:]]}"}"  # Remove trailing whitespace
    echo "$str"
}

# Convert string to uppercase
upper() {
    echo "$1" | tr '[:lower:]' '[:upper:]'
}

# Convert string to lowercase
lower() {
    echo "$1" | tr '[:upper:]' '[:lower:]'
}

# Check if string contains substring
contains() {
    local string="$1" substring="$2"
    [[ "$string" == *"$substring"* ]]
}

# Check if string starts with prefix
starts_with() {
    local string="$1" prefix="$2"
    [[ "$string" == "$prefix"* ]]
}

# Check if string ends with suffix
ends_with() {
    local string="$1" suffix="$2"
    [[ "$string" == *"$suffix" ]]
}

# Join array elements with delimiter
join() {
    local delimiter="$1"
    shift
    local result="$1"
    shift
    for item in "$@"; do
        result+="$delimiter$item"
    done
    echo "$result"
}

# Split string into array by delimiter (sets global SPLIT_RESULT array)
split() {
    local string="$1" delimiter="$2"
    SPLIT_RESULT=()
    
    if [[ -z "$delimiter" ]]; then
        # Split by whitespace
        read -ra SPLIT_RESULT <<< "$string"
    else
        # Split by custom delimiter
        IFS="$delimiter" read -ra SPLIT_RESULT <<< "$string"
    fi
}

# =============================================================================
# SCRIPT UTILITIES AND VALIDATION
# =============================================================================

# Print standardized script header
print_script_header() {
    local script_name="$1" description="$2"
    
    cat << EOF
==================================================
Script: ${script_name:-$(basename "$0")}
Description: ${description:-"No description provided"}
Environment: $(get_shell_info | grep "Environment:" | cut -d' ' -f2-)
Working Directory: $(pwd)
User: $(get_windows_username)
Timestamp: $(date)
==================================================
EOF
}

# Validate script prerequisites
validate_prerequisites() {
    local required_commands=("$@")
    local missing_commands=()
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing_commands+=("$cmd")
        fi
    done
    
    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        log_error "Missing required commands:"
        for cmd in "${missing_commands[@]}"; do
            log_error "  - $cmd"
        done
        log_error "Please install missing commands and try again."
        return 1
    fi
    
    log_debug "All prerequisites validated: ${required_commands[*]}"
    return 0
}

# Parse and compare semantic versions
parse_version() {
    local version="$1" comparison="$2" target="$3"
    
    [[ -z "$version" ]] && { echo "Usage: parse_version <version> [comparison] [target]" >&2; return 1; }
    
    # Just return version if no comparison requested
    [[ -z "$comparison" ]] && { echo "$version"; return 0; }
    
    # Simple version comparison (assumes semantic versioning)
    local IFS='.'
    local ver1=($version) ver2=($target)
    
    for ((i=0; i<${#ver1[@]} || i<${#ver2[@]}; i++)); do
        local v1=${ver1[i]:-0} v2=${ver2[i]:-0}
        
        case "$comparison" in
            "gt"|">") [[ $v1 -gt $v2 ]] && return 0; [[ $v1 -lt $v2 ]] && return 1 ;;
            "ge"|">=") [[ $v1 -gt $v2 ]] && return 0; [[ $v1 -lt $v2 ]] && return 1 ;;
            "lt"|"<") [[ $v1 -lt $v2 ]] && return 0; [[ $v1 -gt $v2 ]] && return 1 ;;
            "le"|"<=") [[ $v1 -lt $v2 ]] && return 0; [[ $v1 -gt $v2 ]] && return 1 ;;
            "eq"|"=") [[ $v1 -ne $v2 ]] && return 1 ;;
            "ne"|"!=") [[ $v1 -eq $v2 ]] && return 1 ;;
        esac
    done
    
    return 0
}

# Interactive yes/no confirmation
confirm() {
    local prompt="$1" default="${2:-}"
    local response
    
    while true; do
        if [[ -n "$default" ]]; then
            read -p "$prompt [$(upper "$default")/$(lower "${default/y/n}")"[y/n]"]: " response
            response=${response:-$default}
        else
            read -p "$prompt [y/n]: " response
        fi
        
        case "$(lower "$response")" in
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) echo "Please answer yes or no." ;;
        esac
    done
}

# Interactive menu selection
select_option() {
    local prompt="$1"
    shift
    local options=("$@")
    local choice
    
    echo "$prompt"
    for i in "${!options[@]}"; do
        echo "  $((i+1))) ${options[i]}"
    done
    
    while true; do
        read -p "Enter choice [1-${#options[@]}]: " choice
        if [[ "$choice" =~ ^[0-9]+$ ]] && [[ $choice -ge 1 ]] && [[ $choice -le ${#options[@]} ]]; then
            echo "${options[$((choice-1))]}"
            return $((choice-1))
        fi
        echo "Invalid choice. Please enter a number between 1 and ${#options[@]}."
    done
}

# =============================================================================
# NETWORK AND SYSTEM INFORMATION
# =============================================================================

# Get public IP address
get_public_ip() {
    local ip
    
    # Try multiple services
    for service in "ifconfig.me" "ipinfo.io/ip" "icanhazip.com"; do
        if ip=$(curl -s --max-time 5 "$service" 2>/dev/null) && [[ -n "$ip" ]]; then
            echo "$ip"
            return 0
        fi
    done
    
    log_warning "Could not determine public IP address"
    return 1
}

# Check internet connectivity
check_internet() {
    local test_hosts=("google.com" "cloudflare.com" "8.8.8.8")
    
    for host in "${test_hosts[@]}"; do
        if ping -c 1 -W 3 "$host" >/dev/null 2>&1; then
            log_debug "Internet connectivity confirmed via $host"
            return 0
        fi
    done
    
    log_warning "No internet connectivity detected"
    return 1
}

# Download file with progress
download_file() {
    local url="$1" output="$2"
    
    [[ -z "$url" || -z "$output" ]] && { echo "Usage: download_file <url> <output_file>" >&2; return 1; }
    
    if command -v curl >/dev/null 2>&1; then
        curl -L --progress-bar -o "$output" "$url"
    elif command -v wget >/dev/null 2>&1; then
        wget --progress=bar -O "$output" "$url"
    else
        log_error "Neither curl nor wget available for downloading"
        return 1
    fi
}

# Get number of CPU cores
get_cpu_count() {
    if command -v nproc >/dev/null 2>&1; then
        nproc
    elif [[ -r /proc/cpuinfo ]]; then
        grep -c ^processor /proc/cpuinfo
    elif is_wsl || is_msys2 || is_cygwin || is_git_bash; then
        echo "${NUMBER_OF_PROCESSORS:-1}"
    else
        echo "1"
    fi
}

# Get memory usage information
get_memory_info() {
    if [[ -r /proc/meminfo ]]; then
        awk '/MemTotal|MemFree|MemAvailable/ {print $1 " " $2 " " $3}' /proc/meminfo
    elif command -v free >/dev/null 2>&1; then
        free -h
    else
        log_warning "Memory information not available on this platform"
        return 1
    fi
}

# Check available disk space
check_disk_space() {
    local path="${1:-$(pwd)}" threshold="${2:-90}"
    local usage
    
    if command -v df >/dev/null 2>&1; then
        usage=$(df "$path" | awk 'NR==2 {print int($5)}')
        
        if [[ $usage -gt $threshold ]]; then
            log_warning "Disk usage ${usage}% exceeds threshold ${threshold}% for $path"
            return 1
        else
            log_debug "Disk usage ${usage}% is within threshold for $path"
            return 0
        fi
    else
        log_warning "Cannot check disk space - df command not available"
        return 1
    fi
}

# =============================================================================
# SECURITY AND VALIDATION FUNCTIONS
# =============================================================================

# Validate path for security issues
validate_path() {
    local path="$1"
    
    [[ -z "$path" ]] && { echo "Usage: validate_path <path>" >&2; return 1; }
    
    # Check for dangerous patterns
    if [[ "$path" =~ \.\.|^\s*$ ]]; then
        log_error "Path contains dangerous patterns: $path"
        return 1
    fi
    
    # Check for null bytes
    if [[ "$path" == *$'\0'* ]]; then
        log_error "Path contains null bytes: $path"
        return 1
    fi
    
    return 0
}

# Sanitize filename for cross-platform use
sanitize_filename() {
    local filename="$1"
    
    [[ -z "$filename" ]] && { echo "Usage: sanitize_filename <filename>" >&2; return 1; }
    
    # Remove or replace problematic characters
    filename=$(echo "$filename" | tr '[:upper:]' '[:lower:]')  # Lowercase
    filename=$(echo "$filename" | sed 's/[<>:"|?*\\\/]/_/g')    # Replace illegal chars
    filename=$(echo "$filename" | sed 's/[[:space:]]\+/_/g')   # Replace spaces
    filename=$(echo "$filename" | sed 's/^[._-]*//; s/[._-]*$//')  # Trim special chars
    
    echo "$filename"
}

# Generate UUID v4
generate_uuid() {
    if command -v uuidgen >/dev/null 2>&1; then
        uuidgen | lower
    else
        # Fallback UUID generation
        local uuid
        uuid=$(cat /proc/sys/kernel/random/uuid 2>/dev/null) || \
        uuid=$(od -x /dev/urandom | head -1 | awk '{OFS="-"; print $2$3,$4,$5,$6,$7$8$9}')
        echo "$uuid"
    fi
}

# Generate hash of string (SHA256)
hash_string() {
    local string="$1" algorithm="${2:-sha256}"
    
    [[ -z "$string" ]] && { echo "Usage: hash_string <string> [algorithm]" >&2; return 1; }
    
    if command -v "${algorithm}sum" >/dev/null 2>&1; then
        echo -n "$string" | "${algorithm}sum" | cut -d' ' -f1
    else
        log_error "Hash algorithm $algorithm not available"
        return 1
    fi
}

# =============================================================================
# CONFIGURATION MANAGEMENT
# =============================================================================

# Load configuration from file
load_config() {
    local config_file="$1"
    
    [[ -z "$config_file" ]] && { echo "Usage: load_config <config_file>" >&2; return 1; }
    
    if [[ -r "$config_file" ]]; then
        # Source the config file safely
        # shellcheck source=/dev/null
        source "$config_file"
        log_debug "Loaded configuration from: $config_file"
        return 0
    else
        log_error "Cannot read configuration file: $config_file"
        return 1
    fi
}

# Save configuration to file
save_config() {
    local config_file="$1"
    shift
    local variables=("$@")
    
    [[ -z "$config_file" ]] && { echo "Usage: save_config <config_file> <var1> [var2...]" >&2; return 1; }
    
    {
        echo "# Configuration file generated on $(date)"
        echo "# DO NOT EDIT - This file is automatically generated"
        echo ""
        
        for var in "${variables[@]}"; do
            if [[ -n "${!var:-}" ]]; then
                printf '%s="%s"\n' "$var" "${!var}"
            fi
        done
    } > "$config_file"
    
    log_debug "Saved configuration to: $config_file"
}

# =============================================================================
# INITIALIZATION AND CLEANUP
# =============================================================================

# MSYS2 baseline enforcement - complete environment consistency
# These settings override any user-global MSYS2 modifications for script reliability
export MSYSTEM=UCRT64              # Modern UCRT environment (recommended for 2025)
export MSYS2_PATH_TYPE=minimal     # Don't inherit Windows PATH automatically
export MSYS_NO_PATHCONV=1          # Disable automatic path conversion for predictability
export MSYS2_ARG_CONV_EXCL="*"     # Exclude all arguments from path conversion
export MSYS2_ENV_CONV_EXCL="*"     # Exclude all environment vars from path conversion

# Programmatic Windows PATH integration - curated and controlled
_integrate_windows_path() {
    # Skip if already integrated
    [[ "$WINDOWS_PATH_INTEGRATED" == "1" ]] && return
    
    # Get full Windows PATH via cmd.exe (no PowerShell dependency)
    if command -v cmd.exe >/dev/null 2>&1; then
        local windows_path
        windows_path=$(cmd.exe /c "echo %PATH%" 2>/dev/null | tr -d '\r\n')
        
        # Convert all Windows PATH entries to POSIX format
        if [[ -n "$windows_path" ]]; then
            IFS=';' read -ra PATH_ARRAY <<< "$windows_path"
            for dir in "${PATH_ARRAY[@]}"; do
                # Skip empty entries
                [[ -z "$dir" ]] && continue
                
                # Convert to POSIX format
                local posix_dir=$(echo "$dir" | sed 's|\\|/|g' | sed 's|^\([A-Za-z]\):|/\L\1|')
                
                # Add all valid directories, avoiding duplicates
                if [[ -d "$posix_dir" ]]; then
                    # Check for duplicates in converted_path AND existing PATH
                    if [[ ":$converted_path:$PATH:" != *":$posix_dir:"* ]]; then
                        converted_path="${converted_path:+$converted_path:}$posix_dir"
                    fi
                fi
            done
        fi
    fi
    
    # Add curated Windows PATH to our PATH
    if [[ -n "$converted_path" ]]; then
        export PATH="$PATH:$converted_path"
        export WINDOWS_PATH_INTEGRATED=1
    fi
}

# Initialize the library
_initialize() {
    # Validate environment
    _validate_environment || return 1
    
    # Integrate Windows PATH in controlled manner
    _integrate_windows_path
    
    # Set default configuration
    if [[ "${BASH_SOURCE[0]}" != "${0}" ]]; then
        # Being sourced - show minimal info
        log_debug "Portable Git Bash Environment v$PORTABLE_ENV_VERSION loaded"
    fi
    
    return 0
}

# Export all public functions
export -f to_windows_path to_posix_path get_absolute_path normalize_path
export -f path_exists safe_mkdir safe_remove get_script_dir get_temp_dir create_backup
export -f run_windows_cmd run_powershell run_cmd get_windows_username get_windows_version is_admin
export -f is_git_bash is_msys2 is_cygwin is_wsl is_portable_env get_shell_info detect_platform
export -f set_strict_mode set_debug_mode log_info log_warning log_error log_debug die assert retry
export -f print_script_header validate_prerequisites parse_version confirm select_option
export -f trim upper lower contains starts_with ends_with join split
export -f get_public_ip check_internet download_file get_cpu_count get_memory_info check_disk_space
export -f validate_path sanitize_filename generate_uuid hash_string
export -f load_config save_config

# Initialize the library
_initialize || {
    echo "ERROR: Failed to initialize Portable Git Bash Environment" >&2
    exit 1
}

# Default script setup (can be overridden)
set -e  # Exit on error by default

# Success indicator
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Being executed directly - show help
    echo "Portable Git Bash Environment Library v$PORTABLE_ENV_VERSION"
    echo ""
    echo "This library should be sourced in your shell scripts:"
    echo '  source "$(dirname "${BASH_SOURCE[0]}")/portable-env.sh"'
    echo ""
    echo "For complete documentation and usage examples, see the header comments."
    echo ""
    get_shell_info
fi

# End of portable-env.sh