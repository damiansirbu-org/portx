#!/bin/bash
# =============================================================================
# DEPENDENCY REVERSE ANALYZER - Reverse Dependency Analysis
# Find what files/modules depend ON this file (reverse dependencies)
# Searches 5 levels up recursively with rg to find reverse dependencies
# =============================================================================

# Source filesystem utilities
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/fs-utils.sh"

# Register this analyzer
AVAILABLE_ANALYZERS+=("analyze_dependency_reverse")

analyze_dependency_reverse() {
    # Initialize analysis environment using shared utilities
    if ! init_dependency_analysis "$FILE_PATH"; then
        return_error '{"analyzer":"dependency_reverse","status":"tool_unavailable","details":"ripgrep not found at expected path"}'
        return
    fi
    
    # Use smart project root detection
    local root_result search_root project_root_found
    root_result=$(find_project_root "$FILE_PATH")
    search_root=$(echo "$root_result" | "$GOJQ_PATH" -r '.search_root')
    project_root_found=$(echo "$root_result" | "$GOJQ_PATH" -r '.project_root_found')
    
    
    local reverse_dependencies=()
    local importers=()
    local referrers=()
    local includers=()
    
    # Build reverse dependency patterns based on file type
    case "$file_ext" in
        py|pyi)
            # Find files importing this module
            # Look for "import module_name" or "from module_name import"
            reverse_dependencies+=($(timeout 15 "$rg_path" --json --type py \
                -e "import\s+$file_basename_no_ext(\s|$)" \
                -e "from\s+$file_basename_no_ext\s+import" \
                -e "from\s+.*\.$file_basename_no_ext\s+import" \
                "$search_root" 2>/dev/null | head -40))
            
            # Find files that might import from relative paths
            local relative_path="${FILE_PATH#$search_root/}"
            local module_path="${relative_path%.*}"
            local module_path_dotted="${module_path//\//.}"
            
            if [[ -n "$module_path_dotted" ]]; then
                reverse_dependencies+=($(timeout 15 "$rg_path" --json --type py \
                    -e "import\s+$module_path_dotted" \
                    -e "from\s+$module_path_dotted\s+import" \
                    "$search_root" 2>/dev/null | head -30))
            fi
            
            # Look for function/class usage (if this file exports common names)
            local exports
            exports=$(timeout 5 "$rg_path" --no-heading -o \
                -e "^def\s+([a-zA-Z_][a-zA-Z0-9_]*)" \
                -e "^class\s+([a-zA-Z_][a-zA-Z0-9_]*)" \
                -r '$1' "$FILE_PATH" 2>/dev/null | head -10)
            
            if [[ -n "$exports" ]]; then
                while IFS= read -r export_name; do
                    if [[ -n "$export_name" ]]; then
                        referrers+=($(timeout 10 "$rg_path" --json --type py \
                            -e "$export_name\s*\(" -e "$export_name\s*=" \
                            "$search_root" 2>/dev/null | head -20))
                    fi
                done <<< "$exports"
            fi
            ;;
            
        java)
            # Get package and class name
            local package_name class_name
            package_name=$(timeout 5 "$rg_path" --no-heading -o \
                -e "package\s+([a-zA-Z_][a-zA-Z0-9_.]*)" \
                -r '$1' "$FILE_PATH" 2>/dev/null | head -1)
            class_name="$file_basename_no_ext"
            
            if [[ -n "$package_name" && -n "$class_name" ]]; then
                # Find imports of this specific class
                reverse_dependencies+=($(timeout 15 "$rg_path" --json --type java \
                    -e "import\s+$package_name\.$class_name" \
                    -e "import\s+$package_name\.\*" \
                    "$search_root" 2>/dev/null | head -30))
                
                # Find usage of the class name (instantiation, static calls)
                referrers+=($(timeout 15 "$rg_path" --json --type java \
                    -e "new\s+$class_name\s*\(" \
                    -e "$class_name\." \
                    -e "$class_name\s+\w+" \
                    "$search_root" 2>/dev/null | head -40))
            fi
            
            # Also search for simple class name usage without package
            reverse_dependencies+=($(timeout 10 "$rg_path" --json --type java \
                -e "import.*\.$class_name\s*;" \
                "$search_root" 2>/dev/null | head -20))
            ;;
            
        js|jsx|ts|tsx)
            # Find files importing this module
            local relative_from_root="${FILE_PATH#$search_root/}"
            local import_path_base="${relative_from_root%.*}"
            
            # Look for relative and absolute imports
            reverse_dependencies+=($(timeout 15 "$rg_path" --json --type js --type ts \
                -e "import.*from\s+['\"][^'\"]*$file_basename_no_ext['\"]" \
                -e "import.*from\s+['\"]\..*$import_path_base['\"]" \
                -e "require\(['\"][^'\"]*$file_basename_no_ext['\"]\)" \
                -e "require\(['\"]\..*$import_path_base['\"]\)" \
                "$search_root" 2>/dev/null | head -35))
            
            # Find dynamic imports
            reverse_dependencies+=($(timeout 10 "$rg_path" --json --type js --type ts \
                -e "import\(['\"][^'\"]*$file_basename_no_ext['\"]\)" \
                "$search_root" 2>/dev/null | head -15))
            
            # Look for exported functions/classes usage
            local exports
            exports=$(timeout 5 "$rg_path" --no-heading -o \
                -e "export\s+(function\s+)?([a-zA-Z_][a-zA-Z0-9_]*)" \
                -e "export\s+default\s+([a-zA-Z_][a-zA-Z0-9_]*)" \
                -e "export\s+\{([^}]+)\}" \
                "$FILE_PATH" 2>/dev/null | head -10)
            
            if [[ -n "$exports" ]]; then
                # Extract actual export names and search for usage
                while IFS= read -r export_line; do
                    local export_names
                    export_names=$(echo "$export_line" | sed -E 's/.*export[^{]*\{([^}]+)\}.*/\1/' | tr ',' '\n' | sed 's/^\s*//;s/\s*$//' | head -5)
                    while IFS= read -r export_name; do
                        if [[ -n "$export_name" && "$export_name" != "$export_line" ]]; then
                            referrers+=($(timeout 10 "$rg_path" --json --type js --type ts \
                                -e "$export_name\s*\(" -e "$export_name\s*=" \
                                "$search_root" 2>/dev/null | head -15))
                        fi
                    done <<< "$export_names"
                done <<< "$exports"
            fi
            ;;
            
        sh|bash)
            # Find files sourcing this script
            local script_name="$file_basename"
            reverse_dependencies+=($(timeout 10 "$rg_path" --json --type sh \
                -e "source\s+.*$script_name" \
                -e "\.\s+.*$script_name" \
                -e "bash\s+.*$script_name" \
                "$search_root" 2>/dev/null | head -25))
            
            # Find function definitions and their usage across scripts
            local functions
            functions=$(timeout 5 "$rg_path" --no-heading -o \
                -e "^([a-zA-Z_][a-zA-Z0-9_]*)\s*\(\)" \
                -e "function\s+([a-zA-Z_][a-zA-Z0-9_]*)" \
                -r '$1' "$FILE_PATH" 2>/dev/null | head -8)
            
            if [[ -n "$functions" ]]; then
                while IFS= read -r func_name; do
                    if [[ -n "$func_name" ]]; then
                        referrers+=($(timeout 10 "$rg_path" --json --type sh \
                            -e "$func_name\s*\(" -e "$func_name\s+.*" \
                            "$search_root" 2>/dev/null | head -20))
                    fi
                done <<< "$functions"
            fi
            ;;
            
        go)
            # Go files - search for imports of this package
            local package_path="$1"
            local patterns=(
                "import\\s+\".*$(basename "$package_path" .go)\""
                "\".*$(basename "$package_path" .go)\""
            )
            ;;
            
        *) 
            return_error '{"analyzer":"dependency_reverse","status":"unsupported_file_type","details":"File extension not supported for reverse dependency analysis"}'
            return
            ;;
    esac
    
    # Process and format results
    local dependency_count=0
    local referrer_count=0
    local processed_dependencies="[]"
    local processed_referrers="[]"
    
    if [[ ${#reverse_dependencies[@]} -gt 0 ]]; then
        local dep_json=""
        for dep in "${reverse_dependencies[@]}"; do
            if [[ -n "$dep" ]]; then
                if [[ -n "$dep_json" ]]; then
                    dep_json+=","
                fi
                dep_json+="$dep"
                ((dependency_count++))
            fi
        done
        if [[ -n "$dep_json" ]]; then
            processed_dependencies="[$dep_json]"
        fi
    fi
    
    if [[ ${#referrers[@]} -gt 0 ]]; then
        local ref_json=""
        for ref in "${referrers[@]}"; do
            if [[ -n "$ref" ]]; then
                if [[ -n "$ref_json" ]]; then
                    ref_json+=","
                fi
                ref_json+="$ref"
                ((referrer_count++))
            fi
        done
        if [[ -n "$ref_json" ]]; then
            processed_referrers="[$ref_json]"
        fi
    fi
    
    # Output comprehensive JSON structure
    local escaped_file_path escaped_search_root
    escaped_file_path=$(printf '%s' "$FILE_PATH" | sed 's/\\/\\\\/g; s/"/\\"/g')
    escaped_search_root=$(printf '%s' "$search_root" | sed 's/\\/\\\\/g; s/"/\\"/g')
    
    local result_json
    result_json=$(printf '{"analyzer":"dependency_reverse","file":"%s","language":"%s","search_scope":{"root":"%s","project_root_found":%s,"search_strategy":"%s"},"reverse_analysis":{"importers":{"count":%d,"found":%s},"referrers":{"count":%d,"patterns":%s},"total_reverse_deps":%d},"metadata":{"analyzed_at":"%s","search_timeout":"30s","note":"Shows files that depend ON this file"}}' \
        "$escaped_file_path" \
        "$file_ext" \
        "$escaped_search_root" \
        "$project_root_found" \
        "$([[ "$project_root_found" == true ]] && echo "project_tree_search" || echo "local_directory_search")" \
        "$dependency_count" \
        "$processed_dependencies" \
        "$referrer_count" \
        "$processed_referrers" \
        $((dependency_count + referrer_count)) \
        "$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "unknown")")
    return_success "$result_json"
}