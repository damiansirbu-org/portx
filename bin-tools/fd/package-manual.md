# fd Package Manual

## Package Information
- **Package Name**: fd
- **Category**: File Operations
- **Type**: File Search Tool
- **License**: MIT/Apache 2.0

## Description
Simple, fast and user-friendly alternative to find.

Modern file search tool with intuitive syntax, fast performance, and sensible defaults.
Features regex support, parallel execution, and automatic gitignore integration.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| fd.exe | Fast and user-friendly file search | Find files and directories with modern syntax |

## Common Usage Examples

### Basic File Search
```bash
# Find files by name
fd filename

# Find with pattern matching
fd "*.js"
fd "test.*"

# Case-insensitive search
fd -i filename
fd -i "README"
```

### Directory Search
```bash
# Search for directories only
fd -t d dirname

# Search for files only
fd -t f filename

# Search for symbolic links
fd -t l linkname

# Search for executables
fd -t x execname
```

### Advanced Patterns
```bash
# Regex search
fd "^test.*\.py$"

# Search with full path matching
fd --full-path "src/.*\.js"

# Exclude patterns
fd --exclude "*.tmp" filename
fd -E "node_modules" "*.js"
```

### Search Scope
```bash
# Search in specific directory
fd filename /path/to/search

# Control search depth
fd --max-depth 3 filename
fd -d 2 "*.js"

# Include hidden files
fd -H filename

# Include ignored files
fd -I filename
```

### File Type Filtering
```bash
# Search only source code files
fd --extension js
fd -e py

# Multiple extensions
fd -e js -e ts -e jsx

# Search by file size
fd --size +100k filename
fd --size -10m "*.log"
```

### Output Formatting
```bash
# Print full path
fd -a filename

# Print relative path
fd filename

# Print with null separator
fd -0 filename

# Show search stats
fd --stats filename
```

### Integration with Other Tools
```bash
# Execute command on results
fd "*.txt" -x cat {}

# Execute with multiple placeholders
fd "*.js" -x grep -l "function" {}

# Pipe to other commands
fd "*.py" | xargs wc -l

# Use with find syntax
fd filename --exec rm {}
```

### Git Integration
```bash
# Respect .gitignore (default behavior)
fd filename

# Include gitignored files
fd -I filename

# Search only git-tracked files
fd filename --type f | grep -v ".git"

# Exclude git directories
fd --exclude ".git" filename
```

### Performance Optimization
```bash
# Parallel search (default)
fd -j 4 filename

# Single-threaded search
fd -j 1 filename

# Search with follow symlinks
fd -L filename

# Strip prefixes for cleaner output
fd --strip-cwd-prefix filename
```

### Real-world Examples
```bash
# Find all TypeScript files
fd -e ts -e tsx

# Find test files
fd "test|spec" -e js -e py

# Find configuration files
fd "config|\.conf|\.cfg"

# Find large log files
fd --size +50m "*.log"

# Clean up build artifacts
fd "build|dist|node_modules" -t d -x rm -rf {}

# Find recently modified files
fd -t f --changed-within 1d

# Find old files for cleanup
fd -t f --changed-before 30d "*.tmp"
```

### Ignore Patterns
```bash
# Use custom ignore file
fd --ignore-file custom.ignore filename

# Global ignore patterns
fd --global-ignore-file ~/.fdignore filename

# Respect .ignore files
fd filename  # Automatic with .ignore, .gitignore, .fdignore
```

## Default Behavior
- Respects `.gitignore`, `.ignore`, and `.fdignore` files
- Excludes hidden files and directories (unless `-H`)
- Case-sensitive search (unless `-i`)
- Parallel execution for performance
- Colored output when terminal supports it

## Installation
Fast and intuitive file search tool with modern defaults.
Designed as a user-friendly replacement for the traditional find command.

## Dependencies
None - standalone executable with built-in pattern matching and parallel search capabilities.

## Performance Features
- Written in Rust for maximum performance
- Parallel directory traversal
- Optimized regex engine
- Smart ignore file processing
- Memory-efficient large directory handling

---
*Part of PORTX Portable Development Environment*