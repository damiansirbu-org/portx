#!/bin/bash
export FILE_PATH="/c/Work/Git/damiansirbu/claude/hooks/analyze-hook/analyze-hook.sh"
source lib/settings.sh
source lib/core-utils.sh
setup_environment
source lib/json-utils.sh

# Copy load_analyzers function from main script
load_analyzers() {
    local action="$1"
    local analyzer_subdir="$ANALYZER_DIR/analyzers/$action"
    for analyzer_file in "$analyzer_subdir"/*.sh; do
        if [[ -f "$analyzer_file" ]]; then
            source "$analyzer_file"
        fi
    done
}

load_analyzers inspect

echo "=== Debug dependency analyzer ==="
echo "FILE_PATH: '$FILE_PATH'"
echo "ANALYZER_DIR: '$ANALYZER_DIR'"
echo "Available analyzer functions:"
declare -F | grep analyze_dependency

if declare -F analyze_dependency >/dev/null; then
    echo -e "\n=== Direct call ==="
    analyze_dependency
    
    echo -e "\n=== Testing in pipeline context ==="
    # Test what format_analysis_results does
    mapfile -t APPLICABLE_ANALYZERS < <(echo "analyze_dependency")
    echo "APPLICABLE_ANALYZERS: ${APPLICABLE_ANALYZERS[*]}"
    
    # Manual test of what format_analysis_results does
    analyzer_result=$(analyze_dependency 2>&1)
    echo "Raw analyzer result length: ${#analyzer_result}"
    echo "Raw analyzer result: $analyzer_result"
else
    echo "analyze_dependency function not found!"
fi

echo -e "\n=== Testing format_analysis_results parsing ==="
echo "JSON_GOJQ_PATH: '$JSON_GOJQ_PATH'"
echo "GOJQ_PATH: '$GOJQ_PATH'"

analyzer_result='{"output":{"analyzer":"dependency","test":"data"},"return_code":"SUCCESS"}'
echo "Test JSON: $analyzer_result"

return_code=$(echo "$analyzer_result" | "$JSON_GOJQ_PATH" -r '.return_code // "ERROR"' 2>/dev/null)
output_data=$(echo "$analyzer_result" | "$JSON_GOJQ_PATH" -r '.output // ""' 2>/dev/null)

echo "Parsed return_code: '$return_code'"
echo "Parsed output_data length: ${#output_data}"
echo "Parsed output_data: $output_data"
