#!/bin/bash
# Pure jq JSON Schema Validator for portx
# No external dependencies - uses existing jq in portx

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JQ_CMD="$SCRIPT_DIR/../packages/jq/jq.exe"

validate_portx_schema() {
    local json_file="$1"
    local errors=0
    
    echo "Validating: $json_file"
    
    # Check JSON syntax
    if ! cat "$json_file" | "$JQ_CMD" empty 2>/dev/null; then
        echo "ERROR: Invalid JSON syntax"
        return 1
    fi
    
    # Required fields validation
    local required_fields=("name" "version" "description")
    for field in "${required_fields[@]}"; do
        if ! cat "$json_file" | "$JQ_CMD" -e ".$field" >/dev/null 2>&1; then
            echo "ERROR: Missing required field: $field"
            ((errors++))
        fi
    done
    
    # Name validation (lowercase, alphanumeric with hyphens)
    local name=$(cat "$json_file" | "$JQ_CMD" -r '.name // empty')
    if [[ -n "$name" && ! "$name" =~ ^[a-z0-9]([a-z0-9-])*[a-z0-9]?$ ]]; then
        echo "ERROR: Invalid name format: $name (must be lowercase alphanumeric with hyphens)"
        ((errors++))
    fi
    
    # Version validation (looks like a version)
    local version=$(cat "$json_file" | "$JQ_CMD" -r '.version // empty')
    if [[ -n "$version" && ! "$version" =~ ^[0-9]+(\.[0-9]+)*$ ]]; then
        echo "ERROR: Invalid version format: $version (must look like a version: x.y or x.y.z etc)"
        ((errors++))
    fi
    
    # ImportType validation
    local import_type=$(cat "$json_file" | "$JQ_CMD" -r '.importType // empty')
    if [[ -z "$import_type" ]]; then
        echo "ERROR: Missing required field: importType"
        ((errors++))
    elif [[ ! "$import_type" =~ ^(wrap|path|none)$ ]]; then
        echo "ERROR: Invalid importType: $import_type (must be: wrap, path, or none)"
        ((errors++))
    fi
    
    # Conditional validation based on importType
    if [[ "$import_type" == "wrap" ]]; then
        if ! cat "$json_file" | "$JQ_CMD" -e '.bin' >/dev/null 2>&1; then
            echo "ERROR: bin required when importType is 'wrap'"
            ((errors++))
        fi
    fi
    
    # Bin validation (if present)
    if cat "$json_file" | "$JQ_CMD" -e '.bin' >/dev/null 2>&1; then
        # Check each tool in bin using for loop to avoid subshell issues
        local tools_array=($(cat "$json_file" | "$JQ_CMD" -r '.bin | keys[]' 2>/dev/null))
        for tool in "${tools_array[@]}"; do
            [[ -z "$tool" ]] && continue
            
            # Check required tool fields
            if ! cat "$json_file" | "$JQ_CMD" -e ".bin.\"$tool\".path" >/dev/null 2>&1; then
                echo "ERROR: Missing path for tool: $tool"
                ((errors++))
            fi
            
            if ! cat "$json_file" | "$JQ_CMD" -e ".bin.\"$tool\".description" >/dev/null 2>&1; then
                echo "ERROR: Missing description for tool: $tool"
                ((errors++))
            fi
            
            # Path validation (must be relative, end with .exe/.cmd/.bat)
            local tool_path=$(cat "$json_file" | "$JQ_CMD" -r ".bin.\"$tool\".path // empty")
            if [[ -n "$tool_path" ]]; then
                if [[ "$tool_path" == /* ]]; then
                    echo "ERROR: Tool path must be relative (not absolute): $tool_path"
                    ((errors++))
                fi
                
                if [[ ! "$tool_path" =~ \.(exe|cmd|bat)$ ]]; then
                    echo "ERROR: Tool path must end with .exe, .cmd, or .bat: $tool_path"
                    ((errors++))
                fi
            fi
            
        done
    fi
    
    if [[ $errors -eq 0 ]]; then
        echo "SUCCESS: Schema validation passed"
        return 0
    else
        echo "FAILED: $errors validation errors found"
        return 1
    fi
}

# Command line usage
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -ne 1 ]]; then
        echo "Usage: $0 <portx.json>"
        exit 1
    fi
    
    validate_portx_schema "$1"
fi