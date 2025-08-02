# Ripgrep Package Manual

## Package Information
- **Package Name**: ripgrep
- **Category**: Text Processing  
- **Type**: Search Tool
- **License**: MIT/Unlicense

## Description
Ultra-fast text search tool that recursively searches directories for regex patterns.

Modern replacement for grep with better performance, Unicode support, and smart filtering.
Designed for code search with automatic exclusion of binary files, hidden files, and common ignore patterns.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| rg.exe | Recursive regex search tool | Fast text and code search |

## Common Usage Examples

### Basic Search
```bash
# Search for pattern in current directory
rg "function"

# Search in specific file
rg "pattern" file.txt

# Search in specific directory
rg "pattern" /path/to/search

# Case-insensitive search
rg -i "pattern"
```

### Advanced Patterns
```bash
# Regex search
rg "\b\w+@\w+\.\w+\b"

# Word boundaries
rg "\bfunction\b"

# Multiline search
rg -U "start.*end"

# Search for exact string (no regex)
rg -F "literal.string"
```

### File Type Filtering
```bash
# Search only JavaScript files
rg "pattern" -t js

# Search only Python files
rg "pattern" -t py

# Exclude specific file types
rg "pattern" -T js

# Search specific file extensions
rg "pattern" -g "*.md"
```

### Output Control
```bash
# Show line numbers
rg -n "pattern"

# Show context (3 lines before/after)
rg -C 3 "pattern"

# Show only matching text
rg -o "pattern"

# Count matches
rg -c "pattern"

# List files with matches
rg -l "pattern"
```

### Code Search Features
```bash
# Search function definitions
rg "^func\s+\w+"

# Search imports/includes
rg "^import|^#include"

# Search TODO comments
rg -i "todo|fixme|hack"

# Search for unused variables
rg "var\s+\w+.*unused"
```

### Replace Operations
```bash
# Replace text (dry run)
rg "old_pattern" -r "new_text"

# Replace in files
rg "old_pattern" -r "new_text" --passthru

# Replace with regex groups
rg "(\w+)_old" -r "${1}_new"
```

### Integration with Other Tools
```bash
# Pipe to other commands
rg "error" --json | jq '.data.lines.text'

# Use with xargs
rg -l "pattern" | xargs sed -i 's/old/new/g'

# Count total lines
rg "pattern" -c | awk '{sum += $1} END {print sum}'
```

### Performance Features
```bash
# Parallel search (default)
rg "pattern" -j 4

# Search compressed files
rg "pattern" -z

# Include hidden files
rg "pattern" --hidden

# Include ignored files
rg "pattern" --no-ignore
```

### Ignore Patterns
```bash
# Respect .gitignore
rg "pattern"  # default behavior

# Use custom ignore file
rg "pattern" --ignore-file custom.ignore

# Search all files (ignore all ignore files)
rg "pattern" --no-ignore --hidden
```

## Configuration
Ripgrep respects these ignore files automatically:
- `.gitignore`
- `.ignore`
- `.rgignore`
- Global ignore files

## Installation
Ultra-fast search tool optimized for code and text searching.
Significantly faster than traditional grep with better defaults for development workflows.

## Dependencies
None - standalone executable with all features built-in.

## Performance Benefits
- Written in Rust for maximum performance
- Parallel searching across multiple threads
- Smart binary file detection and skipping
- Automatic ignore file processing
- Unicode support with excellent performance

---
*Part of PORTX Portable Development Environment*