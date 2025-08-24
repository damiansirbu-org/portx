#!/bin/bash
# =============================================================================
# PORTX Git Bash Configuration
# Professional Shell Environment for Portable Development
# =============================================================================
#
# DESCRIPTION:
#   Portable Git Bash environment configuration with professional organization
#   following GNU Bash startup file best practices.
#
# STRUCTURE:
#   1. Environment Detection & Validation
#   2. Core System Configuration
#   3. Security & SSH Management
#   4. Development Environment Setup
#   5. User Interface & Prompt Configuration
#   6. Tool Integration & PATH Management
#
# COMPATIBILITY: Git Bash (MINGW64), Windows 10/11
# AUTHOR: PORTX Development Team
# =============================================================================

# =============================================================================
# SECTION 1: ENVIRONMENT DETECTION & VALIDATION
# =============================================================================

# Prevent multiple loading and ensure proper environment
[[ -n "$PORTX_BASHRC_LOADED" ]] && return
export PORTX_BASHRC_LOADED=1

# ⚠️  CRITICAL ENVIRONMENT WARNING ⚠️
# Do NOT override USER/HOME variables set by /etc/profile
# The portable environment requires these exact values:
#   HOME=/home/portx
#   USER=portx
#   USERNAME=portx
# Overriding these breaks portability!

# Claude Code Integration will be configured after GIT_BASH_ROOT is detected

# =============================================================================
# Git Bash Root Detection Function
# =============================================================================

