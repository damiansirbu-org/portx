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
LAST_GIT_DIR=""

# Fast git status using gitstatusd or fallback
update_git_status() {
    # Check if git state changed (not just directory)
    local should_update=false
    
    # Always update if directory changed
    if [[ "$PWD" != "$LAST_PWD" ]]; then
        should_update=true
        LAST_PWD="$PWD"
    fi
    
    # Also update if in git repo and HEAD/index changed
    if [[ "$should_update" == "false" ]] && git rev-parse --git-dir &>/dev/null 2>&1; then
        local git_dir=$(git rev-parse --git-dir 2>/dev/null)
        local cache_file="$HOME/.git_prompt_cache"
        if [[ "$git_dir/HEAD" -nt "$cache_file" ]] || 
           [[ "$git_dir/index" -nt "$cache_file" ]] 2>/dev/null; then
            should_update=true
            touch "$cache_file" 2>/dev/null
        fi
    fi
    
    # Skip if no update needed
    [[ "$should_update" == "false" ]] && return
    
    # Check if we're in a git repo (fast check)
    local current_git_dir
    current_git_dir=$(git rev-parse --git-dir 2>/dev/null)
    if [[ -z "$current_git_dir" ]]; then
        GIT_STATUS_CACHED=""
        return
    fi
    
    # Reset cache if we changed git repositories
    if [[ "$current_git_dir" != "$LAST_GIT_DIR" ]]; then
        LAST_GIT_DIR="$current_git_dir"
        should_update=true
        rm -f "$HOME/.git_prompt_cache" 2>/dev/null
    fi
    
    # Use fast git commands (gitstatusd has timeout issues)
    local branch=$(git branch --show-current 2>/dev/null || echo "detached")
    local status=$(git status --porcelain 2>/dev/null)
    
    if [[ -n "$status" ]]; then
        GIT_STATUS_CACHED=$(printf ' %b[%s]%b' "$(color_error)" "${branch}" "$(color_reset)")
    else
        GIT_STATUS_CACHED=$(printf ' %b[%s]%b' "$(color_pale_green)" "${branch}" "$(color_reset)")
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
