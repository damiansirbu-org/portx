#!/bin/bash
# =============================================================================
# HADOLINT ANALYZER - Professional Dockerfile Linter
# Advanced Dockerfile quality checking with best practices validation
# =============================================================================

analyze_hadolint() {
    local hadolint_path="$GIT_BASH_ROOT/home/portx/packages/hadolint/hadolint.exe"
    
    echo "=== HADOLINT DOCKERFILE LINTING ==="
    echo "Analyzing: $FILE_PATH"
    echo
    
    if [[ "$(basename "$FILE_PATH")" != Dockerfile* ]] && [[ ! "$FILE_PATH" =~ Dockerfile ]]; then
        echo "Not a Dockerfile - skipping hadolint analysis"
        return 1
    fi
    
    # Check if Hadolint is available
    if [[ ! -f "$hadolint_path" ]]; then
        echo "Hadolint not available at $hadolint_path"
        echo "Please install hadolint for professional Dockerfile analysis"
        return 1
    fi
    
    echo "Running Hadolint analysis..."
    local hadolint_output
    if hadolint_output=$(timeout $ANALYZER_TIMEOUT "$hadolint_path" --format json "$FILE_PATH" 2>/dev/null); then
        if [[ -n "$hadolint_output" && "$hadolint_output" != "[]" ]]; then
            echo "Issues found:"
            # Parse JSON and show human-readable format
            echo "$hadolint_output" | "$GOJQ_PATH" -r '.[] | "Line \(.line): [\(.level)] \(.code) - \(.message)"' 2>/dev/null || echo "$hadolint_output"
        else
            echo "✅ No issues found - Dockerfile follows best practices"
        fi
    else
        echo "Hadolint analysis failed or timed out"
        return 1
    fi
    
    echo
    echo "Hadolint rule categories checked:"
    echo "• DL3000-DL3999: Best practices"
    echo "• DL4000-DL4999: Security issues"  
    echo "• DL1001-DL1999: Parser warnings"
    echo "• SC2000-SC9999: ShellCheck integration"
    
    echo
    return 0
}