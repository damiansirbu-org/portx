#!/bin/bash
# Portable Script Template
# ========================
#
# Copy this template for all your scripts to ensure portability
# This script will work identically on any Git Bash installation
#
# Usage: ./script-template.sh [arguments]

# REQUIRED: Source portable environment (works from any location)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/portable-env.sh"

# Optional: Enable strict mode for better error handling
set_strict_mode

# Script Configuration
# ===================
SCRIPT_NAME="Example Portable Script"
SCRIPT_DESCRIPTION="Demonstrates comprehensive portable environment features"

# Prerequisites check
validate_prerequisites "git.exe" "powershell.exe"

# Script Header
print_script_header "$SCRIPT_NAME" "$SCRIPT_DESCRIPTION"

# Main Script Logic
# =================

main() {
    log_info "Starting script execution"
    
    # Example 1: Working with paths
    local project_dir="/c/App/PORTX"
    log_info "Project directory (POSIX): $project_dir"
    log_info "Project directory (Windows): $(to_windows_path "$project_dir")"
    
    # Example 2: PowerShell commands with POSIX paths
    log_info "Running PowerShell command with POSIX path..."
    run_powershell -Command "Get-ChildItem $(to_windows_path "$project_dir") | Select-Object -First 5 | Format-Table Name,Length"
    
    # Example 3: File operations
    local temp_file="/tmp/portx-test.txt"
    echo "Hello from PORTX script!" > "$temp_file"
    
    if path_exists "$temp_file"; then
        log_info "Created temporary file: $temp_file"
        log_info "Absolute path: $(get_absolute_path "$temp_file")"
    fi
    
    # Example 4: Cross-platform directory creation
    local output_dir="/tmp/portx-output"
    safe_mkdir "$output_dir"
    log_info "Created output directory: $output_dir"
    
    # Example 5: Git operations (always work with POSIX paths)
    if path_exists "/c/Work/Git"; then
        log_info "Git repositories directory exists"
        # Git commands work with POSIX paths automatically
        # git.exe clone https://github.com/user/repo.git "/c/Work/Git/new-repo"
    fi
    
    # Example 6: Environment detection
    if is_portable_env; then
        log_info "Running in portable environment"
    else
        log_warning "Not running in portable environment"
    fi
    
    if is_git_bash; then
        log_info "Running in Git Bash"
    else
        log_warning "Not running in Git Bash"
    fi
    
    # Cleanup
    rm -f "$temp_file"
    rmdir "$output_dir" 2>/dev/null || true
    
    log_info "Script completed successfully"
}

# Error handling
handle_error() {
    local exit_code=$?
    log_error "Script failed with exit code: $exit_code"
    exit $exit_code
}

trap handle_error ERR

# Execute main function
main "$@"