# Git Bash Configuration with Deep Directory Scanning
# Static environment variables (set once per shell)

# ⚠️ WARNING: DO NOT SET USER OR HOME VARIABLES HERE! ⚠️
# The /etc/profile sets portable environment:
#   HOME=/home/portx
#   USER=portx
#   USERNAME=portx
# 
# If you add lines like "export USER=$(whoami)" or "export HOME=/home/$USER"
# they will OVERRIDE the portable settings and break the portable functionality!
# The whole point of portable mode is to NOT use Windows user-specific paths.
#


# Git Bash specific Claude Code configuration
# Detect bash.exe path dynamically and convert to Windows path
BASH_EXE_PATH="$(which bash 2>/dev/null)"
if [[ -n "$BASH_EXE_PATH" ]]; then
    # Convert Unix path to Windows path (e.g., /c/App/PORTX/bin/bash.exe -> C:\App\PORTX\bin\bash.exe)
    WINDOWS_BASH_PATH="$(echo "$BASH_EXE_PATH" | sed 's|^/c/|C:\\|' | sed 's|/|\\|g')"
    export CLAUDE_CODE_GIT_BASH_PATH="$WINDOWS_BASH_PATH"
fi

# Auto-discover PORTX_ROOT dynamically
find_portx_root() {
    local bash_home="$(dirname "$(which bash)" 2>/dev/null || echo "/bin")"
    local current_dir="$(dirname "$bash_home")"
    
    # First check common PORTX installation locations
    local common_locations=(
        "/c/App/PORTX"
        "/c/PORTX"
        "/opt/PORTX"
        "/usr/local/PORTX"
    )
    
    for location in "${common_locations[@]}"; do
        if [[ -d "$location/bin" && -d "$location/home" && -d "$location/mingw64" ]]; then
            echo "$location"
            return 0
        fi
    done
    
    # Search upward from bash directory
    while [[ "$current_dir" != "/" && "$current_dir" != "" ]]; do
        # Check if all required directories exist
        if [[ -d "$current_dir/bin" && -d "$current_dir/home" && -d "$current_dir/mingw64" ]]; then
            echo "$current_dir"
            return 0
        fi
        
        # Move up one directory
        current_dir="$(dirname "$current_dir")"
    done
    
    # If not found, return a reasonable fallback
    echo "/c/App/PORTX"
    return 1
}

export PORTX_ROOT=$(find_portx_root)

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
    
    # Basic file completion only - tool-specific completions removed for performance
fi