# find_git_bash_root() - Dynamically detect Git Bash installation root
#
# DESCRIPTION:
#   Locates the Git Bash installation root directory with sophisticated validation.
#   Prioritizes proper Git Bash installations over MSYS2 alternatives.
#
# RETURNS:
#   String: Absolute path to Git Bash root directory
#   Exit 1: If no valid Git Bash installation found
#
# VALIDATION:
#   - Ensures sh.exe is in a 'bin' directory
#   - Validates presence of required directories (bin, mingw64, home)
#   - Prefers non-/usr paths to avoid MSYS2 conflicts
find_git_bash_root() {
    # Known Git Bash installation locations (prioritized)
    local -a sh_candidates=(
        "/c/App/Git/bin/sh.exe"
        "/c/git-bash/bin/sh.exe"
        "/opt/git-bash/bin/sh.exe"
        "/usr/local/git-bash/bin/sh.exe"
    )

    local sh_path=""

    # Phase 1: Check known installation locations
    for candidate in "${sh_candidates[@]}"; do
        [[ -f "$candidate" ]] && {
            sh_path="$candidate"
            break
        }
    done

    # Phase 2: Dynamic discovery with MSYS2 avoidance
    if [[ -z "$sh_path" ]]; then
        local -a all_sh_paths
        mapfile -t all_sh_paths < <(which -a sh.exe 2>/dev/null)

        # Prefer non-/usr paths (avoid MSYS2 sh.exe)
        for path in "${all_sh_paths[@]}"; do
            [[ "$path" != /usr/* ]] && {
                sh_path="$path"
                break
            }
        done

        # Fallback: Use first available if no preferred path found
        [[ -z "$sh_path" && ${#all_sh_paths[@]} -gt 0 ]] && sh_path="${all_sh_paths[0]}"
    fi

    # Validation: Ensure sh.exe was found
    if [[ -z "$sh_path" ]]; then
        printf "FATAL ERROR: No Git Bash sh.exe found!\nChecked locations:\n" >&2
        printf "  - %s [NOT FOUND]\n" "${sh_candidates[@]}" >&2
        printf "PORTX cannot continue without proper Git Bash installation.\n" >&2
        exit 1
    fi

    # Validation: Ensure proper directory structure
    local bin_dir git_root
    bin_dir="$(dirname "$sh_path")"

    if [[ "$(basename "$bin_dir")" != "bin" ]]; then
        printf "FATAL ERROR: sh.exe not in 'bin' directory!\n" >&2
        printf "Found sh.exe at: %s\n" "$sh_path" >&2
        printf "Expected sh.exe to be in a 'bin' directory, but found in: %s\n" "$bin_dir" >&2
        printf "PORTX cannot continue with invalid Git Bash structure.\n" >&2
        exit 1
    fi

    git_root="$(dirname "$bin_dir")"

    # Validation: Ensure complete Git Bash installation
    local -a required_dirs=("$git_root/bin" "$git_root/mingw64" "$git_root/home")
    local missing_dirs=()

    for dir in "${required_dirs[@]}"; do
        [[ ! -d "$dir" ]] && missing_dirs+=("$dir")
    done

    if [[ ${#missing_dirs[@]} -gt 0 ]]; then
        printf "FATAL ERROR: Invalid Git Bash structure at %s\n" "$git_root" >&2
        printf "Missing required directories:\n" >&2
        printf "  - %s [MISSING]\n" "${missing_dirs[@]}" >&2
        printf "PORTX cannot continue with incomplete Git Bash installation.\n" >&2
        exit 1
    fi

    printf "%s" "$git_root"
    return 0
}

# =============================================================================
# Environment Variable Initialization
# =============================================================================

# Initialize core PORTX environment variables
# Fix SC2155: Separate declare and assign to avoid masking return values
GIT_BASH_ROOT=$(find_git_bash_root)
readonly GIT_BASH_ROOT
export GIT_BASH_ROOT
export USER="portx"
export PORTX_HOME="$GIT_BASH_ROOT/home/$USER"

# Configure Claude Code Git Bash integration with dynamic path
# Transform Unix path (/c/App/Git) to Windows path (C:\App\Git)
GIT_BASH_ROOT_WINDOWS=$(echo "$GIT_BASH_ROOT" | sed 's|^/c/|C:\\|' | sed 's|/|\\|g')
export CLAUDE_CODE_GIT_BASH_PATH="${GIT_BASH_ROOT_WINDOWS}\\bin\\bash.exe"

# =============================================================================
# SECTION 2: CORE SYSTEM CONFIGURATION
# =============================================================================

# =============================================================================
# Terminal Environment Configuration
# =============================================================================

# Terminal capabilities and shell behavior
export TERM=xterm-256color
export SHELL="/bin/bash"

# MSYS2 Environment Configuration
# Modern UCRT runtime environment (recommended for 2025)
export MSYSTEM=UCRT64

# Windows Integration Settings
# Prevent Windows temp directory conflicts in portable environment
unset TMP TEMP
export TMPDIR=/tmp

# =============================================================================
# Internationalization & Locale Configuration
# =============================================================================

# UTF-8 Locale Configuration
# Ensures proper character encoding for international content
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# =============================================================================
# Theme System Integration
# =============================================================================

# load_theme_system() - Initialize PORTX theme system with basic failsafe
#
# DESCRIPTION:
#   Loads the unified PORTX theme system for consistent UI elements.
#   Provides super basic ASCII fallback if theme.sh is unavailable.
load_theme_system() {
    # Load theme system - let it crash if not found
    # shellcheck source=/dev/null
    source "$PORTX_HOME/scripts/theme.sh"
}

# Initialize theme system
load_theme_system

# =============================================================================
# Development Environment Configuration
# =============================================================================

# Default Development Tools
export EDITOR=vim
export PAGER=less

# =============================================================================
# Shell History Configuration
# =============================================================================

# History Settings (Performance Optimized)
# Unlimited history with immediate persistence and deduplication
export HISTFILE="$HOME/.bash_history"
export HISTSIZE=-1                      # Unlimited in-memory history
export HISTFILESIZE=-1                  # Unlimited on-disk history
export HISTTIMEFORMAT="[%F %T] "        # Timestamp format: [YYYY-MM-DD HH:MM:SS]
export HISTCONTROL=ignoredups:erasedups # Remove duplicates

# Shell Options for History Management
shopt -s histappend # Append to history file, don't overwrite

# Real-time History Persistence
# Write history immediately after each command for session sharing
PROMPT_COMMAND="history -a;$PROMPT_COMMAND"

# =============================================================================
# PATH Management & Development Tools
# =============================================================================

# Local Development PATH Extensions
# Add user-specific binary directories to PATH if they exist
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/scripts" ]] && export PATH="$HOME/scripts:$PATH"

# =============================================================================
# SECTION 5: USER INTERFACE & PROMPT CONFIGURATION
# =============================================================================

# =============================================================================
# Command Aliases
# =============================================================================

# System Command Enhancements
alias ls='ls --color=auto'

# Kubernetes Shortcuts
alias k=kubectl
alias kk='kubectl config current-context'

# Git Enhancement Aliases
alias git-log='tig'
alias git-browse='tig'

# =============================================================================
# Interactive Shell Configuration
# =============================================================================

# configure_interactive_shell() - Setup completion and interactive features
#
# DESCRIPTION:
#   Configures bash completion, readline options, and interactive enhancements.
#   Only executed in interactive shell sessions for performance.
#
# FEATURES:
#   - Programmable completion system
#   - Git for Windows integration
#   - Case-insensitive filename completion
#   - Enhanced readline behavior
configure_interactive_shell() {
    # Verify interactive shell
    [[ $- != *i* ]] && return

    # Enable programmable completion
    shopt -s progcomp 2>/dev/null

    # Load Git for Windows completion if available
    local git_completion="/mingw64/share/git/completion/git-completion.bash"
    # shellcheck source=/dev/null
    [[ -f "$git_completion" ]] && source "$git_completion"

    # Load system bash completion (prioritized locations)
    local -a completion_paths=(
        "/usr/share/bash-completion/bash_completion"
        "/etc/bash_completion"
    )

    for completion_file in "${completion_paths[@]}"; do
        if [[ -f "$completion_file" ]]; then
            # shellcheck source=/dev/null
            source "$completion_file"
            break
        fi
    done

    # Readline Configuration (Windows-friendly)
    bind "set completion-ignore-case on" 2>/dev/null # Case-insensitive completion
    bind "set show-all-if-ambiguous on" 2>/dev/null  # Show all matches immediately
    bind "set show-all-if-unmodified on" 2>/dev/null # No double-tab requirement

    # Basic Command Completion Setup
    local -a basic_commands=(ls cat less vi vim)
    for cmd in "${basic_commands[@]}"; do
        complete -o bashdefault -o default -o filenames "$cmd"
    done
}

# Initialize interactive shell configuration
configure_interactive_shell

# =============================================================================
# SECTION 6: TOOL INTEGRATION & PATH MANAGEMENT
# =============================================================================

# =============================================================================
# PORTX Tool PATH Management System
# =============================================================================

# load_portx_path() - Intelligent PORTX tool PATH loading with caching
#
# DESCRIPTION:
#   Loads PORTX tool paths using cached results for performance.
#   Automatically regenerates cache if missing or invalid.
#
# CACHE STRATEGY:
#   - Uses ~/.portx_path cache file for instant loading
#   - Falls back to import-packages.sh for cache generation
#   - Provides manual cache regeneration capability
load_portx_path() {
    local cache_file="$PORTX_HOME/.portx_cache"

    # Load from cache if available
    if [[ -f "$cache_file" ]]; then
        # shellcheck source=/dev/null
        source "$cache_file"
        
        # Bashrc controls PATH integration - add PACKAGES_PATH to PATH
        if [[ -n "$PACKAGES_PATH" ]]; then
            export PATH="$PACKAGES_PATH:$PATH"
        fi
        return 0
    fi

    # Cache not found - show warning
    echo "WARNING: No .portx_cache found, please regenerate using: ./scripts/import-packages.sh" >&2
}


# Initialize PORTX tool environment
load_portx_path

# =============================================================================
# PORTX Integration Aliases
# =============================================================================

# Main PORTX command alias (assumes portx.sh is in PATH)
alias portx="portx.sh"

# =============================================================================
# SECTION 3: SECURITY & SSH MANAGEMENT
# =============================================================================

# Load SSH agent configuration and key management
# shellcheck source=/dev/null
source ~/scripts/ssh-agent.sh

# Load environment security configuration
# shellcheck source=/dev/null
source ~/scripts/env-security.sh

# Load custom prompt configuration (PS1 setup)
# shellcheck source=/dev/null
source ~/scripts/ps1.sh

# =============================================================================
# Bashrc Configuration Complete
# =============================================================================
