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

# MSYS2 baseline enforcement - complete environment consistency
export MSYSTEM=UCRT64              # Modern UCRT environment (recommended for 2025)
export MSYS2_PATH_TYPE=minimal     # Don't inherit Windows PATH automatically
export MSYS_NO_PATHCONV=1          # Disable automatic path conversion for predictability
export MSYS2_ARG_CONV_EXCL="*"     # Exclude all arguments from path conversion
export MSYS2_ENV_CONV_EXCL="*"     # Exclude all environment vars from path conversion

# Windows PATH integration now handled in cached .portx_path file

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

# SAFE: PORTX Complete PATH Loader - PORTX Tools + Windows PATH Integration
load_portx_path() {
    local cache_file="$HOME/.portx_path"
    
    # Check for force rebuild flag
    if [[ "$PORTX_FORCE_REBUILD" == "1" ]] || [[ ! -f "$cache_file" ]]; then
        # Force rebuild or cache doesn't exist
        :
    else
        # Use existing cache
        source "$cache_file"
        return
    fi
    
    # Announce scanning with progress messages
    echo -e "\\033[90mScanning PORTX packages...\\033[0m"
    
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
    
    # Get Windows PATH and convert it
    echo -e "\\033[90mIntegrating Windows PATH...\\033[0m"
    local windows_path_section=""
    local windows_count=0
    if command -v cmd.exe >/dev/null 2>&1; then
        local windows_path
        windows_path=$(cmd.exe /c "echo %PATH%" 2>/dev/null | tr -d '\r\n')
        
        if [[ -n "$windows_path" ]]; then
            local converted_paths=()
            local portx_paths=""
            
            # Build list of existing PORTX paths to avoid duplicates
            if [ -d "$portx_home/bin" ]; then
                portx_paths=":$portx_home/bin"
            fi
            while IFS= read -r exe_dir; do
                if [ -n "$exe_dir" ]; then
                    portx_paths="$portx_paths:$exe_dir"
                fi
            done < <(discover_packages)
            
            IFS=';' read -ra PATH_ARRAY <<< "$windows_path"
            for dir in "${PATH_ARRAY[@]}"; do
                [[ -z "$dir" ]] && continue
                local posix_dir=$(echo "$dir" | sed 's|\\|/|g' | sed 's|^\([A-Za-z]\):|/\L\1|')
                
                # Skip if this is a PORTX directory (avoid duplicates)
                if [[ "$portx_paths" == *":$posix_dir"* ]]; then
                    continue
                fi
                
                if [[ -d "$posix_dir" ]]; then
                    converted_paths+=("$posix_dir")
                    ((windows_count++))
                fi
            done
            
            # Build Windows PATH section
            if [[ ${#converted_paths[@]} -gt 0 ]]; then
                windows_path_section="# Add Windows PATH entries\n"
                for path in "${converted_paths[@]}"; do
                    windows_path_section+="COMPLETE_PATH=\"\$COMPLETE_PATH:$path\"\n"
                done
            fi
        fi
    fi

    # Generate cache file with complete PATH integration
    echo -e "\\033[90mGenerating complete PATH cache...\\033[0m"
    {
        echo "#!/bin/bash"
        echo "# PORTX Complete PATH Cache"
        echo "# =========================="
        echo "#"
        echo "# PURPOSE: Complete PATH integration - PORTX tools + Windows PATH"
        echo "# This provides fast access to all tools: PORTX executables + Windows system tools"
        echo "#"
        echo "# GENERATION INFO:"
        echo "#   Generated: $(date)"
        echo "#   PORTX Directory: $portx_home"
        echo "#   Packages Directory: $packages_dir"
        echo "#"
        echo "# TOOL COUNTS:"
        echo "#   MINGW Core: $mingw_count executables"
        echo "#   PORTX Bin: $bin_count executables"
        echo "#   PORTX Packages: $packages_count directories, $packages_exe_count executables"
        echo "#   Windows PATH: $windows_count directories"
        echo "#   Total: $((mingw_count + bin_count + packages_exe_count + windows_count)) PATH entries"
        echo "#"
        echo "# USAGE: This file is automatically sourced by .bashrc on shell startup."
        echo "# To regenerate: rm ~/.portx_path or run 'regenerate_path_cache'"
        echo "#"
        echo "# CACHE INVALIDATION: Delete this file if any of the following change:"
        echo "#   - Windows PATH environment variable is modified"
        echo "#   - PORTX packages are added/removed/updated"
        echo "#   - PORTX installation is moved or modified"
        echo "#   - New Windows software installed that adds to PATH"
        echo ""
        
        echo "# PORTX Home: $portx_home"
        echo ""
        
        # Build complete integrated PATH
        echo "# Build complete integrated PATH (PORTX + Windows)"
        echo "COMPLETE_PATH=\"\""
        
        # Add core bin directory first (highest priority)
        if [ -d "$portx_home/bin" ]; then
            echo "COMPLETE_PATH=\"$portx_home/bin\""
        fi
        
        # Add PORTX package directories
        if [ -d "$packages_dir" ]; then
            echo "# Add PORTX package directories"
            
            while IFS= read -r exe_dir; do
                if [ -n "$exe_dir" ]; then
                    local dir_exe_count=$(find "$exe_dir" -maxdepth 1 \( -name "*.exe" -o -name "*.bat" -o -name "*.cmd" \) -type f 2>/dev/null | wc -l)
                    echo "COMPLETE_PATH=\"\$COMPLETE_PATH:$exe_dir\"  # $dir_exe_count executables"
                fi
            done < <(discover_packages)
            
            echo "# PORTX packages added: $packages_count directories"
        fi
        
        # Add Windows PATH section
        if [[ -n "$windows_path_section" ]]; then
            echo ""
            echo -e "$windows_path_section"
            echo "# Windows PATH entries added: $windows_count directories"
        fi
        
        echo ""
        echo "# Export complete integrated PATH"
        echo "export PATH=\"\$COMPLETE_PATH\""
        echo ""
        
        # Calculate total counts
        local total_exe_count=$((mingw_count + bin_count + packages_exe_count))
        local total_path_dirs=$((1 + 1 + packages_count + windows_count))  # mingw + bin + packages + windows
        
        echo "# Complete PATH statistics"
        echo "export MINGW_COUNT=$mingw_count"
        echo "export BIN_COUNT=$bin_count"  
        echo "export PACKAGES_EXE_COUNT=$packages_exe_count"
        echo "export PACKAGES_COUNT=$packages_count"
        echo "export WINDOWS_PATH_COUNT=$windows_count"
        echo "export TOTAL_EXE_COUNT=$total_exe_count"
        echo "export TOTAL_PATH_DIRS=$total_path_dirs"
        echo "export TOOLS_STATUS=\"\\033[1;90mTOOLS\\033[0m\\033[90m(mingw:1/$mingw_count, bin:1/$bin_count, pkg:$packages_count/$packages_exe_count)\\033[0m\""
        echo "export PATH_STATUS=\"\\033[1;90mPATH\\033[0m\\033[90m(portx:$((1 + packages_count))/$((bin_count + packages_exe_count)), windows:$windows_count)\\033[0m\""
        echo "export PATH_LAST_SCAN=\"$(date '+%Y-%m-%d %H:%M')\""
        
    } > "$cache_file"
    
    # Source the newly created cache
    source "$cache_file"
    
    # Show brief info if interactive
    if [[ $- == *i* ]] && [[ -z "$PORTX_QUIET_LOAD" ]]; then
        echo -e "\\033[90mComplete PATH cache ready: $total_path_dirs directories integrated\\033[0m"
        echo -e "\\033[90mPORTX: $((bin_count + packages_exe_count)) executables | Windows: $windows_count directories\\033[0m"
    fi
}

# Utility functions for complete PATH management
show_path_info() {
    echo "Complete PATH Cache Info:"
    echo "  Cache file: ~/.portx_path"
    if [[ -f "$HOME/.portx_path" ]]; then
        echo "  Cache exists: Yes"
        echo "  Last scan: ${PATH_LAST_SCAN:-Unknown}"
        echo "  PORTX executables: ${TOTAL_EXE_COUNT:-Unknown}"
        echo "  Windows directories: ${WINDOWS_PATH_COUNT:-Unknown}"
        echo "  Total PATH entries: ${TOTAL_PATH_DIRS:-Unknown}"
    else
        echo "  Cache exists: No"
        echo "  Run 'regenerate_path_cache' to create"
    fi
}

regenerate_path_cache() {
    echo "Removing complete PATH cache file..."
    rm -f "$HOME/.portx_path"
    echo "Regenerating complete PATH cache (PORTX + Windows)..."
    PORTX_FORCE_REBUILD=1 load_portx_path
    show_path_info
}

list_path_directories() {
    echo "Current complete PATH directories:"
    echo "$PATH" | tr ':' '\n' | nl
}

# Legacy compatibility functions
show_tools_info() { show_path_info; }
regenerate_tools_cache() { regenerate_path_cache; }
list_tool_directories() { list_path_directories; }

# Load complete PATH (PORTX + Windows) 
load_portx_path

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