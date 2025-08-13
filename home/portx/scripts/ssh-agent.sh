# SSH Agent Management (Windows OpenSSH integrated)
#
# INTEGRATION STRATEGY: PORTX is source of truth, syncs to Windows
# - PORTX keys: /home/portx/.ssh/ (C:\App\PORTX\home\portx\.ssh\) - SOURCE OF TRUTH
# - Windows keys: %USERPROFILE%\.ssh\ (C:\Users\[user]\.ssh\) - SYNCED FROM PORTX
# - Automatic sync: PORTX keys → Windows location for system-wide SSH
#
# WINDOWS OPENSSH SERVICE (Recommended for best performance):
# 1. Run as admin: Set-Service ssh-agent -StartupType Automatic
# 2. Run as admin: Start-Service ssh-agent  
# 3. PORTX keys automatically synced and loaded into Windows service
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

# Function to start or connect to ssh-agent
ssh_agent_start() {
    local ssh_success=false
    
    # Method 1: Check if ANY ssh-agent is running (Windows service or Git Bash)
    if ssh-add -l >/dev/null 2>&1; then
        # Agent is running with keys - assume PORTX keys are there
        ssh_success=true
        
        # For Windows OpenSSH service: ensure keys are synced and loaded
        sync_portx_keys_to_windows
        
        # Use a marker file to avoid repeated key addition
        local key_marker="$HOME/.ssh/.portx_keys_added"
        if [[ ! -f "$key_marker" ]]; then
            # Load from PORTX location (source of truth)
            for key in "$HOME/.ssh/id_rsa" "$HOME/.ssh/id_ed25519" "$HOME/.ssh/id_ecdsa"; do
                if [[ -f "$key" ]]; then
                    ssh-add "$key" 2>/dev/null && touch "$key_marker"
                fi
            done
        fi
    else
        # Method 2: Try to connect to existing Git Bash ssh-agent
        local ssh_env_file="$HOME/.ssh/agent.env"
        if [[ -f "$ssh_env_file" ]]; then
            source "$ssh_env_file" > /dev/null 2>&1
            if ssh-add -l >/dev/null 2>&1; then
                ssh_success=true
            fi
        fi
    fi
    
    # Start new ssh-agent if not running or no keys
    if [[ "$ssh_success" != "true" ]]; then
        # Ensure PORTX keys are synced to Windows before starting agent
        sync_portx_keys_to_windows
        
        ssh-agent > "$ssh_env_file" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            chmod 600 "$ssh_env_file"
            source "$ssh_env_file" > /dev/null
            
            # Add PORTX keys (source of truth)
            for key in ~/.ssh/id_rsa ~/.ssh/id_ed25519 ~/.ssh/id_ecdsa; do
                if [[ -f "$key" ]]; then
                    ssh-add "$key" 2>/dev/null && ssh_success=true
                fi
            done
        fi
    fi
    
    # Store SSH status for display (optimized - cache user info)
    if [[ $- == *i* ]]; then
        if [[ "$ssh_success" == "true" ]]; then
            # Use cached user info if available, otherwise extract once
            local cached_user_file="$HOME/.ssh/cached_user"
            local key_users=""
            
            if [[ -f "$cached_user_file" && -n "$(cat "$cached_user_file" 2>/dev/null)" ]]; then
                # Use cached user info (much faster)
                key_users=$(cat "$cached_user_file")
            else
                # Extract user info only once and cache it
                for pub_key in ~/.ssh/id_*.pub; do
                    if [[ -f "$pub_key" ]]; then
                        # Faster extraction - just get the last word from the key
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
                export SSH_STATUS="\033[1;90mSSH\033[0m\033[90m($key_users)\033[0m"
            else
                export SSH_STATUS="\033[1;90mSSH\033[0m"
            fi
        else
            export SSH_STATUS="\033[1;31mSSH\033[0m\033[90m(no keys)\033[0m"
        fi
    fi
}

# Start ssh-agent if SSH directory exists (always available for git operations)
if [[ -d "$HOME/.ssh" ]]; then
    ssh_agent_start
else
    # No SSH directory - warn user
    if [[ $- == *i* ]]; then
        export SSH_STATUS="\033[1;31mSSH\033[0m\033[90m(no ~/.ssh)\033[0m"
    fi
fi

# SSH agent setup complete