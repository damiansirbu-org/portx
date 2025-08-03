# SD Package Manual

## Package Information
- **Package Name**: sd
- **Category**: Text Processing
- **Type**: Stream Editor (sed replacement)
- **License**: MIT

## Description
Intuitive find and replace command-line tool designed as a modern replacement for sed.

SD provides a more user-friendly interface for text substitution with regex support, Unicode handling, and simplified syntax.
Features better error messages, sensible defaults, and cross-platform compatibility for text processing workflows.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| sd.exe | Stream editor for find and replace | Modern sed replacement with intuitive syntax |

## Basic Usage Examples

### Simple Text Replacement
```bash
# Replace all occurrences in file
sd 'old_text' 'new_text' file.txt

# Replace and save to new file
sd 'old_text' 'new_text' input.txt > output.txt

# In-place editing
sd 'old_text' 'new_text' -i file.txt

# Process multiple files
sd 'old_text' 'new_text' -i *.txt

# Read from stdin
echo "hello world" | sd 'world' 'universe'
```

### Regular Expression Patterns
```bash
# Basic regex replacement
sd '\d+' 'NUMBER' file.txt

# Capture groups
sd '(\w+) (\w+)' '$2, $1' names.txt

# Word boundaries
sd '\bcat\b' 'dog' text.txt

# Case insensitive replacement
sd -i '(?i)error' 'ERROR' log.txt

# Multiple patterns
sd 'foo|bar' 'baz' file.txt
```

### Advanced Pattern Matching
```bash
# Email address replacement
sd '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' '[EMAIL]' document.txt

# URL replacement
sd 'https?://[^\s]+' '[URL]' text.txt

# Phone number formatting
sd '(\d{3})(\d{3})(\d{4})' '$1-$2-$3' contacts.txt

# Remove HTML tags
sd '<[^>]*>' '' html_file.txt

# Extract specific patterns
sd '.*error: ([^,]+),.*' '$1' error_log.txt
```

## Comparison with Traditional sed

### Syntax Improvements
```bash
# Traditional sed (complex escaping)
sed 's/\([0-9]\+\)-\([0-9]\+\)/\2:\1/g' file.txt

# SD (cleaner syntax)
sd '(\d+)-(\d+)' '$2:$1' file.txt

# Traditional sed (delimiter confusion)
sed 's/\/path\/to\/old/\/path\/to\/new/g' paths.txt

# SD (no delimiter issues)
sd '/path/to/old' '/path/to/new' paths.txt
```

### Unicode and International Text
```bash
# Unicode character handling
sd 'café' 'coffee' menu.txt

# Emoji replacement
sd '😀' '🙂' social_media.txt

# Multi-byte character support
sd '北京' 'Beijing' chinese_text.txt

# Accented characters
sd 'naïve' 'naive' english_text.txt
```

## File Processing Workflows

### Batch File Processing
```bash
#!/bin/bash
# Batch text processing with sd

SEARCH_PATTERN=$1
REPLACE_TEXT=$2
FILE_PATTERN=${3:-"*.txt"}

echo "Processing files matching: $FILE_PATTERN"
echo "Pattern: $SEARCH_PATTERN -> $REPLACE_TEXT"

# Find and process files
find . -name "$FILE_PATTERN" -type f | while read file; do
    echo "Processing: $file"
    
    # Check if pattern exists in file
    if grep -q "$SEARCH_PATTERN" "$file"; then
        # Create backup
        cp "$file" "${file}.backup"
        
        # Apply replacement
        sd "$SEARCH_PATTERN" "$REPLACE_TEXT" -i "$file"
        
        echo "  ✓ Updated: $file"
    else
        echo "  - No changes needed: $file"
    fi
done

echo "Batch processing complete"
```

