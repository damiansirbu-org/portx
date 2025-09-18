#!/bin/bash
# =============================================================================
# KUBE-SCORE ANALYZER - Kubernetes Object Quality Scoring
# Scores Kubernetes objects based on security and reliability best practices
# =============================================================================

analyze_kube_score() {
    local kube_score_path="$GIT_BASH_ROOT/home/portx/packages/kube-score/kube-score.exe"
    
    echo "=== KUBE-SCORE ANALYSIS ==="
    echo "Analyzing: $FILE_PATH"
    echo
    
    # Check if this is a Kubernetes YAML file
    local file_ext="${FILE_PATH##*.}"
    if [[ ! "$file_ext" =~ ^(yaml|yml)$ ]]; then
        echo "Not a YAML file - skipping kube-score analysis"
        return 1
    fi
    
    # Quick check if it's actually Kubernetes YAML
    if ! timeout 5 grep -q -E "apiVersion:|kind:" "$FILE_PATH" 2>/dev/null; then
        echo "Not a Kubernetes YAML file - skipping kube-score analysis"
        return 1
    fi
    
    # Check if kube-score is available
    if [[ ! -f "$kube_score_path" ]]; then
        echo "kube-score not available at $kube_score_path"
        echo "Please install kube-score for Kubernetes quality scoring"
        return 1
    fi
    
    echo "Running kube-score analysis..."
    local kube_score_output
    if kube_score_output=$(timeout $ANALYZER_TIMEOUT "$kube_score_path" score --output-format json "$FILE_PATH" 2>/dev/null); then
        if [[ -n "$kube_score_output" && "$kube_score_output" != "null" ]]; then
            # Parse and display results
            echo "Quality assessment:"
            echo "$kube_score_output" | "$GOJQ_PATH" -r '.[]? | "[\(.Grade // "UNKNOWN")] \(.ObjectName // "unknown") - \(.Check.Name): \(.Check.Comment // "No details")"' 2>/dev/null || {
                echo "Raw output:"
                echo "$kube_score_output"
            }
        else
            echo "✅ No scoring issues found - Kubernetes objects are well configured"
        fi
    else
        echo "kube-score analysis failed or timed out"
        return 1
    fi
    
    echo
    echo "kube-score quality checks:"
    echo "• Container security practices"
    echo "• Resource specifications"
    echo "• Health check configurations"  
    echo "• Pod disruption budgets"
    echo "• Network security policies"
    echo "• Service configuration quality"
    echo "• Deployment best practices"
    echo "• StatefulSet configurations"
    
    echo
    echo "Scoring grades:"
    echo "• CRITICAL: Must fix - security/reliability issue"
    echo "• WARNING: Should fix - best practice violation"
    echo "• OK: Well configured"
    
    echo
    local resource_info
    resource_info=$(grep -E "^(kind|metadata):" "$FILE_PATH" 2>/dev/null | head -2)
    if [[ -n "$resource_info" ]]; then
        echo "Resource information:"
        echo "$resource_info"
    fi
    
    echo
    return 0
}