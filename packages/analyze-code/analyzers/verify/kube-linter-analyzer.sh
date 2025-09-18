#!/bin/bash
# =============================================================================
# KUBE-LINTER ANALYZER - Kubernetes Best Practices Linter
# Validates Kubernetes YAML files for security and best practices
# =============================================================================

analyze_kube_linter() {
    local kube_linter_path="$GIT_BASH_ROOT/home/portx/packages/kube-linter/kube-linter.exe"
    
    echo "=== KUBE-LINTER ANALYSIS ==="
    echo "Analyzing: $FILE_PATH"
    echo
    
    # Check if this is a Kubernetes YAML file
    local file_ext="${FILE_PATH##*.}"
    if [[ ! "$file_ext" =~ ^(yaml|yml)$ ]]; then
        echo "Not a YAML file - skipping kube-linter analysis"
        return 1
    fi
    
    # Quick check if it's actually Kubernetes YAML
    if ! timeout 5 grep -q -E "apiVersion:|kind:" "$FILE_PATH" 2>/dev/null; then
        echo "Not a Kubernetes YAML file - skipping kube-linter analysis"
        return 1
    fi
    
    # Check if kube-linter is available
    if [[ ! -f "$kube_linter_path" ]]; then
        echo "kube-linter not available at $kube_linter_path"
        echo "Please install kube-linter for Kubernetes validation"
        return 1
    fi
    
    echo "Running kube-linter analysis..."
    local kube_linter_output
    if kube_linter_output=$(timeout $ANALYZER_TIMEOUT "$kube_linter_path" lint --format json "$FILE_PATH" 2>/dev/null); then
        if [[ -n "$kube_linter_output" && "$kube_linter_output" != "null" ]]; then
            # Parse and display results
            echo "Issues found:"
            echo "$kube_linter_output" | "$GOJQ_PATH" -r '.Reports[]? | "[\(.Diagnostic.Check)] \(.Object.K8sObject.Name // "unknown"): \(.Diagnostic.Message)"' 2>/dev/null || {
                echo "Raw output:"
                echo "$kube_linter_output"
            }
        else
            echo "✅ No issues found - Kubernetes YAML follows best practices"
        fi
    else
        echo "kube-linter analysis failed or timed out"
        return 1
    fi
    
    echo
    echo "kube-linter checks performed:"
    echo "• Security best practices"
    echo "• Resource limits and requests"
    echo "• Readiness and liveness probes"
    echo "• Pod security standards"
    echo "• Network policies"
    echo "• Service account configurations"
    echo "• Image security (latest tags, pull policies)"
    echo "• CPU and memory configurations"
    
    echo
    echo "Kubernetes resource detected:"
    local kind
    kind=$(grep "^kind:" "$FILE_PATH" 2>/dev/null | head -1)
    if [[ -n "$kind" ]]; then
        echo "$kind"
    else
        echo "Unknown resource type"
    fi
    
    echo
    return 0
}