### Configuration File Updates
```bash
#!/bin/bash
# Update configuration files across projects

CONFIG_DIR="/path/to/configs"
OLD_VALUE=$1
NEW_VALUE=$2

echo "Updating configuration files..."

# Update database connections
sd "database_host=.*" "database_host=$NEW_VALUE" -i "$CONFIG_DIR"/*.conf

# Update API endpoints
sd "api_endpoint: ['\"].*['\"]" "api_endpoint: '$NEW_VALUE'" -i "$CONFIG_DIR"/*.yaml "$CONFIG_DIR"/*.yml

# Update environment variables
sd "export DATABASE_URL=.*" "export DATABASE_URL=$NEW_VALUE" -i "$CONFIG_DIR"/*.env

# Update JSON configurations
sd '"database_url":\s*"[^"]*"' "\"database_url\": \"$NEW_VALUE\"" -i "$CONFIG_DIR"/*.json

echo "Configuration update complete"
```

### Log Processing and Anonymization
```bash
#!/bin/bash
# Anonymize sensitive data in log files

LOG_FILE=$1
ANONYMIZED_FILE="${LOG_FILE}.anonymized"

echo "Anonymizing log file: $LOG_FILE"

# Copy original file
cp "$LOG_FILE" "$ANONYMIZED_FILE"

# Remove email addresses
sd '[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}' '[EMAIL_REDACTED]' -i "$ANONYMIZED_FILE"

# Remove phone numbers
sd '\b\d{3}[-.]?\d{3}[-.]?\d{4}\b' '[PHONE_REDACTED]' -i "$ANONYMIZED_FILE"

# Remove credit card numbers
sd '\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b' '[CARD_REDACTED]' -i "$ANONYMIZED_FILE"

# Remove IP addresses
sd '\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b' '[IP_REDACTED]' -i "$ANONYMIZED_FILE"

# Remove social security numbers
sd '\b\d{3}-\d{2}-\d{4}\b' '[SSN_REDACTED]' -i "$ANONYMIZED_FILE"

# Remove API keys and tokens
sd '(api[_-]?key|token|secret)["\s]*[:=]["\s]*[a-zA-Z0-9+/=]{20,}' '$1="[REDACTED]"' -i "$ANONYMIZED_FILE"

echo "Anonymization complete: $ANONYMIZED_FILE"
```

## Development and Code Refactoring

### Code Modernization
```bash
#!/bin/bash
# Modernize JavaScript/TypeScript code

PROJECT_DIR=$1

echo "Modernizing code in: $PROJECT_DIR"

# Convert var to let/const
sd '\bvar\b' 'let' -i "$PROJECT_DIR"/**/*.js

# Update function syntax
sd 'function\s+(\w+)\s*\(' 'const $1 = (' -i "$PROJECT_DIR"/**/*.js

# Convert to arrow functions
sd '\.function\s*\(' '.(' -i "$PROJECT_DIR"/**/*.js

# Update import statements
sd 'require\(["\']([^"\']+)["\']\)' 'import "$1"' -i "$PROJECT_DIR"/**/*.js

# Convert jQuery to vanilla JS
sd '\$\(document\)\.ready\(' 'document.addEventListener("DOMContentLoaded", ' -i "$PROJECT_DIR"/**/*.js

echo "Code modernization complete"
```

### API Migration
```bash
#!/bin/bash
# Migrate API endpoints across codebase

OLD_API_BASE=$1
NEW_API_BASE=$2
PROJECT_DIR=${3:-"."}

echo "Migrating API endpoints..."
echo "From: $OLD_API_BASE"
echo "To: $NEW_API_BASE"

# Update API base URLs
sd "$OLD_API_BASE" "$NEW_API_BASE" -i "$PROJECT_DIR"/**/*.js "$PROJECT_DIR"/**/*.ts

# Update configuration files
sd "api_base_url[\"'\s]*:[\"'\s]*$OLD_API_BASE" "api_base_url: \"$NEW_API_BASE\"" -i "$PROJECT_DIR"/**/*.json "$PROJECT_DIR"/**/*.yaml

# Update environment variables
sd "API_BASE_URL=$OLD_API_BASE" "API_BASE_URL=$NEW_API_BASE" -i "$PROJECT_DIR"/**/.env*

# Update documentation
sd "$OLD_API_BASE" "$NEW_API_BASE" -i "$PROJECT_DIR"/**/*.md "$PROJECT_DIR"/**/*.rst

echo "API migration complete"
```