# SAFE: PORTX Tools Loader - Controlled Discovery with Security
load_portx_tools() {
    local cache_file="$HOME/.portx_tools"
    
    # Check for force rebuild flag
    if [[ "$PORTX_FORCE_REBUILD" == "1" ]] || [[ ! -f "$cache_file" ]]; then
        # Force rebuild or cache doesn't exist
        :
    else
        # Use existing cache
        source "$cache_file"
        return
    fi
    
    # Announce scanning (like original)
    echo "Reindexing PORTX tools..."
    
    # Use PORTX_ROOT environment variable (set in bashrc with auto-discovery)
    local portx_home="${PORTX_ROOT:-/c/App/PORTX}"
    
    local packages_dir="$portx_home/packages"
    
    # Initialize counts (like original logic)
    local tool_count=0
    local mingw_count=284  # Fixed count from Git Bash/MINGW core
    local bin_count=0
    local packages_exe_count=0
    local packages_count=0
    
    # Count MINGW as 1 directory (like original)
    ((tool_count++))
    
    # Count PORTX/bin executables (like original)
    if [ -d "$portx_home/bin" ]; then
        bin_count=$(find "$portx_home/bin" -maxdepth 1 -type f -executable 2>/dev/null | wc -l | tr -d ' \t')
        ((tool_count++))
    fi
    
    # Package validation function
    is_safe_package_dir() {
        local dir="$1"
        [ ! -d "$dir" ] && return 1
        
        # Must contain at least one executable
        local exe_count=$(find "$dir" -maxdepth 1 \( -name "*.exe" -o -name "*.bat" -o -name "*.cmd" \) 2>/dev/null | wc -l)
        [ "$exe_count" -eq 0 ] && return 1
        
        # Reject dangerous directory patterns
        local dir_name=$(basename "$dir")
        case "$dir_name" in
            # System/temp directories
            *uninstall*|*setup*|*installer*|*temp*|*tmp*|*cache*|*backup*|*old*|*test*|*debug*)
                return 1 ;;
            # Script interpreters (except azure-cli/Scripts which is safe)
            *python*|*node*|*npm*|*pip*|site-packages|__pycache__|Scripts)
                [[ "$dir" == *"azure-cli/Scripts" ]] && return 0
                return 1 ;;
            # Documentation/help
            *doc*|*help*|*manual*|*man*|*info*)
                return 1 ;;
        esac
        
        # Count actual tool executables (not installers)
        local good_exe_count=0
        while IFS= read -r exe; do
            local exe_name=$(basename "$exe" | tr '[:upper:]' '[:lower:]')
            case "$exe_name" in
                *uninstall*|*setup*|*install*|*update*|*upgrade*) continue ;;
                *) ((good_exe_count++)) ;;
            esac
        done < <(find "$dir" -maxdepth 1 \( -name "*.exe" -o -name "*.bat" -o -name "*.cmd" \) 2>/dev/null)
        
        # Must have at least one good executable
        [ "$good_exe_count" -gt 0 ]
    }
    
    # Discover safe package directories and count them (like original)
    discover_packages() {
        local packages_dir="$portx_home/packages"
        [ ! -d "$packages_dir" ] && return
        
        # Find package directories with direct executables
        find "$packages_dir" -maxdepth 1 -type d 2>/dev/null | while read -r pkg_dir; do
            [ "$pkg_dir" = "$packages_dir" ] && continue
            is_safe_package_dir "$pkg_dir" && echo "$pkg_dir"
        done
        
        # Find package subdirectories (bin, Scripts, etc.)
        find "$packages_dir" -maxdepth 2 -type d \( -name "bin" -o -name "Scripts" \) 2>/dev/null | while read -r sub_dir; do
            is_safe_package_dir "$sub_dir" && echo "$sub_dir"
        done
    }
    
    # Count packages executables (like original)
    if [ -d "$packages_dir" ]; then
        while IFS= read -r exe_dir; do
            if [ -n "$exe_dir" ]; then
                local dir_exe_count=$(find "$exe_dir" -maxdepth 1 -type f -executable 2>/dev/null | wc -l)
                packages_exe_count=$((packages_exe_count + dir_exe_count))
                ((tool_count++))
                ((packages_count++))
            fi
        done < <(discover_packages)
    fi
    
    # Generate cache file (like original structure)
    {
        echo "#!/bin/bash"
        echo "# PORTX Tools Cache"
        echo "# =================="
        echo "#"
        echo "# PURPOSE: This file contains PATH exports and counts for all PORTX tools."
        echo "# It tracks three categories: MINGW core, PORTX bin, and packages."
        echo "# Each export adds a tool directory to the PATH, making tools globally available."
        echo "#"
        echo "# GENERATION INFO:"
        echo "#   Generated: $(date)"
        echo "#   Packages Directory: $packages_dir"
        echo "#"
        echo "# TOOL COUNTS:"
        echo "#   MINGW Core: $mingw_count executables"
        echo "#   PORTX Bin: $bin_count executables"
        echo "#   Packages: $packages_count directories, $packages_exe_count executables"
        echo "#   Total: $((mingw_count + bin_count + packages_exe_count)) executables"
        echo "#"
        echo "# USAGE: This file is automatically sourced by .bashrc on shell startup."
        echo "# To regenerate: rm ~/.portx_tools or run 'regenerate_tools_cache'"
        echo ""
        
        echo "# PORTX Home: $portx_home"
        echo ""
        
        # Build single optimized PATH instead of multiple exports
        echo "# Build optimized PATH (single export instead of multiple)"
        echo "PORTX_PATH=\"\""
        
        # Add core bin directory first (highest priority)
        if [ -d "$portx_home/bin" ]; then
            echo "PORTX_PATH=\"$portx_home/bin\""
        fi
        
        # Add safe package directories
        if [ -d "$packages_dir" ]; then
            echo "# Add package directories to PORTX_PATH"
            
            while IFS= read -r exe_dir; do
                if [ -n "$exe_dir" ]; then
                    local dir_exe_count=$(find "$exe_dir" -maxdepth 1 \( -name "*.exe" -o -name "*.bat" -o -name "*.cmd" \) -type f 2>/dev/null | wc -l)
                    echo "PORTX_PATH=\"\$PORTX_PATH:$exe_dir\"  # $dir_exe_count executables"
                fi
            done < <(discover_packages)
            
            echo "# packages directories added: $packages_count"
        fi
        
        echo ""
        echo "# Single PATH export (much faster than multiple exports)"
        echo "export PATH=\"\$PORTX_PATH:\$PATH\""
        echo ""
        
        # Calculate total executables and directories (like original)
        local total_exe_count=$((mingw_count + bin_count + packages_exe_count))
        local total_dirs=$((1 + 1 + packages_count))  # 1 mingw dir + 1 bin dir + package dirs
        
        echo "# Total tool directories added: $tool_count"
        echo "# All executable counts:"
        echo "export MINGW_COUNT=$mingw_count"
        echo "export BIN_COUNT=$bin_count"  
        echo "export PACKAGES_EXE_COUNT=$packages_exe_count"
        echo "export PACKAGES_COUNT=$packages_count"
        echo "export TOTAL_EXE_COUNT=$total_exe_count"
        echo "export TOTAL_DIRS=$total_dirs"
        echo "export TOOLS_STATUS=\"\\033[1;90mTOOLS\\033[0m\\033[90m(mingw:1/$mingw_count, bin:1/$bin_count, pkg:$packages_count/$packages_exe_count)\\033[0m\""
        echo "export TOOLS_LAST_SCAN=\"$(date '+%Y-%m-%d %H:%M')\""
        
    } > "$cache_file"
    
    # Source the newly created cache
    source "$cache_file"
    
    # Show brief info if interactive (like original)
    if [[ $- == *i* ]] && [[ -z "$PORTX_QUIET_LOAD" ]]; then
        echo "Tools cache regenerated: $tool_count directories loaded (safe filtering enabled)"
        echo "Total: $total_exe_count executables (mingw:$mingw_count, bin:$bin_count, pkg:$packages_count/$packages_exe_count)"
    fi
}

