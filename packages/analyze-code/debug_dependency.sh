#!/bin/bash
export FILE_PATH="/c/Work/Git/damiansirbu/claude/hooks/analyze-hook/analyze-hook.sh"
source lib/settings.sh
source lib/core-utils.sh
setup_environment
source lib/json-utils.sh
load_analyzers inspect

echo "=== Debug dependency analyzer ==="
echo "FILE_PATH: '$FILE_PATH'"
echo "Available analyzer functions:"
declare -F | grep analyze_dependency

echo -e "\n=== Direct call ==="
analyze_dependency

echo -e "\n=== Pipeline call ==="
mapfile -t APPLICABLE_ANALYZERS < <(echo "analyze_dependency")
format_analysis_results