### Database Schema Updates
```bash
#!/bin/bash
# Update database references in code

OLD_TABLE_NAME=$1
NEW_TABLE_NAME=$2
CODE_DIR=${3:-"src/"}

echo "Updating database table references..."
echo "From: $OLD_TABLE_NAME"
echo "To: $NEW_TABLE_NAME"

# Update SQL queries
sd "FROM\s+$OLD_TABLE_NAME\b" "FROM $NEW_TABLE_NAME" -i "$CODE_DIR"/**/*.sql

# Update model references
sd "table_name\s*=\s*['\"]$OLD_TABLE_NAME['\"]" "table_name = '$NEW_TABLE_NAME'" -i "$CODE_DIR"/**/*.py

# Update ORM configurations
sd "@Table\(name\s*=\s*['\"]$OLD_TABLE_NAME['\"]" "@Table(name = \"$NEW_TABLE_NAME\"" -i "$CODE_DIR"/**/*.java

# Update TypeScript interfaces
sd "interface\s+${OLD_TABLE_NAME^}" "interface ${NEW_TABLE_NAME^}" -i "$CODE_DIR"/**/*.ts

echo "Database schema update complete"
```

## Data Processing and Transformation

### CSV Data Cleaning
```bash
#!/bin/bash
# Clean and standardize CSV data

INPUT_CSV=$1
OUTPUT_CSV="${INPUT_CSV%.csv}_cleaned.csv"

echo "Cleaning CSV data: $INPUT_CSV"

# Copy input to output
cp "$INPUT_CSV" "$OUTPUT_CSV"

# Standardize phone numbers
sd '(\d{3})[\s.-]?(\d{3})[\s.-]?(\d{4})' '$1-$2-$3' -i "$OUTPUT_CSV"

# Standardize state abbreviations
sd '\b(California|CA)\b' 'CA' -i "$OUTPUT_CSV"
sd '\b(New York|NY)\b' 'NY' -i "$OUTPUT_CSV"
sd '\b(Texas|TX)\b' 'TX' -i "$OUTPUT_CSV"

# Clean email addresses (remove spaces)
sd '([a-zA-Z0-9._%+-]+)\s*@\s*([a-zA-Z0-9.-]+\.[a-zA-Z]{2,})' '$1@$2' -i "$OUTPUT_CSV"

# Standardize boolean values
sd '\b(yes|Yes|YES|true|True|TRUE)\b' 'true' -i "$OUTPUT_CSV"
sd '\b(no|No|NO|false|False|FALSE)\b' 'false' -i "$OUTPUT_CSV"

# Remove extra whitespace
sd '\s+' ' ' -i "$OUTPUT_CSV"
sd '^\s+|\s+$' '' -i "$OUTPUT_CSV"

echo "CSV cleaning complete: $OUTPUT_CSV"
```

### Log Format Standardization
```bash
#!/bin/bash
# Standardize log formats across multiple sources

LOG_DIR=$1
STANDARDIZED_DIR="${LOG_DIR}_standardized"

mkdir -p "$STANDARDIZED_DIR"

echo "Standardizing log formats in: $LOG_DIR"

for log_file in "$LOG_DIR"/*.log; do
    if [ -f "$log_file" ]; then
        filename=$(basename "$log_file")
        output_file="$STANDARDIZED_DIR/$filename"
        
        echo "Processing: $filename"
        
        # Copy original
        cp "$log_file" "$output_file"
        
        # Standardize timestamp formats
        # Convert various timestamp formats to ISO 8601
        sd '(\d{2})/(\d{2})/(\d{4})\s+(\d{2}):(\d{2}):(\d{2})' '$3-$1-$2T$4:$5:$6' -i "$output_file"
        sd '(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2}):(\d{2})' '$1-$2-$3T$4:$5:$6' -i "$output_file"
        
        # Standardize log levels
        sd '\[ERROR\]|\[ERR\]|ERROR:' '[ERROR]' -i "$output_file"
        sd '\[WARN\]|\[WARNING\]|WARN:' '[WARN]' -i "$output_file"
        sd '\[INFO\]|INFO:' '[INFO]' -i "$output_file"
        sd '\[DEBUG\]|DEBUG:' '[DEBUG]' -i "$output_file"
        
        # Standardize IP address format
        sd '(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})' '$1.$2.$3.$4' -i "$output_file"
        
        echo "  ✓ Standardized: $filename"
    fi
done

echo "Log standardization complete: $STANDARDIZED_DIR"
```

