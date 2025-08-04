# Git Bash Configuration with Deep Directory Scanning
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
export CLAUDE_CODE_GIT_BASH_PATH="C:\App\PORTX\bin\bash.exe"

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

# FIXED: Advanced PORTX Tools Loader - ONLY scans within PORTX directory structure
load_portx_tools() {
    local cache_file="$HOME/.portx_tools"
    local scan_depth="${PORTX_SCAN_DEPTH:-4}"  # Configurable depth (default: 4)
    local min_exe_count="${PORTX_MIN_EXECUTABLES:-1}"  # Minimum executables to add directory
    
    # If cache exists and is recent (less than 1 day old), use it
    if [ -f "$cache_file" ] && [ "$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0)))" -lt 86400 ]; then
        source "$cache_file"
        return
    fi
    
    # Cache doesn't exist or is old - generate it with advanced scanning
    
    # Detect PORTX base directory dynamically first
    local portx_home=""
    local packages_dir=""
        if [ -d "/c/App/PORTX" ]; then
            portx_home="/c/App/PORTX"
            packages_dir="/c/App/PORTX/packages"
        elif [ -d "/c/App/Git" ]; then
            portx_home="/c/App/Git"
            packages_dir="/c/App/Git/packages"
        else
            # Fallback: derive from current HOME
            portx_home="$(dirname "$(dirname "$HOME")")"
            packages_dir="$portx_home/packages"
        fi
    
    # Smart executable directory finder with filtering
    find_executable_dirs_smart() {
        local base_dir="$1"
        local max_depth="${2:-$scan_depth}"
        local min_count="${3:-$min_exe_count}"
        
        # Find directories with executables, count them, and filter
        find "$base_dir" -maxdepth "$max_depth" -type f -executable 2>/dev/null | \
            sed 's|/[^/]*$||' | \
            sort | uniq -c | \
            awk -v min_count="$min_count" '$1 >= min_count {print $2}' | \
            while read -r dir; do
                # Additional verification and filtering
                if [ -d "$dir" ]; then
                    local exe_count=$(find "$dir" -maxdepth 1 \( -name "*.exe" -o -name "*.bat" -o -name "*.cmd" \) -type f 2>/dev/null | wc -l)
                    local dir_name=$(basename "$dir")
                    
                    # Skip common directories that shouldn't be in PATH
                    case "$dir_name" in
                        "uninstall"|"temp"|"tmp"|"cache"|"log"|"logs"|"backup"|"old"|"test"|"tests"|"doc"|"docs"|"help"|"manual")
                            continue
                            ;;
                    esac
                    
                    # Skip directories with only uninstall or setup executables
                    if [ "$exe_count" -eq 1 ] && (find "$dir" -maxdepth 1 -name "*uninstall*" -o -name "*setup*" -o -name "*install*" | grep -q .); then
                        continue
                    fi
                    
                    echo "$dir"
                fi
            done
    }

    # First scan to calculate all counts, then generate header
    local tool_count=0
    local mingw_count=0
    local bin_count=0
    local packages_exe_count=0
    local packages_count=0
    
    echo "Reindexing PORTX tools..."
    
    # Do the scanning first to get counts
    # 1. Count MINGW executables (estimated)
    mingw_count=284
    ((tool_count++))  # Count MINGW as 1 directory
    
    # 2. Count PORTX/bin executables  
    if [ -d "$portx_home/bin" ]; then
        bin_count=$(find "$portx_home/bin" -maxdepth 1 -type f -executable 2>/dev/null | wc -l | tr -d ' \t')
        ((tool_count++))
    fi
    
    # 3. Count packages executables
    if [ -d "$packages_dir" ]; then
        while IFS= read -r exe_dir; do
            if [ -n "$exe_dir" ]; then
                local dir_exe_count=$(find "$exe_dir" -maxdepth 1 -type f -executable 2>/dev/null | wc -l)
                packages_exe_count=$((packages_exe_count + dir_exe_count))
                ((tool_count++))
                ((packages_count++))
            fi
        done < <(find_executable_dirs_smart "$packages_dir" "$scan_depth" "$min_exe_count")
    fi
    
    # Generate cache file with proper header including counts
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
        echo "#   Scan Depth: $scan_depth levels"
        echo "#   Min Executables: $min_exe_count per directory"
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
        
        # 1. Deep scan packages with smart filtering
        if [ -d "$packages_dir" ]; then
            echo "# Smart deep scan of packages directory: $packages_dir"
            
            while IFS= read -r exe_dir; do
                if [ -n "$exe_dir" ]; then
                    local dir_exe_count=$(find "$exe_dir" -maxdepth 1 \( -name "*.exe" -o -name "*.bat" -o -name "*.cmd" \) -type f 2>/dev/null | wc -l)
                    echo "export PATH=\"$exe_dir:\$PATH\"  # $dir_exe_count executables"
                fi
            done < <(find_executable_dirs_smart "$packages_dir" "$scan_depth" "$min_exe_count")
            
            echo "# packages directories added: $packages_count"
            echo ""
        fi
        
        # 2. Add core bin directory (PORTX /bin with Git Bash core tools)
        if [ -d "$portx_home/bin" ]; then
            echo "# Core PORTX tools directory"
            echo "export PATH=\"$portx_home/bin:\$PATH\""
            echo ""
        fi
        
        # Calculate total executables and directories
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
        
        # Utility functions
        echo ""
        echo "# Utility functions for tools management"
        echo "show_tools_info() {"
        echo "    echo \"Tools Cache Info:\""
        echo "    echo \"  Total directories: $tool_count\""
        echo "    echo \"  Last scan: \$(date -d \"\$TOOLS_LAST_SCAN\" 2>/dev/null || echo 'Unknown')\""
        echo "    echo \"  Scan depth: $scan_depth levels\""
        echo "    echo \"  Min executables: $min_exe_count per directory\""
        echo "    echo \"  Cache file: .portx_tools\""
        echo "}"
        echo ""
        echo "regenerate_tools_cache() {"
        echo "    echo \"Removing cache file...\""
        echo "    rm -f \"/home/portx/.portx_tools\""
        echo "    echo \"Regenerating tools cache with deep scan...\""
        echo "    load_portx_tools"
        echo "    show_tools_info"
        echo "}"
        echo ""
        echo "list_tool_directories() {"
        echo "    echo \"Current tool directories in PATH:\""
        echo "    echo \"\$PATH\" | tr ':' '\\n' | grep -E '/(bin|exe|cmd|tools?)(/|\$)' | nl"
        echo "}"
        
    } > "$cache_file"
    
    # Source the newly created cache
    source "$cache_file"
    
    # Show brief info if interactive
    if [[ $- == *i* ]] && [[ -z "$PORTX_QUIET_LOAD" ]]; then
        echo "Tools cache regenerated: $tool_count directories loaded (depth: $scan_depth)"
        echo "Total: $total_exe_count executables (mingw:$mingw_count, bin:$bin_count, pkg:$packages_count/$packages_exe_count)"
    fi
}

# Load scripts in proper order
load_portx_tools
source ~/scripts/ssh-agent.sh
source ~/scripts/env-security.sh
source ~/scripts/ps1.sh