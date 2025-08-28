# PORTX Package.json Rewrite Project

## Tomorrow's Tasks

### 1. Establish Code Pattern for package.json
- Define standard schema with **full executable paths** starting from package root
- Example: `"executable": "./bin/tool.exe"` or `"executable": "./tool.exe"`
- This eliminates path guessing and scanning complexity
- Standardize all required and optional fields

### 2. Define package.json Rules
- **NO JavaScript-style comments** (`//` or `/* */`)
- Clean JSON only - no comment parsing needed
- Consistent field naming and structure
- Mandatory fields vs optional fields
- Validation schema

### 3. Redo ALL 121 package.json files
- Go through each package directory one by one
- Scan actual filesystem to discover real executables
- Rewrite tools array with complete and accurate data
- Include full paths, descriptions, tags, defaultArgs
- Remove all comments and standardize format

### 4. Remove Strict Error Handling 
- **REMOVE `set -euo pipefail`** - it's hiding actual errors and messages
- We need to see what the fuck is actually failing
- Let errors show properly instead of silent failures
- Add proper error checking where needed, not blanket strict mode
- **⚠️ CRITICAL: If you add set -euo pipefail back, I will uninstall you ⚠️**

### 5. Better Debug Logging
- Improve debug_log() function with clearer output
- Add timestamps and better formatting
- More granular logging in critical functions
- Log wrapper creation success/failure with details
- Better error messages that actually help debugging

## Expected Outcome
- Fast performance (no fallback scanning needed)
- Accurate wrapper counts (249 executables → ~500 wrappers)
- Reliable package.json-first architecture
- Clean, maintainable package definitions
- **Visible errors and debugging info**
- **Proper error reporting instead of silent failures**

## Root Cause Analysis
The performance issues and wrapper count mismatches were caused by:
1. Incomplete/inaccurate `tools` arrays in package.json files
2. Complex fallback scanning when package.json parsing fails
3. JavaScript comments breaking JSON parsing
4. Missing full paths requiring filesystem discovery

Fix the data quality → fix the performance.