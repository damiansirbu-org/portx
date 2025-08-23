# PS1 Prompt Module - Optimized with gitstatusd
# PURPOSE: Fast two-line prompt with cached git status
# FEATURES: Git repository state with color coding using theme system
# DESIGN: Line 1: path + git branch, Line 2: $ prompt

# Load theme system for consistent colors - let it crash if not found
# shellcheck source=/dev/null
source "$PORTX_HOME/scripts/theme.sh"

# Git status variables (updated by PROMPT_COMMAND)
GIT_STATUS_CACHED=""
LAST_PWD=""

# Fast git status using gitstatusd or fallback
update_git_status() {
    # Only update if directory changed
    if [[ "$PWD" == "$LAST_PWD" ]]; then
        return
    fi
    LAST_PWD="$PWD"
    
    # Check if we're in a git repo (fast check)
    if ! git rev-parse --git-dir &>/dev/null 2>&1; then
        GIT_STATUS_CACHED=""
        return
    fi
    
    # Try gitstatusd first (much faster)
    if command -v gitstatusd >/dev/null 2>&1; then
        local req_id="ps1"
        local response
        response=$(echo -nE "${req_id}"$'\x1f'"${PWD}"$'\x1e' | gitstatusd 2>/dev/null | head -1)
        
        if [[ -n "$response" ]]; then
            IFS=$'\x1f' read -ra resp <<< "$response"
            if [[ "${resp[1]}" == "1" ]]; then  # Is git repo
                local branch="${resp[4]}"
                local staged="${resp[10]}"
                local unstaged="${resp[11]}"
                local untracked="${resp[13]}"
                
                if [[ "$staged" != "0" || "$unstaged" != "0" || "$untracked" != "0" ]]; then
                    GIT_STATUS_CACHED=$(printf ' %b[%s]%b' "$(color_error)" "${branch}" "$(color_reset)")
                else
                    GIT_STATUS_CACHED=$(printf ' %b[%s]%b' "$(color_success)" "${branch}" "$(color_reset)")
                fi
                return
            fi
        fi
    fi
    
    # Fallback to regular git commands
    local branch=$(git branch --show-current 2>/dev/null || echo "detached")
    local status=$(git status --porcelain 2>/dev/null)
    
    if [[ -n "$status" ]]; then
        GIT_STATUS_CACHED=$(printf ' %b[%s]%b' "$(color_error)" "${branch}" "$(color_reset)")
    else
        GIT_STATUS_CACHED=$(printf ' %b[%s]%b' "$(color_success)" "${branch}" "$(color_reset)")
    fi
}

# Set up PROMPT_COMMAND to update git status
PROMPT_COMMAND="update_git_status${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

# Set PS1 using cached variables (with proper variable expansion)
if [[ "$NO_COLOR" == "1" ]]; then
    export PS1='$PWD$GIT_STATUS_CACHED\n$ '
else
    # Pre-evaluate color codes and wrap them properly for PS1
    PS1_COLOR_WHITE="\[$(color_primary)\]"
    PS1_COLOR_RESET="\[$(color_reset)\]"
    export PS1="${PS1_COLOR_WHITE}\$PWD${PS1_COLOR_RESET}\$GIT_STATUS_CACHED\n\$ "
fi

# PS1 configuration loaded
