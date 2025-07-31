# Git Bash Configuration
# Static environment variables (set once per shell)

# ⚠️ WARNING: DO NOT SET USER OR HOME VARIABLES HERE! ⚠️
# The portable Git Bash launcher (git-bash-portable.bat) sets:
#   HOME=/home/portable
#   USER=portable
#   USERNAME=portable
# 
# If you add lines like "export USER=$(whoami)" or "export HOME=/home/$USER"
# they will OVERRIDE the portable settings and break the portable functionality!
# The whole point of portable mode is to NOT use Windows user-specific paths.
#


# Git Bash specific Claude Code configuration
export CLAUDE_CODE_GIT_BASH_PATH="C:\App\Git\bin\bash.exe"

# Terminal and Shell configuration
export TERM=xterm-256color
export SHELL="/bin/bash"

# Git Bash specific settings
unset TMP TEMP  # Prevent Windows temp directory conflicts
export TMPDIR=/tmp

# Locale settings for proper UTF-8 support
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Development environment
export EDITOR=vim
export PAGER=less

# History configuration (optimized for performance)
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=-1
export HISTFILESIZE=-1
export HISTTIMEFORMAT="[%F %T] "
export HISTCONTROL=ignoredups:erasedups
shopt -s histappend

# Write history immediately after each command
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# Path additions for development tools
if [[ -d "$HOME/bin" ]]; then
    export PATH="$HOME/bin:$PATH"
fi

if [[ -d "$HOME/.local/bin" ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi


# Color definitions for prompts and output
Color_Off='\[\033[0m\]'
Red='\[\033[0;31m\]'
Green='\[\033[0;32m\]'
Yellow='\[\033[0;33m\]'
Blue='\[\033[0;34m\]'
Purple='\[\033[0;35m\]'
Cyan='\[\033[0;36m\]'
White='\[\033[0;37m\]'
BRed='\[\033[1;31m\]'
BGreen='\[\033[1;32m\]'
BYellow='\[\033[1;33m\]'
BBlue='\[\033[1;34m\]'
BPurple='\[\033[1;35m\]'
BCyan='\[\033[1;36m\]'
BWhite='\[\033[1;37m\]'

# Common aliases
alias ls='ls --color=auto'
alias k=kubectl
alias kk='kubectl config current-context'

# Bash completion configuration (interactive shells only)
if [[ $- == *i* ]]; then
    # Enable programmable completion
    shopt -s progcomp 2>/dev/null
    
    # Load Git for Windows completion if available
    if [[ -f /mingw64/share/git/completion/git-completion.bash ]]; then
        source /mingw64/share/git/completion/git-completion.bash
    fi
    
    # Load system bash completion if available
    for f in /usr/share/bash-completion/bash_completion /etc/bash_completion; do
        if [[ -f "$f" ]]; then
            source "$f"
            break
        fi
    done
    
    # Case-insensitive filename completion (Windows-friendly)
    bind "set completion-ignore-case on" 2>/dev/null
    
    # Show all matches if ambiguous
    bind "set show-all-if-ambiguous on" 2>/dev/null
    
    # Don't require double-tab for completion
    bind "set show-all-if-unmodified on" 2>/dev/null
    
    # Enable filename completion
    complete -o bashdefault -o default -o filenames ls
    complete -o bashdefault -o default -o filenames cat
    complete -o bashdefault -o default -o filenames less
    complete -o bashdefault -o default -o filenames vi
    complete -o bashdefault -o default -o filenames vim
    
    # Completion for common commands (if available)
    if command -v kubectl >/dev/null 2>&1; then
        source <(kubectl completion bash 2>/dev/null)
        complete -o default -F __start_kubectl k
    fi
fi

# Load scripts in proper order
source ~/.bashrc_tools
source ~/scripts/ssh-agent.sh
source ~/scripts/env-security.sh
source ~/scripts/ps1.sh