### JSON Data Transformation
```bash
#!/bin/bash
# Transform JSON data structure

INPUT_JSON=$1
OUTPUT_JSON="${INPUT_JSON%.json}_transformed.json"

echo "Transforming JSON data: $INPUT_JSON"

# Copy input to output
cp "$INPUT_JSON" "$OUTPUT_JSON"

# Update field names
sd '"firstName"' '"first_name"' -i "$OUTPUT_JSON"
sd '"lastName"' '"last_name"' -i "$OUTPUT_JSON"
sd '"phoneNumber"' '"phone_number"' -i "$OUTPUT_JSON"

# Convert string dates to ISO format
sd '"(\d{2})/(\d{2})/(\d{4})"' '"$3-$1-$2"' -i "$OUTPUT_JSON"

# Normalize boolean values
sd '"(yes|Yes|YES)"' 'true' -i "$OUTPUT_JSON"
sd '"(no|No|NO)"' 'false' -i "$OUTPUT_JSON"

# Convert string numbers to numbers
sd '"(\d+)":\s*"(\d+)"' '"$1": $2' -i "$OUTPUT_JSON"

echo "JSON transformation complete: $OUTPUT_JSON"
```

## Integration with Development Workflows

### Git Hook Integration
```bash
#!/bin/bash
# Git pre-commit hook using sd for code formatting

# Check for trailing whitespace and fix
echo "Checking for trailing whitespace..."
git diff --cached --name-only | while read file; do
    if [ -f "$file" ]; then
        sd '\s+$' '' -i "$file"
        git add "$file"
    fi
done

# Standardize line endings
echo "Standardizing line endings..."
git diff --cached --name-only --diff-filter=AM | while read file; do
    if [ -f "$file" ]; then
        sd '\r\n' '\n' -i "$file"
        git add "$file"
    fi
done

# Format JSON files
echo "Formatting JSON files..."
git diff --cached --name-only --diff-filter=AM | grep '\.json$' | while read file; do
    if [ -f "$file" ]; then
        # Remove trailing commas
        sd ',(\s*[}\]])' '$1' -i "$file"
        git add "$file"
    fi
done

echo "Pre-commit formatting complete"
```

### CI/CD Pipeline Integration
```yaml
# GitHub Actions workflow using sd
name: Code Standardization

on:
  pull_request:
    branches: [ main, develop ]

jobs:
  standardize:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install sd
      run: |
        wget https://github.com/chmln/sd/releases/download/v0.7.6/sd-v0.7.6-x86_64-unknown-linux-musl.tar.gz
        tar -xzf sd-v0.7.6-x86_64-unknown-linux-musl.tar.gz
        sudo mv sd-v0.7.6-x86_64-unknown-linux-musl/sd /usr/local/bin/
    
    - name: Standardize Code
      run: |
        # Remove trailing whitespace
        find . -name "*.js" -o -name "*.ts" -o -name "*.py" | xargs sd '\s+$' ''
        
        # Standardize quotes in JavaScript
        find . -name "*.js" | xargs sd "'" '"'
        
        # Update old API endpoints
        find . -name "*.js" -o -name "*.ts" | xargs sd 'api\.old\.com' 'api.new.com'
    
    - name: Check for changes
      run: |
        if git diff --quiet; then
          echo "No standardization changes needed"
        else
          echo "Code standardization changes detected"
          git diff
          exit 1
        fi
```

