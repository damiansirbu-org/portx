# SSH Agent Management (Windows OpenSSH integrated)
#
# Load theme system for consistent colors
# shellcheck source=/dev/null
source "$PORTX_HOME/scripts/theme.sh"
#
# INTEGRATION STRATEGY: PORTX is source of truth, syncs to Windows
# - PORTX keys: /home/portx/.ssh/ (C:\App\PORTX\home\portx\.ssh\) - SOURCE OF TRUTH
# - Windows keys: %USERPROFILE%\.ssh\ (C:\Users\[user]\.ssh\) - SYNCED FROM PORTX
# - Automatic sync: PORTX keys → Windows location for system-wide SSH
#
# WINDOWS OPENSSH SERVICE (Recommended for best performance):
# 1. Run as admin: Set-Service ssh-agent -StartupType Automatic
# 2. Run as admin: Start-Service ssh-agent  
# 3. PORTX will detect running service and sync keys automatically
# 4. All applications (VS Code, Git GUI, etc.) use the same SSH agent

# Function to sync PORTX keys to Windows OpenSSH location
sync_portx_keys_to_windows() {
    local windows_ssh="$USERPROFILE/.ssh"
    local portx_ssh="$HOME/.ssh"
    
    # Create Windows .ssh directory if it doesn't exist
    [[ ! -d "$windows_ssh" ]] && mkdir -p "$windows_ssh" 2>/dev/null
    
    # PORTX is source of truth - copy PORTX keys to Windows location
    for key in id_rsa id_ed25519 id_ecdsa; do
        if [[ -f "$portx_ssh/$key" ]]; then
            # Copy PORTX key to Windows if Windows doesn't have it or PORTX is newer
            if [[ ! -f "$windows_ssh/$key" ]] || [[ "$portx_ssh/$key" -nt "$windows_ssh/$key" ]]; then
                cp "$portx_ssh/$key" "$windows_ssh/$key" 2>/dev/null
                cp "$portx_ssh/$key.pub" "$windows_ssh/$key.pub" 2>/dev/null
                chmod 600 "$windows_ssh/$key" 2>/dev/null
                chmod 644 "$windows_ssh/$key.pub" 2>/dev/null
            fi
        fi
    done
}

# Simple SSH agent startup
ssh_agent_start() {
    # Always sync PORTX keys to Windows location first
    sync_portx_keys_to_windows
    
    # Load existing agent environment if available
    local ssh_env_file="$HOME/.ssh/agent.env"
    if [[ -f "$ssh_env_file" ]]; then
        source "$ssh_env_file" > /dev/null
    fi
    
    # Check if ssh-agent is already running and accessible
    if [[ -n "$SSH_AUTH_SOCK" ]] && ssh-add -l >/dev/null 2>&1; then
        # Agent running - add our keys if needed
        for key in ~/.ssh/id_rsa ~/.ssh/id_ed25519 ~/.ssh/id_ecdsa; do
            if [[ -f "$key" ]]; then
                ssh-add "$key" 2>/dev/null
            fi
        done
        return 0
    fi
    
    # Only cleanup if we have a broken agent environment
    if [[ -n "$SSH_AUTH_SOCK" ]]; then
        echo "PORTX SSH: Cleaning broken agent environment (sock: $SSH_AUTH_SOCK)" >&2
        unset SSH_AUTH_SOCK SSH_AGENT_PID
    fi
    
    # Start new ssh-agent
    ssh-agent > "$ssh_env_file" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        chmod 600 "$ssh_env_file"
        source "$ssh_env_file" > /dev/null
        
        # Add PORTX keys
        for key in ~/.ssh/id_rsa ~/.ssh/id_ed25519 ~/.ssh/id_ecdsa; do
            if [[ -f "$key" ]]; then
                ssh-add "$key" 2>/dev/null
            fi
        done
    fi
}

# Set SSH status for display
set_ssh_status() {
    if [[ $- == *i* ]]; then
        if ssh-add -l >/dev/null 2>&1; then
            # SSH agent working - get cached user info
            local cached_user_file="$HOME/.ssh/cached_user"
            local key_users=""
            
            if [[ -f "$cached_user_file" ]]; then
                key_users=$(cat "$cached_user_file" 2>/dev/null)
            else
                # Cache user info from first available key
                for pub_key in ~/.ssh/id_*.pub; do
                    if [[ -f "$pub_key" ]]; then
                        comment=$(tail -1 "$pub_key" 2>/dev/null | awk '{print $NF}')
                        if [[ "$comment" == *"@"* ]]; then
                            key_users="$comment"
                            echo "$comment" > "$cached_user_file"
                            break
                        fi
                    fi
                done
            fi
            
            if [[ -n "$key_users" ]]; then
                # Export structured data
                export PORTX_SSH_USER="$key_users"
                export PORTX_SSH_STATUS="authenticated"
                # Legacy compatibility
                export SSH_STATUS="$(color_info)Ssh$(color_reset)$(color_muted)[$key_users]$(color_reset)"
            else
                # Export structured data  
                export PORTX_SSH_STATUS="active"
                # Legacy compatibility
                export SSH_STATUS="$(color_info)Ssh$(color_reset)$(color_muted)[active]$(color_reset)"
            fi
        else
            # Export structured data
            export PORTX_SSH_STATUS="no agent"
            # Legacy compatibility
            export SSH_STATUS="$(color_error)Ssh$(color_reset)$(color_muted)[no agent]$(color_reset)"
        fi
    fi
}

# Start ssh-agent if SSH directory exists
if [[ -d "$HOME/.ssh" ]]; then
    ssh_agent_start
    set_ssh_status
else
    # No SSH directory - warn user
    if [[ $- == *i* ]]; then
        # Export structured data
        export PORTX_SSH_STATUS="no ~/.ssh"
        # Legacy compatibility
        export SSH_STATUS="$(color_error)Ssh$(color_reset)$(color_muted)[no ~/.ssh]$(color_reset)"
    fi
fi

# SSH agent setup complete