#!/bin/bash
# Auto-generate package.json files for PORTX packages

set -euo pipefail

GIT_BASH_ROOT="${GIT_BASH_ROOT:-/c/App/Git}"
PACKAGES_DIR="$GIT_BASH_ROOT/home/portx/packages"

printf "Generating package.json files...\n"

# Collect all executables for AI description batch
all_executables=()
all_packages=()

for pkg_path in "$PACKAGES_DIR"/*; do
    if [[ -d "$pkg_path" ]]; then
        pkg_name="$(basename "$pkg_path")"
        executables=$(find "$pkg_path" -maxdepth 1 -name "*.exe" 2>/dev/null || true)
        
        if [[ -n "$executables" ]]; then
            while IFS= read -r exe_file; do
                if [[ -n "$exe_file" ]]; then
                    exe_name=$(basename "$exe_file")
                    all_executables+=("$exe_name")
                    all_packages+=("$pkg_name")
                fi
            done <<<"$executables"
        fi
    fi
done

printf "Found %d executables across %d packages\n" "${#all_executables[@]}" "${#all_packages[@]}"
printf "Executables to describe: %s\n" "${all_executables[*]}"

# TODO: Send to AI for descriptions
# For now, create JSONs with placeholder descriptions

for pkg_path in "$PACKAGES_DIR"/*; do
    if [[ -d "$pkg_path" ]]; then
        pkg_name="$(basename "$pkg_path")"
        executables=$(find "$pkg_path" -maxdepth 1 -name "*.exe" 2>/dev/null || true)
        
        if [[ -z "$executables" ]]; then
            continue
        fi
        
        # Get package version (placeholder for now)
        pkg_version="1.0.0"
        
        # Start building JSON
        json_content='{"name":"'$pkg_name'","version":"'$pkg_version'","tools":['
        
        first_tool=true
        while IFS= read -r exe_file; do
            if [[ -n "$exe_file" ]]; then
                exe_name=$(basename "$exe_file")
                
                # Check dependencies using ldd
                dependencies=""
                local_deps=$(ldd "$exe_file" 2>/dev/null | grep -v "/c/Windows/" | grep -v "not found" | grep "=>" || true)
                if [[ -n "$local_deps" ]]; then
                    # Has local dependencies - extract DLL names
                    deps_array=$(echo "$local_deps" | awk '{print $1}' | tr '\n' ',' | sed 's/,$//')
                    dependencies='"'$deps_array'"'
                else
                    dependencies='[]'
                fi
                
                # Add comma if not first tool
                if [[ "$first_tool" == "false" ]]; then
                    json_content+=','
                fi
                first_tool=false
                
                # Add tool entry
                json_content+='{"executable":"'$exe_name'","description":"TODO: Add description","dependencies":['$dependencies']}'
            fi
        done <<<"$executables"
        
        json_content+='],"paths":["./"]}'
        
        # Write JSON file
        printf "%s" "$json_content" | jq '.' > "$pkg_path/package.json"
        printf "Generated: %s/package.json\n" "$pkg_path"
    fi
done

printf "Generated package.json files. Descriptions need to be filled by AI.\n"