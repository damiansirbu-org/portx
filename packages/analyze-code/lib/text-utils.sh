#!/bin/bash
# =============================================================================
# GLOBAL OUTPUT SANITIZATION UTILITIES
# Safe sanitization without breaking JSON structure or content
# =============================================================================

# Remove ANSI escape sequences from text strings
remove_ansi_codes() {
    local input="$1"
    
    # Remove ANSI escape sequences properly for MINGW64 Git Bash
    local clean_output
    clean_output=$(printf '%s' "$input" | sed 's/\x1B\[[0-9;]*[HDJKmsu]//g')
    
    # Remove carriage returns
    clean_output=$(printf '%s' "$clean_output" | tr -d '\r')
    
    printf '%s' "$clean_output"
}

# Note: JSON escaping moved to json-helper.sh
# Use json_escape() from json-helper.sh instead

# Convert filepath to safe filesystem name
sanitize_filesystem_path() {
    local filepath="$1"
    # Use tr for all character replacements - no sed needed
    echo "$filepath" | tr '[:upper:]' '[:lower:]' | tr '/\\:' '_' | tr '<>' '_' | tr ' ' '_' | tr -s '_'
}

