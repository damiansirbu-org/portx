#!/bin/bash
# =============================================================================
# DOCKERFILE ANALYZER - Dockerfile Quality and Security Analysis
# Analyzes Dockerfile structure and patterns for quality validation
# =============================================================================

analyze_dockerfile() {
    echo "=== DOCKERFILE ANALYSIS ==="
    echo "Analyzing: $FILE_PATH"
    echo
    
    if [[ "$(basename "$FILE_PATH")" != Dockerfile* ]] && [[ ! "$FILE_PATH" =~ Dockerfile ]]; then
        echo "Not a Dockerfile - skipping analysis"
        return 1
    fi
    
    if [[ ! -f "$FILE_PATH" ]]; then
        echo "File not found: $FILE_PATH"
        return 1
    fi
    
    echo "Dockerfile structure analysis:"
    echo "Base images:"
    if grep -n "^FROM" "$FILE_PATH" 2>/dev/null; then
        :
    else
        echo "No FROM instructions found"
    fi
    
    echo
    echo "Exposed ports:"
    if grep -n "^EXPOSE" "$FILE_PATH" 2>/dev/null; then
        :
    else
        echo "No EXPOSE instructions found"
    fi
    
    echo
    echo "Environment variables:"
    if grep -n "^ENV" "$FILE_PATH" 2>/dev/null; then
        :
    else
        echo "No ENV instructions found"
    fi
    
    echo
    echo "Entry points:"
    if grep -n "^\\(ENTRYPOINT\\|CMD\\)" "$FILE_PATH" 2>/dev/null; then
        :
    else
        echo "No ENTRYPOINT or CMD instructions found"
    fi
    
    echo
    echo "Multi-stage build:"
    if grep -q "^FROM.*AS" "$FILE_PATH" 2>/dev/null; then
        echo "Multi-stage build detected"
    else
        echo "Single-stage build"
    fi
    
    echo
    echo "Potential issues:"
    
    # Check for common Dockerfile issues
    local issues_found=false
    
    if grep -q "^FROM.*:latest" "$FILE_PATH" 2>/dev/null; then
        echo "⚠️  Using :latest tag (consider pinning versions)"
        issues_found=true
    fi
    
    if grep -q "^RUN.*apt-get update.*apt-get install" "$FILE_PATH" 2>/dev/null; then
        if ! grep -q "apt-get.*clean\|rm.*apt" "$FILE_PATH" 2>/dev/null; then
            echo "⚠️  apt-get without cleanup (increases image size)"
            issues_found=true
        fi
    fi
    
    if grep -q "^USER root\|^USER 0" "$FILE_PATH" 2>/dev/null; then
        echo "⚠️  Running as root user (security risk)"
        issues_found=true
    fi
    
    if ! grep -q "^USER" "$FILE_PATH" 2>/dev/null; then
        echo "⚠️  No USER instruction (will run as root)"
        issues_found=true
    fi
    
    if [[ "$issues_found" != true ]]; then
        echo "No obvious issues found"
    fi
    
    echo
    return 0
}