# Utility functions for tools management
show_tools_info() {
    echo "Tools Cache Info:"
    echo "  Cache file: ~/.portx_tools"
    if [[ -f "$HOME/.portx_tools" ]]; then
        echo "  Cache exists: Yes"
        echo "  Last scan: ${TOOLS_LAST_SCAN:-Unknown}"
        echo "  Total directories: ${TOTAL_DIRS:-Unknown}"
        echo "  Total executables: ${TOTAL_EXE_COUNT:-Unknown}"
    else
        echo "  Cache exists: No"
        echo "  Run 'regenerate_tools_cache' to create"
    fi
}

regenerate_tools_cache() {
    echo "Removing cache file..."
    rm -f "$HOME/.portx_tools"
    echo "Regenerating tools cache with safe scan..."
    PORTX_FORCE_REBUILD=1 load_portx_tools
    show_tools_info
}

list_tool_directories() {
    echo "Current tool directories in PATH:"
    echo "$PATH" | tr ':' '\n' | grep -E '/(bin|exe|cmd|tools?)(/|$)' | nl
}

# Load scripts in proper order
load_portx_tools

# Set up portx alias after tools are loaded
# Detect PORTX root from bash executable location (same logic as load_portx_tools)
bash_home="$(dirname "$(which bash)" 2>/dev/null || echo "/bin")"
portx_home="$(dirname "$bash_home")"

# Validate this is actually a PORTX installation
if [[ ! -d "$portx_home/bin" ]] || [[ ! -d "$portx_home/home" ]] || [[ ! -d "$portx_home/mingw64" ]]; then
    # Fallback: derive from HOME if validation fails
    portx_home="$(dirname "$(dirname "$HOME")")"
fi

# Look for portx.sh in the detected PORTX directory
if [ -f "$portx_home/portx.sh" ]; then
    alias portx="$portx_home/portx.sh"
fi

source ~/scripts/ssh-agent.sh
source ~/scripts/env-security.sh
source ~/scripts/ps1.sh