### Documentation Generation
```bash
#!/bin/bash
# Generate documentation from code comments

SOURCE_DIR=$1
DOCS_DIR="docs/generated"

mkdir -p "$DOCS_DIR"

echo "Generating documentation from source code..."

# Extract function documentation from Python files
find "$SOURCE_DIR" -name "*.py" | while read file; do
    filename=$(basename "$file" .py)
    doc_file="$DOCS_DIR/${filename}_functions.md"
    
    echo "# Functions in $filename" > "$doc_file"
    echo "" >> "$doc_file"
    
    # Extract function definitions and docstrings
    grep -A 10 "^def " "$file" | while read line; do
        if [[ $line =~ ^def ]]; then
            func_name=$(echo "$line" | sd 'def\s+(\w+).*' '$1')
            echo "## $func_name" >> "$doc_file"
            echo '```python' >> "$doc_file"
            echo "$line" >> "$doc_file"
            echo '```' >> "$doc_file"
            echo "" >> "$doc_file"
        fi
    done
done

# Extract API endpoints from route definitions
find "$SOURCE_DIR" -name "*.py" | while read file; do
    if grep -q "@app.route\|@router\." "$file"; then
        filename=$(basename "$file" .py)
        api_doc="$DOCS_DIR/${filename}_api.md"
        
        echo "# API Endpoints in $filename" > "$api_doc"
        echo "" >> "$api_doc"
        
        grep -B 2 -A 5 "@app.route\|@router\." "$file" | while read line; do
            if [[ $line =~ @.*route ]]; then
                route=$(echo "$line" | sd '.*route\(["\']([^"\']+)["\'].*' '$1')
                echo "- \`$route\`" >> "$api_doc"
            fi
        done
    fi
done

echo "Documentation generation complete: $DOCS_DIR"
```

## Performance and Optimization

### Large File Processing
```bash
#!/bin/bash
# Efficient processing of large files

LARGE_FILE=$1
PATTERN=$2
REPLACEMENT=$3
CHUNK_SIZE=${4:-1000000}  # 1MB chunks

echo "Processing large file: $LARGE_FILE"
echo "Pattern: $PATTERN -> $REPLACEMENT"

# Split file into manageable chunks
split -l $CHUNK_SIZE "$LARGE_FILE" "/tmp/chunk_"

# Process chunks in parallel
for chunk in /tmp/chunk_*; do
    {
        echo "Processing chunk: $(basename $chunk)"
        sd "$PATTERN" "$REPLACEMENT" -i "$chunk"
    } &
done

# Wait for all chunks to complete
wait

# Reassemble file
cat /tmp/chunk_* > "${LARGE_FILE}.processed"

# Cleanup
rm -f /tmp/chunk_*

echo "Large file processing complete: ${LARGE_FILE}.processed"
```

### Memory-Efficient Stream Processing
```bash
#!/bin/bash
# Stream processing for continuous data

INPUT_STREAM=$1
OUTPUT_STREAM=$2
PATTERN=$3
REPLACEMENT=$4

echo "Starting stream processing..."
echo "Pattern: $PATTERN -> $REPLACEMENT"

# Process stream line by line to minimize memory usage
while IFS= read -r line; do
    # Apply transformation
    transformed_line=$(echo "$line" | sd "$PATTERN" "$REPLACEMENT")
    
    # Output to stream
    echo "$transformed_line" >> "$OUTPUT_STREAM"
    
done < "$INPUT_STREAM"

echo "Stream processing complete"
```

## Use Cases

### Text Processing and Data Cleaning
- Configuration file updates and standardization
- Log file processing and anonymization
- CSV data cleaning and normalization
- JSON/XML data transformation

### Development and Code Maintenance
- Code refactoring and modernization
- API endpoint migration
- Database schema updates
- Documentation generation

### System Administration
- Configuration management across servers
- Log analysis and standardization
- Batch file processing and automation
- Data migration and transformation

### Content Management
- Website content updates
- Markdown processing and conversion
- Template processing and generation
- Multi-language content management

## Installation
Modern stream editor with intuitive syntax and Unicode support.
Essential tool for text processing, data cleaning, and development workflows.

## Dependencies
- None (static binary)
- Cross-platform compatibility
- Unicode and multi-byte character support
- Regular expression engine

## Performance Features
- Efficient memory usage for large files
- Fast regex engine with Unicode support
- Stream processing capabilities
- Parallel processing support for batch operations

---
*Part of PORTX Portable Development Environment*