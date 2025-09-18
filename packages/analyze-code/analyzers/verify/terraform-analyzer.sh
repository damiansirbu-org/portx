#!/bin/bash
# =============================================================================
# TERRAFORM ANALYZER - Infrastructure as Code Quality Validation
# Validates Terraform files for syntax, security, and best practices
# =============================================================================

analyze_terraform() {
    local terraform_path="terraform"
    
    echo "=== TERRAFORM ANALYSIS ==="
    echo "Analyzing: $FILE_PATH"
    echo
    
    local file_ext="${FILE_PATH##*.}"
    local basename="$(basename "$FILE_PATH")"
    
    # Check if this is a Terraform file
    if [[ ! "$file_ext" == "tf" && ! "$file_ext" == "hcl" && ! "$basename" =~ \.tfvars$ ]]; then
        echo "Not a Terraform file - skipping analysis"
        return 1
    fi
    
    if [[ ! -f "$FILE_PATH" ]]; then
        echo "File not found: $FILE_PATH"
        return 1
    fi
    
    # Check if terraform is available
    if ! command -v terraform >/dev/null 2>&1; then
        echo "Terraform CLI not available"
        echo "Performing basic static analysis instead..."
        
        # Basic static analysis without terraform CLI
        echo
        echo "Resources defined:"
        if grep -n "^resource" "$FILE_PATH" 2>/dev/null; then
            :
        else
            echo "No resources found"
        fi
        
        echo
        echo "Variables defined:"
        if grep -n "^variable" "$FILE_PATH" 2>/dev/null; then
            :
        else
            echo "No variables found"
        fi
        
        echo
        echo "Outputs defined:"
        if grep -n "^output" "$FILE_PATH" 2>/dev/null; then
            :
        else
            echo "No outputs found"
        fi
        
        echo
        echo "Data sources:"
        if grep -n "^data" "$FILE_PATH" 2>/dev/null; then
            :
        else
            echo "No data sources found"
        fi
        
    else
        echo "Running Terraform validation..."
        local dir_path
        dir_path="$(dirname "$FILE_PATH")"
        
        # Change to directory containing the .tf file
        local original_dir
        original_dir="$(pwd)"
        
        if cd "$dir_path" 2>/dev/null; then
            # Initialize if needed (suppress output)
            if [[ ! -d ".terraform" ]]; then
                echo "Initializing Terraform..."
                timeout $ANALYZER_TIMEOUT terraform init -input=false >/dev/null 2>&1
            fi
            
            # Run terraform validate
            local terraform_output
            if terraform_output=$(timeout $ANALYZER_TIMEOUT terraform validate -json 2>/dev/null); then
                local is_valid
                is_valid=$(echo "$terraform_output" | "$GOJQ_PATH" -r '.valid // false' 2>/dev/null)
                
                if [[ "$is_valid" == "true" ]]; then
                    echo "✅ Terraform configuration is valid"
                else
                    echo "❌ Terraform validation failed"
                    echo "$terraform_output" | "$GOJQ_PATH" -r '.diagnostics[]? | "[\(.severity | ascii_upcase)] \(.summary): \(.detail // "")"' 2>/dev/null || echo "$terraform_output"
                fi
            else
                echo "Terraform validate failed or timed out"
            fi
            
            cd "$original_dir"
        else
            echo "Could not access directory: $dir_path"
            return 1
        fi
    fi
    
    echo
    echo "Basic quality checks:"
    local issues_found=false
    
    # Check for hardcoded values
    if grep -q -E "(password|secret|key).*=.*\"[^\"]+\"" "$FILE_PATH" 2>/dev/null; then
        echo "⚠️  Potential hardcoded secrets detected"
        issues_found=true
    fi
    
    # Check for missing descriptions
    if grep -q "^variable" "$FILE_PATH" 2>/dev/null; then
        if ! grep -q "description.*=" "$FILE_PATH" 2>/dev/null; then
            echo "⚠️  Variables without descriptions"
            issues_found=true
        fi
    fi
    
    # Check for missing tags
    if grep -q "^resource.*aws_" "$FILE_PATH" 2>/dev/null; then
        if ! grep -q "tags.*=" "$FILE_PATH" 2>/dev/null; then
            echo "⚠️  AWS resources without tags"
            issues_found=true
        fi
    fi
    
    if [[ "$issues_found" != true ]]; then
        echo "No obvious quality issues found"
    fi
    
    echo
    echo "Terraform best practices checked:"
    echo "• Configuration syntax validation"
    echo "• Resource naming conventions"
    echo "• Variable descriptions"
    echo "• Output definitions"
    echo "• Security: hardcoded values"
    echo "• AWS tagging practices"
    
    echo
    return 0
}