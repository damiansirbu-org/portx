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
    local cache_file="$HOME/.portx_tools_path_cache"
    local scan_depth="${PORTX_SCAN_DEPTH:-4}"  # Configurable depth (default: 4)
    local min_exe_count="${PORTX_MIN_EXECUTABLES:-1}"  # Minimum executables to add directory
    
    # If cache exists and is recent (less than 1 day old), use it
    if [ -f "$cache_file" ] && [ "$(($(date +%s) - $(stat -c %Y "$cache_file" 2>/dev/null || echo 0)))" -lt 86400 ]; then
        source "$cache_file"
        return
    fi
    
    # Cache doesn't exist or is old - generate it with advanced scanning
    {
        echo "# PORTX Tools PATH Cache - Auto-generated Deep Scan"
        echo "# Generated: $(date)"
        echo "# Scan Depth: $scan_depth levels"
        echo "# Min Executables: $min_exe_count per directory"
        echo "# Delete this file to regenerate or set PORTX_FORCE_REBUILD=1"
        echo ""
        
        # Detect PORTX base directory dynamically
        local portx_home=""
        if [ -d "/c/App/PORTX" ]; then
            portx_home="/c/App/PORTX"
        elif [ -d "/c/App/Git" ]; then
            portx_home="/c/App/Git"
        else
            # Fallback: derive from current HOME
            portx_home="$(dirname "$(dirname "$HOME")")"
        fi
        
        echo "# PORTX Home: $portx_home"
        echo ""
        
        # Smart executable directory finder with filtering
        find_executable_dirs_smart() {
            local base_dir="$1"
            local max_depth="${2:-$scan_depth}"
            local min_count="${3:-$min_exe_count}"
            
            # Find directories with executables, count them, and filter
            find "$base_dir" -maxdepth "$max_depth" -type f \( -name "*.exe" -o -name "*.bat" -o -name "*.cmd" \) 2>/dev/null | \
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
        
        # Priority directories (added first, higher precedence)
        local tool_count=0
        local core_exe_count=122  # Fixed number of basic MINGW executables
        local binext_exe_count=0
        local bintools_exe_count=0
        
        # 1. Add bin-ext first (highest priority)
        if [ -d "$portx_home/bin-ext" ]; then
            echo "# High-priority enhanced Unix tools"
            echo "export PATH=\"$portx_home/bin-ext:\$PATH\""
            binext_exe_count=$(find "$portx_home/bin-ext" -maxdepth 1 \( -name "*.exe" -o -name "*.bat" -o -name "*.cmd" \) -type f 2>/dev/null | wc -l)
            ((tool_count++))
            echo ""
        fi
        
        # 2. Deep scan bin-tools with smart filtering
        if [ -d "$portx_home/bin-tools" ]; then
            echo "# Smart deep scan of bin-tools directory"
            
            local bin_tools_count=0
            while IFS= read -r exe_dir; do
                if [ -n "$exe_dir" ]; then
                    local dir_exe_count=$(find "$exe_dir" -maxdepth 1 \( -name "*.exe" -o -name "*.bat" -o -name "*.cmd" \) -type f 2>/dev/null | wc -l)
                    echo "export PATH=\"$exe_dir:\$PATH\"  # $dir_exe_count executables"
                    bintools_exe_count=$((bintools_exe_count + dir_exe_count))
                    ((tool_count++))
                    ((bin_tools_count++))
                fi
            done < <(find_executable_dirs_smart "$portx_home/bin-tools" "$scan_depth" "$min_exe_count")
            
            echo "# bin-tools directories added: $bin_tools_count"
            echo ""
        fi
        
        # 3. Scan other PORTX-specific tool directories (ONLY within PORTX)
        for tool_base in "$portx_home/tools" "$portx_home/bin" "$portx_home/Apps"; do
            if [ -d "$tool_base" ]; then
                echo "# Smart scan of $(basename "$tool_base") directory"
                local section_count=0
                
                while IFS= read -r exe_dir; do
                    if [ -n "$exe_dir" ]; then
                        echo "export PATH=\"$exe_dir:\$PATH\""
                        ((tool_count++))
                        ((section_count++))
                    fi
                done < <(find_executable_dirs_smart "$tool_base" 2 "$min_exe_count")
                
                if [ "$section_count" -gt 0 ]; then
                    echo "# $(basename "$tool_base") directories added: $section_count"
                    echo ""
                fi
            fi
        done
        
        # REMOVED: The problematic /c/App/ scanning that was adding Cygwin64
        # The original code scanned ALL of /c/App/ which is wrong - we should only scan within PORTX
        
        # Calculate total executables
        local total_exe_count=$((core_exe_count + binext_exe_count + bintools_exe_count))
        
        echo "# Total tool directories added: $tool_count"
        echo "# Executable counts:"
        echo "export CORE_EXE_COUNT=$core_exe_count"
        echo "export BINEXT_EXE_COUNT=$binext_exe_count"
        echo "export BINTOOLS_EXE_COUNT=$bintools_exe_count"
        echo "export TOTAL_EXE_COUNT=$total_exe_count"
        echo "export TOOLS_STATUS=\"\\033[1;90mTOOLS\\033[0m\\033[90m($core_exe_count+$binext_exe_count+$bintools_exe_count)\\033[0m\""
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
        echo "    echo \"  Cache file: .portx_tools_path_cache\""
        echo "}"
        echo ""
        echo "regenerate_tools_cache() {"
        echo "    echo \"Removing cache file...\""
        echo "    rm -f \"$cache_file\""
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
    fi
}

# Load scripts in proper order
load_portx_tools
source ~/scripts/ssh-agent.sh
source ~/scripts/env-security.sh
source ~/scripts/ps1.sh