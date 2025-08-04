# Environment Security Check - detect PATH conflicts
# PURPOSE: Warn about external shell installations that conflict with Git Bash
# FEATURES: Simple PATH scanning, no cache dependencies

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
        echo "⚠️  GIT BASH PATH CONFLICTS DETECTED ⚠️" >&2
        for issue in "${found_issues[@]}"; do
            echo "  ❌ PATH contains: '$issue'" >&2
        done
        echo "🔧 FIX: Remove conflicting paths from Windows PATH" >&2
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
    env_info=$(get_environment_info)
    if check_environment_security; then
        printf "\033[1;90mPORTX\033[0m\033[90m($env_info)\033[0m" >&2
    else
        printf "\033[1;31mPORTX\033[0m\033[90m($env_info)\033[0m" >&2
    fi
    
    # Show TOOLS and SSH status on same line if available
    if [[ -n "$TOOLS_STATUS" ]]; then
        printf " %b" "$TOOLS_STATUS" >&2
    fi
    if [[ -n "$SSH_STATUS" ]]; then
        printf " %b" "$SSH_STATUS" >&2
    fi
    
    printf "\n" >&2
fi