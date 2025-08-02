# ag (The Silver Searcher) Package Manual

## Package Information
- **Package Name**: ag
- **Category**: Text Processing
- **Type**: Code Search Tool
- **License**: Apache 2.0

## Description
The Silver Searcher is a code-searching tool similar to ack, but faster.

Fast text search optimized for searching source code with intelligent defaults.
Automatically ignores files from .gitignore and applies sensible filtering for development workflows.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| ag.exe | Fast text and code search tool | Search text patterns in codebases with smart filtering |

## Common Usage Examples

### Basic Search
```bash
# Search for pattern in current directory
ag "function"

# Case-insensitive search
ag -i "pattern"

# Search specific file types
ag "pattern" --js
ag "pattern" --python

# Search in specific directory
ag "pattern" /path/to/search
```

### Advanced Patterns
```bash
# Regex search
ag "\b\w+@\w+\.\w+\b"

# Literal string search (no regex)
ag -Q "literal.string"

# Word boundaries
ag -w "function"

# Multiline search
ag -s "start.*end"
```

### File Filtering
```bash
# Search only specific extensions
ag "pattern" --include="*.js"

# Exclude specific files
ag "pattern" --ignore="*.min.js"

# Include hidden files
ag "pattern" --hidden

# Search all files (ignore .gitignore)
ag "pattern" --all-files
```

### Output Control
```bash
# Show line numbers
ag -n "pattern"

# Show context
ag -C 3 "pattern"

# Count matches
ag -c "pattern"

# List files with matches
ag -l "pattern"

# Show only matching text
ag -o "pattern"
```

### Code-Specific Features
```bash
# Search function definitions
ag "^function\s+\w+"

# Search imports
ag "^import|^require"

# Search TODO comments
ag -i "todo|fixme|hack"

# Group by file type
ag "pattern" --group
```

## Installation
Fast code search tool optimized for development workflows.
Faster than traditional grep with intelligent file filtering and source code awareness.

## Dependencies
None - standalone executable with smart defaults for code search.

## Performance Features
- Parallel search execution
- Intelligent file type detection
- Automatic binary file skipping
- Respect for .gitignore and .agignore files
- Memory-mapped file reading

---
*Part of PORTX Portable Development Environment*