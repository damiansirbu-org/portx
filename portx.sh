#!/bin/bash
# PORTX 2.0 Universal Package Manager
# Cross-platform entry point for PORTX operations

# Detect environment and set paths accordingly
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    # WSL environment
    PORTX_ROOT="/mnt/c/App/PORTX"
elif [[ -n "${MSYSTEM:-}" ]]; then
    # MSYS2/Git Bash environment
    PORTX_ROOT="/c/App/PORTX"
elif [[ -n "${CYGWIN:-}" ]] || command -v cygpath >/dev/null 2>&1; then
    # Cygwin environment
    PORTX_ROOT="/cygdrive/c/App/PORTX"
else
    # Native Linux/Unix - assume mounted or direct path
    PORTX_ROOT="/mnt/c/App/PORTX"
fi

# Convert to Windows path for PowerShell
if command -v wslpath >/dev/null 2>&1; then
    # WSL - use wslpath
    WIN_PORTX_ROOT="$(wslpath -w "$PORTX_ROOT")"
elif command -v cygpath >/dev/null 2>&1; then
    # Cygwin - use cygpath
    WIN_PORTX_ROOT="$(cygpath -w "$PORTX_ROOT")"
else
    # MSYS2/Git Bash or fallback - simple conversion
    WIN_PORTX_ROOT="${PORTX_ROOT//\/c\//C:\\}"
    WIN_PORTX_ROOT="${WIN_PORTX_ROOT//\//\\}"
fi

SCRIPT_PATH="$WIN_PORTX_ROOT\\ps\\portx-import.ps1"

show_help() {
    cat << 'EOF'
PORTX 2.0 Universal Package Manager

Usage: portx <command> [options]

Commands:
  import [package]     Import all packages or specific package
  list                 List all available packages and tools
  help                 Show this help message

Options:
  --clean              Remove all existing wrappers before import

Examples:
  portx import            Import all packages
  portx import --clean    Import all packages (clean first)
  portx import git        Import only git package
  portx list              Show all packages

Cross-platform compatible: Windows, WSL, Cygwin, MSYS2, Linux containers
EOF
}

# Handle arguments
COMMAND="${1:-}"
shift || true

case "$COMMAND" in
    ""|"help"|"-h"|"--help")
        show_help
        exit 0
        ;;
    "import")
        # Check for --clean flag in remaining arguments
        CLEAN_FLAG=""
        PACKAGE_NAME=""
        EXTRA_ARGS=()

        for arg in "$@"; do
            case "$arg" in
                "--clean")
                    CLEAN_FLAG="-Clean"
                    ;;
                -*)
                    EXTRA_ARGS+=("$arg")
                    ;;
                *)
                    if [[ -z "$PACKAGE_NAME" ]]; then
                        PACKAGE_NAME="$arg"
                    else
                        EXTRA_ARGS+=("$arg")
                    fi
                    ;;
            esac
        done

        # Build PowerShell command
        PS_ARGS=()
        if [[ -n "$PACKAGE_NAME" ]]; then
            PS_ARGS+=("-PackageName" "$PACKAGE_NAME")
        fi
        if [[ -n "$CLEAN_FLAG" ]]; then
            PS_ARGS+=("$CLEAN_FLAG")
        fi
        PS_ARGS+=("${EXTRA_ARGS[@]}")

        # Execute PowerShell Core script from PORTX packages (modern cross-platform PowerShell)
        "$PORTX_ROOT/packages/powershell-core/pwsh.exe" -ExecutionPolicy Bypass -File "$SCRIPT_PATH" "${PS_ARGS[@]}"
        ;;
    "list")
        # TODO: Implement list functionality
        echo "List functionality not yet implemented"
        exit 1
        ;;
    *)
        echo "Unknown command: $COMMAND"
        echo
        show_help
        exit 1
        ;;
esac