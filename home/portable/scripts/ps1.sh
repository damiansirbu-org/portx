# PS1 Prompt Module
# PURPOSE: Two-line prompt with path and git branch
# FEATURES: Git repository state with color coding
# DESIGN: Line 1: path + git branch, Line 2: $ prompt

# Define colors for PS1 (will be expanded when PS1 is set)
RED='\[\033[0;31m\]'
GREEN='\[\033[0;32m\]'
YELLOW='\[\033[0;33m\]'
BYELLOW='\[\033[1;33m\]'
WHITE='\[\033[0;37m\]'
RESET='\[\033[0m\]'


# Path formatting removed - using $PWD directly in PS1


# Git branch status with color coding
function git_status() {
    if ! git rev-parse --git-dir &>/dev/null; then
        return  # Not in a git repo
    fi
    
    local branch=$(git branch --show-current 2>/dev/null || echo "detached")
    local status=$(git status --porcelain 2>/dev/null)
    
    local result
    if [[ -n "$status" ]]; then
        result=" RED[${branch}]RESET"
    else
        result=" GREEN[${branch}]RESET"  
    fi
    
    echo "$result"
}

# Set PS1 with adaptive coloring (two lines)
if [[ "$NO_COLOR" == "1" ]]; then
    # No color version  
    export PS1="\$PWD\$(git_status | sed 's/[A-Z]*//g')
$ "
else
    # Color version (two lines)
    export PS1="${WHITE}\$PWD${RESET}\$(git_status | sed \"s/RED/${RED}/g; s/GREEN/${GREEN}/g; s/YELLOW/${YELLOW}/g; s/WHITE/${WHITE}/g; s/RESET/${RESET}/g\")
$ "
fi

# PS1 configuration loaded