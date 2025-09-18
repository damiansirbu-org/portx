#!/bin/bash
# =============================================================================
# SHELLCHECK ANALYZER MODULE
# Comprehensive shell script analysis and linting using ShellCheck
# =============================================================================

# Tool configuration
SHELLCHECK_TOOL="$SHELLCHECK_PATH"

# Register this analyzer
AVAILABLE_ANALYZERS+=("analyze_shellcheck")

analyze_shellcheck() {
    # Only analyze shell scripts
    if [[ ! "$FILE_EXT" =~ ^(sh|bash|zsh|fish)$ && ! "$BASENAME" =~ ^(.*\.sh|.*\.bash|.*\.zsh|.*rc|.*profile|Dockerfile)$ ]]; then
        echo '{"tool":"shellcheck","status":"skipped","reason":"not_shell_script","file_ext":"'"$FILE_EXT"'","basename":"'"$BASENAME"'"}'
        return
    fi
    
    # Check if shellcheck is available
    if [[ ! -x "$SHELLCHECK_TOOL" ]]; then
        echo '{"tool":"shellcheck","status":"unavailable","path":"'"$SHELLCHECK_TOOL"'"}'
        return
    fi
    
    # Run shellcheck with comprehensive 2025 authoritative parameters for maximum analysis
    # Parameters: JSON format, bash dialect, all severity levels, all optional checks enabled,
    # external source checking, sourced file analysis, wiki links, extended dataflow analysis
    local result
    result=$(timeout "$ANALYZER_TIMEOUT" "$SHELLCHECK_TOOL" \
        --format=json \
        --shell=bash \
        --severity=style \
        --enable=all \
        --external-sources \
        --check-sourced \
        --wiki-link-count=5 \
        --extended-analysis=true \
        "$FILE_PATH" 2>/dev/null)
    
    # ShellCheck always returns JSON array, even if empty
    if [[ -n "$result" ]]; then
        echo "$result"
    else
        # Fallback in case of complete failure
        echo '{"tool":"shellcheck","status":"analysis_failed","error":"no_output","file":"'"$FILE_PATH"'"}'
    fi
}
