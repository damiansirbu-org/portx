#!/bin/bash
# =============================================================================
# TRIVY ANALYZER - Security Scanner for Containers and Infrastructure
# Scans for security vulnerabilities and misconfigurations
# =============================================================================

analyze_trivy() {
    local trivy_path="$GIT_BASH_ROOT/home/portx/packages/trivy/trivy.exe"
    
    echo "=== TRIVY SECURITY ANALYSIS ==="
    echo "Analyzing: $FILE_PATH"
    echo
    
    # Check if Trivy is available
    if [[ ! -f "$trivy_path" ]]; then
        echo "Trivy not available at $trivy_path"
        echo "Please install Trivy for security scanning"
        return 1
    fi
    
    local file_ext="${FILE_PATH##*.}"
    local basename="$(basename "$FILE_PATH")"
    
    # Determine scan type based on file
    if [[ "$basename" == Dockerfile* ]] || [[ "$FILE_PATH" =~ Dockerfile ]]; then
        echo "Scanning Dockerfile for security issues..."
        local trivy_output
        if trivy_output=$(timeout $ANALYZER_TIMEOUT "$trivy_path" config --format json --severity HIGH,CRITICAL "$FILE_PATH" 2>/dev/null); then
            if [[ -n "$trivy_output" && "$trivy_output" != "null" ]]; then
                echo "Security issues found:"
                # Parse and display results
                echo "$trivy_output" | "$GOJQ_PATH" -r '.Results[]?.Misconfigurations[]? | "Line \(.CauseMetadata.StartLine): [\(.Severity)] \(.ID) - \(.Title)"' 2>/dev/null || echo "$trivy_output"
            else
                echo "✅ No high/critical security issues found"
            fi
        else
            echo "Trivy scan failed or timed out"
            return 1
        fi
        
    elif [[ "$file_ext" =~ ^(yaml|yml)$ ]] && grep -q -E "apiVersion:|kind:|image:|services:" "$FILE_PATH" 2>/dev/null; then
        echo "Scanning Kubernetes/Docker Compose file for security issues..."
        local trivy_output
        if trivy_output=$(timeout $ANALYZER_TIMEOUT "$trivy_path" config --format json --severity HIGH,CRITICAL "$FILE_PATH" 2>/dev/null); then
            if [[ -n "$trivy_output" && "$trivy_output" != "null" ]]; then
                echo "Security issues found:"
                echo "$trivy_output" | "$GOJQ_PATH" -r '.Results[]?.Misconfigurations[]? | "Line \(.CauseMetadata.StartLine): [\(.Severity)] \(.ID) - \(.Title)"' 2>/dev/null || echo "$trivy_output"
            else
                echo "✅ No high/critical security issues found"
            fi
        else
            echo "Trivy scan failed or timed out"
            return 1
        fi
        
    else
        echo "File type not supported by Trivy scanner"
        echo "Supported: Dockerfile, Kubernetes YAML, Docker Compose"
        return 1
    fi
    
    echo
    echo "Trivy security categories checked:"
    echo "• Container misconfigurations"
    echo "• Kubernetes security issues"
    echo "• Infrastructure as Code problems" 
    echo "• Docker best practices violations"
    echo "• Severity levels: HIGH, CRITICAL"
    
    echo
    return 0
}