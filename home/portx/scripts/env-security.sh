#!/bin/bash
# Environment Security Check - detect PATH conflicts
# PURPOSE: Warn about external shell installations that conflict with Git Bash
# FEATURES: Simple PATH scanning, no cache dependencies

# Load theme system for consistent colors - let it crash if not found
# shellcheck source=/dev/null
source "$PORTX_HOME/scripts/theme.sh"

check_environment_security() {
    # Only check PATH for external shell conflicts
    local dangerous_patterns=(
        # External MSYS2 installations
        "msys64" "C:\\msys64" "/c/msys64"
        # External Cygwin installations  
        "cygwin64" "C:\\cygwin64" "/c/cygwin64" "C:\\cygwin" "/c/cygwin"
        # WSL path mixing
        "/mnt/c/Program Files" "/mnt/c/Windows" "wsl$"
    )
    
    local found_issues=()
    
    # Scan PATH for conflicts
    for pattern in "${dangerous_patterns[@]}"; do
        if [[ "$PATH" == *"$pattern"* ]]; then
            found_issues+=("$pattern")
        fi
    done
    
    # Show warnings if issues found
    if [[ ${#found_issues[@]} -gt 0 ]]; then
        echo "$(icon_warning) GIT BASH PATH CONFLICTS DETECTED $(icon_warning)" >&2
        for issue in "${found_issues[@]}"; do
            echo "  $(icon_error) PATH contains: '$issue'" >&2
        done
        echo "$(icon_statistics) FIX: Remove conflicting paths from Windows PATH" >&2
        echo "" >&2
        return 1
    fi
    return 0
}

get_environment_info() {
    env_info=""
    
    # Detect environment type
    if [[ -n "$MSYSTEM" ]]; then
        env_info="MSYS2-$MSYSTEM"
    elif [[ -n "$CYGWIN" ]]; then
        env_info="Cygwin"
    elif [[ "$OSTYPE" == "msys" ]]; then
        env_info="MSYS"
    elif [[ -n "$WSL_DISTRO_NAME" ]]; then
        env_info="WSL-$WSL_DISTRO_NAME"
    else
        env_info="Unknown"
    fi
    
    # Add terminal type if available
    if [[ -n "$TERM" ]]; then
        env_info="$env_info/$TERM"
    fi
    
    echo "$env_info"
}

# Run security check on startup (disable with NO_ENV_CHECK=1)
if [[ "$NO_ENV_CHECK" != "1" ]]; then
    # Set PORTX_ENV_TYPE for formatting functions
    export PORTX_ENV_TYPE="$(get_environment_info)"
    
    # Display system status using formatting functions
    if check_environment_security; then
        format_portx_status >&2
    else
        # For error state, use error color but same format
        local env_info="${PORTX_ENV_TYPE:-unknown}"
        printf '%bPortx%b%b[%s]%b' "$(color_error)" "$(color_reset)" "$(color_muted)" "${env_info,,}" "$(color_reset)" >&2
    fi
    
    # Show TOOLS status using formatting function
    if [[ -n "$PORTX_MINGW_EXECUTABLES" || -n "$PORTX_BIN_EXECUTABLES" || -n "$PORTX_PKG_EXECUTABLES" ]]; then
        printf " " >&2
        format_tools_status >&2
    fi
    
    # Show SSH status using formatting function or legacy variable
    if [[ -n "$PORTX_SSH_USER" || -n "$PORTX_SSH_STATUS" ]]; then
        printf " " >&2
        format_ssh_status >&2
    elif [[ -n "$SSH_STATUS" ]]; then
        printf " %b" "$SSH_STATUS" >&2
    fi
    
    printf "\n" >&2
fi