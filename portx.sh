#!/bin/bash
# PORTX 2.0 Universal Package Manager

# Detect environment for PowerShell path
if [[ -n "${WSL_DISTRO_NAME:-}" ]]; then
    PORTX_ROOT="/mnt/c/App/PORTX"
elif [[ -n "${MSYSTEM:-}" ]]; then
    PORTX_ROOT="/c/App/PORTX"
elif [[ -n "${CYGWIN:-}" ]] || command -v cygpath >/dev/null 2>&1; then
    PORTX_ROOT="/cygdrive/c/App/PORTX"
else
    PORTX_ROOT="/mnt/c/App/PORTX"
fi

# Execute PowerShell script with all arguments
"$PORTX_ROOT/packages/powershell-core/pwsh.exe" -ExecutionPolicy Bypass -File "$PORTX_ROOT/ps/portx-import.ps1" "$@"