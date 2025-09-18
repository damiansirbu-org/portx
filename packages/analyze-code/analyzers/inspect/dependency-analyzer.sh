#!/bin/bash
# =============================================================================
# DEPENDENCY ANALYZER (IMPROVED) - Forward Dependency Analysis 
# Shows what THIS file depends ON - with actual file names and relationships
# =============================================================================

# Source filesystem utilities
source "$(dirname "${BASH_SOURCE[0]}")/../../lib/fs-utils.sh"

# Register this analyzer
AVAILABLE_ANALYZERS+=("analyze_dependency")

analyze_dependency() {
    # Initialize analysis environment using shared utilities
    if ! init_dependency_analysis "$FILE_PATH"; then
        return_error '{"analyzer":"dependency","status":"tool_unavailable","details":"ripgrep not found at expected path"}'
        return
    fi
    
    # Use smart project root detection
    local root_result search_root project_root_found
    root_result=$(find_project_root "$FILE_PATH")
    search_root=$(echo "$root_result" | "$GOJQ_PATH" -r '.search_root')
    project_root_found=$(echo "$root_result" | "$GOJQ_PATH" -r '.project_root_found')
    
    local imports_this_file=()
    local dependency_files=()
    
    # Extract dependencies THIS file has
    case "$FILE_EXT" in
        py|pyi)
            # Find what THIS file imports
            local raw_imports
            raw_imports=$(timeout 10 "$RIPGREP_PATH" --no-heading --line-number \
                -e "^import\s+([a-zA-Z_][a-zA-Z0-9_.]*)" \
                -e "^from\s+([a-zA-Z_][a-zA-Z0-9_.]*)\s+import\s+(.+)" \
                "$FILE_PATH" 2>/dev/null)
            
            if [[ -n "$raw_imports" ]]; then
                while IFS= read -r import_line; do
                    local line_num module_name import_detail
                    if [[ "$import_line" =~ ([0-9]+):.* ]]; then
                        line_num="${BASH_REMATCH[1]}"
                        if [[ "$import_line" =~ import[[:space:]]+([a-zA-Z_][a-zA-Z0-9_.]*) ]]; then
                            module_name="${BASH_REMATCH[1]}"
                            import_detail=$(echo "$import_line" | sed 's/^[0-9]*://' | sed 's/^[[:space:]]*//')
                            # Use safe JSON construction with proper escaping
                            local import_json
                            import_json=$(json_object \
                                "line" "$line_num" \
                                "module" "$module_name" \
                                "statement" "$import_detail" \
                                "type" "import")
                            imports_this_file+=("$import_json")
                            
                            # Try to find actual files for this module
                            local possible_files
                            possible_files=$(find_files_by_name "*${module_name}*.py" "$search_root" | head -10)
                            
                            if [[ -n "$possible_files" ]]; then
                                while IFS= read -r found_file; do
                                    if [[ -n "$found_file" && "$found_file" != "$FILE_PATH" ]]; then
                                        # Use safe JSON construction
                                        local dep_json
                                        dep_json=$(json_object \
                                            "imported_module" "$module_name" \
                                            "file_path" "$found_file" \
                                            "relationship" "direct_import")
                                        dependency_files+=("$dep_json")
                                    fi
                                done <<< "$possible_files"
                            fi
                        fi
                    fi
                done <<< "$raw_imports"
            fi
            ;;
            
        java)
            # Find imports in THIS Java file
            local raw_imports
            raw_imports=$(timeout 10 "$RIPGREP_PATH" --no-heading --line-number \
                -e "^import\s+([a-zA-Z_][a-zA-Z0-9_.]*)" \
                "$FILE_PATH" 2>/dev/null)
            
            if [[ -n "$raw_imports" ]]; then
                while IFS= read -r import_line; do
                    local line_num import_class
                    if [[ "$import_line" =~ ([0-9]+):.* ]]; then
                        line_num="${BASH_REMATCH[1]}"
                        if [[ "$import_line" =~ import[[:space:]]+([a-zA-Z_][a-zA-Z0-9_.]*) ]]; then
                            import_class="${BASH_REMATCH[1]}"
                            local class_name="${import_class##*.}"
                            local import_detail=$(echo "$import_line" | sed 's/^[0-9]*://' | sed 's/^[[:space:]]*//')
                            # Use safe JSON construction with proper escaping
                            local import_json
                            import_json=$(json_object \
                                "line" "$line_num" \
                                "class" "$import_class" \
                                "statement" "$import_detail" \
                                "type" "import")
                            imports_this_file+=("$import_json")
                            
                            # Try to find the actual Java file for this class
                            local possible_files
                            possible_files=$(find_files_by_name "${class_name}.java" "$search_root" | head -5)
                            
                            if [[ -n "$possible_files" ]]; then
                                while IFS= read -r found_file; do
                                    if [[ -n "$found_file" && "$found_file" != "$FILE_PATH" ]]; then
                                        # Use safe JSON construction
                                        local dep_json
                                        dep_json=$(json_object \
                                            "imported_class" "$import_class" \
                                            "file_path" "$found_file" \
                                            "relationship" "direct_import")
                                        dependency_files+=("$dep_json")
                                    fi
                                done <<< "$possible_files"
                            fi
                        fi
                    fi
                done <<< "$raw_imports"
            fi
            ;;
            
        js|jsx|ts|tsx)
            # Find imports/requires in THIS file
            local raw_imports
            raw_imports=$(timeout 10 "$RIPGREP_PATH" --no-heading --line-number \
                -e "import.*from\s+['\"]([^'\"]+)['\"]" \
                -e "require\(['\"]([^'\"]+)['\"]\)" \
                -e "import\(['\"]([^'\"]+)['\"]\)" \
                "$FILE_PATH" 2>/dev/null)
            
            if [[ -n "$raw_imports" ]]; then
                while IFS= read -r import_line; do
                    local line_num module_path
                    if [[ "$import_line" =~ ([0-9]+):.* ]]; then
                        line_num="${BASH_REMATCH[1]}"
                        if [[ "$import_line" =~ \"([^\"]+)\" ]] || [[ "$import_line" =~ \'([^\']+)\' ]]; then
                            module_path="${BASH_REMATCH[1]}"
                            local import_detail=$(echo "$import_line" | sed 's/^[0-9]*://' | sed 's/^[[:space:]]*//')
                            # Use safe JSON construction with proper escaping
                            local import_json
                            import_json=$(json_object \
                                "line" "$line_num" \
                                "module" "$module_path" \
                                "statement" "$import_detail" \
                                "type" "import")
                            imports_this_file+=("$import_json")
                            
                            # For relative imports, try to resolve to actual files
                            if [[ "$module_path" =~ ^\. ]]; then
                                local base_dir="$(dirname "$FILE_PATH")"
                                local resolved_path=""
                                case "$module_path" in
                                    ./*)  resolved_path="$base_dir/${module_path#./}" ;;
                                    ../*)
                                        local parent_dir="$(dirname "$base_dir")"
                                        resolved_path="$parent_dir/${module_path#../}"
                                        ;;
                                esac
                                
                                # Find files with common extensions using es
                                local found_files
                                found_files=$(find_files_by_name "$(basename "$resolved_path").*" "$(dirname "$resolved_path")" | grep -E '\.(js|jsx|ts|tsx)$' | head -1)
                                if [[ -n "$found_files" ]]; then
                                    # Use safe JSON construction
                                    local dep_json
                                    dep_json=$(json_object \
                                        "imported_module" "$module_path" \
                                        "file_path" "$found_files" \
                                        "relationship" "relative_import")
                                    dependency_files+=("$dep_json")
                                fi
                            fi
                        fi
                    fi
                done <<< "$raw_imports"
            fi
            ;;
            
        sh|bash)
            # Find sourced files
            local raw_sources
            raw_sources=$(timeout 10 "$RIPGREP_PATH" --no-heading --line-number \
                -e "source\s+([^;]+)" \
                -e "\.\s+([^;#]+)" \
                "$FILE_PATH" 2>/dev/null)
            
            if [[ -n "$raw_sources" ]]; then
                while IFS= read -r source_line; do
                    local line_num sourced_file
                    if [[ "$source_line" =~ ([0-9]+):.* ]]; then
                        line_num="${BASH_REMATCH[1]}"
                        local source_detail=$(echo "$source_line" | sed 's/^[0-9]*://' | sed 's/^[[:space:]]*//')
                        
                        # Extract the file path from source command
                        if [[ "$source_detail" =~ source[[:space:]]+([^[:space:]]+) ]] || [[ "$source_detail" =~ \.[[:space:]]+([^[:space:]]+) ]]; then
                            sourced_file="${BASH_REMATCH[1]}"
                            # Remove quotes if present
                            sourced_file="${sourced_file//\"/}"
                            sourced_file="${sourced_file//\'/}"
                            
                            # Use safe JSON construction with proper escaping
                            local import_json
                            import_json=$(json_object \
                                "line" "$line_num" \
                                "file" "$sourced_file" \
                                "statement" "$source_detail" \
                                "type" "source")
                            imports_this_file+=("$import_json")
                            
                            # Try to resolve relative paths
                            local resolved_file=""
                            if [[ "$sourced_file" =~ ^/ ]]; then
                                # Absolute path
                                resolved_file="$sourced_file"
                            else
                                # Relative path
                                local base_dir="$(dirname "$FILE_PATH")"
                                resolved_file="$base_dir/$sourced_file"
                            fi
                            
                            if [[ -f "$resolved_file" ]]; then
                                # Use safe JSON construction
                                local dep_json
                                dep_json=$(json_object \
                                    "sourced_file" "$sourced_file" \
                                    "file_path" "$resolved_file" \
                                    "relationship" "source_dependency")
                                dependency_files+=("$dep_json")
                            fi
                        fi
                    fi
                done <<< "$raw_sources"
            fi
            ;;
            
        *) 
            return_error '{"analyzer":"dependency","status":"unsupported_file_type","details":"File extension not supported for dependency analysis"}'
            return
            ;;
    esac
    
    # Format output with actual file names and relationships
    local imports_json="[]"
    local dependencies_json="[]"
    
    if [[ ${#imports_this_file[@]} -gt 0 ]]; then
        imports_json="[$(IFS=,; echo "${imports_this_file[*]}")]"
    fi
    
    if [[ ${#dependency_files[@]} -gt 0 ]]; then
        dependencies_json="[$(IFS=,; echo "${dependency_files[*]}")]"
    fi
    
    # Output clear JSON with actual files and relationships
    local result_json
    result_json=$(printf '{"analyzer":"dependency","file":"%s","language":"%s","search_scope":{"root":"%s","project_root_found":%s},"dependencies":{"imports_in_this_file":{"count":%d,"details":%s},"resolved_dependencies":{"count":%d,"files":%s}},"metadata":{"analyzed_at":"%s","note":"Shows what THIS file depends ON"}}' \
        "$FILE_PATH" \
        "$FILE_EXT" \
        "$search_root" \
        "$project_root_found" \
        "${#imports_this_file[@]}" \
        "$imports_json" \
        "${#dependency_files[@]}" \
        "$dependencies_json" \
        "$(date -u +%Y-%m-%dT%H:%M:%SZ 2>/dev/null || echo "unknown")")
    return_success "$result_json"
}