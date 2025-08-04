# SSH Agent Management

# Function to start or connect to ssh-agent
ssh_agent_start() {
    local ssh_env_file="$HOME/.ssh/agent.env"
    local ssh_success=false
    
    # Check if ssh-agent is already running
    if [[ -f "$ssh_env_file" ]]; then
        source "$ssh_env_file" > /dev/null
        if ps -p $SSH_AGENT_PID > /dev/null 2>&1; then
            # Agent running - check if keys are loaded
            if ssh-add -l >/dev/null 2>&1 && ! ssh-add -l | grep -q "no identities"; then
                ssh_success=true
            fi
        fi
    fi
    
    # Start new ssh-agent if not running or no keys
    if [[ "$ssh_success" != "true" ]]; then
        ssh-agent > "$ssh_env_file" 2>/dev/null
        if [[ $? -eq 0 ]]; then
            chmod 600 "$ssh_env_file"
            source "$ssh_env_file" > /dev/null
            
            # Add default keys if they exist
            for key in ~/.ssh/id_rsa ~/.ssh/id_ed25519 ~/.ssh/id_ecdsa; do
                if [[ -f "$key" ]]; then
                    ssh-add "$key" 2>/dev/null && ssh_success=true
                fi
            done
        fi
    fi
    
    # Store SSH status for display (will be shown by env-security.sh)
    if [[ $- == *i* ]]; then
        if [[ "$ssh_success" == "true" ]]; then
            local key_count=$(ssh-add -l 2>/dev/null | wc -l | tr -d ' ')
            local key_users=""
            
            # Extract user info from SSH public key files
            if [[ $key_count -gt 0 ]]; then
                key_users=""
                for pub_key in ~/.ssh/id_*.pub; do
                    if [[ -f "$pub_key" ]]; then
                        comment=$(tail -c 100 "$pub_key" 2>/dev/null | grep -oE '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}|[a-zA-Z][a-zA-Z0-9._-]*' | tail -1)
                        if [[ -n "$comment" && "$comment" != *"ED25519"* && "$comment" != *"RSA"* ]]; then
                            if [[ -z "$key_users" ]]; then
                                key_users="$comment"
                            else
                                key_users="$key_users,$comment"
                            fi
                        fi
                    fi
                done
                if [[ -n "$key_users" ]]; then
                    export SSH_STATUS="\033[1;90mSSH\033[0m\033[90m($key_users)\033[0m"
                else
                    export SSH_STATUS="\033[1;90mSSH\033[0m"
                fi
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