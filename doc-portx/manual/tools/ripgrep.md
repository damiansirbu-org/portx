# ripgrep (rg) - v13.0.0
**Ultra-fast text search that recursively searches directories for regex patterns**

[🏠 Back to Wiki Home](../index.md) | [🔧 Modern Unix Tools](../categories/modern-unix.md)

---

## 🚀 Overview

ripgrep is a line-oriented search tool that recursively searches the current directory for a regex pattern. By default, ripgrep will respect gitignore rules and automatically skip hidden files/directories and binary files.

- **Version**: 13.0.0
- **Category**: Modern Unix Tools / Search
- **Location**: `bin-ext/ripgrep/rg.exe`
- **Performance**: 2-10x faster than grep, ag, or ack
- **Repository**: https://github.com/BurntSushi/ripgrep

---

## ⚡ Quick Start

### Basic Usage
```bash
# Search for pattern in current directory
rg "pattern"

# Case-insensitive search
rg -i "pattern"

# Search specific file types
rg "pattern" --type js

# Search with line numbers
rg -n "pattern"
```

### Performance Test
```bash
# Search entire codebase
time rg "function"
# Typically completes in milliseconds on large codebases
```

---

## 🔧 Essential Commands

### Basic Search
```bash
# Simple text search
rg "TODO"

# Regex search
rg "fn \w+\("

# Word boundaries
rg -w "test"

# Case insensitive
rg -i "error"
```

### File Type Filtering
```bash
# Search JavaScript files
rg "pattern" --type js

# Search multiple types
rg "pattern" -t py -t rs

# List available types
rg --type-list

# Custom file extension
rg "pattern" -g "*.config"
```

### Output Control
```bash
# Show line numbers
rg -n "pattern"

# Show file names only
rg -l "pattern"

# Show context lines
rg -C 3 "pattern"        # 3 lines before and after
rg -B 2 -A 1 "pattern"   # 2 before, 1 after

# Count matches
rg -c "pattern"
```

---

## 🎯 Advanced Features

### Replacement (Preview)
```bash
# Show what would be replaced
rg "old_pattern" --replace "new_pattern"

# Actually replace (use with caution)
rg "old_pattern" --replace "new_pattern" --passthru > new_file.txt
```

### Multi-line Search
```bash
# Search across multiple lines
rg -U "pattern.*\n.*another" 

# Search for function definitions spanning lines
rg -U "function \w+\([^)]*\)\s*\{"
```

### Statistical Output
```bash
# Show search statistics
rg "pattern" --stats

# JSON output for scripting
rg "pattern" --json | jq '.data.lines.text'
```

### Glob Patterns
```bash
# Include specific files
rg "pattern" -g "*.{js,ts,jsx,tsx}"

# Exclude directories
rg "pattern" -g "!node_modules"

# Complex globbing
rg "pattern" -g "src/**/*.py" -g "!**/test_*.py"
```

---

## 🚀 Practical Examples

### Code Search Workflows
```bash
# Find all TODO comments
rg "TODO|FIXME|HACK|XXX" --type-not md

# Find function definitions
rg "^(function|def|fn)\s+\w+" --type js --type py --type rs

# Find imports/includes
rg "^(import|from|#include|use)\s+" --type js --type py --type cpp --type rs

# Find console/print statements
rg "(console\.|print\(|println!|debugger)" --type js --type py --type rs
```

### Configuration and Logs
```bash
# Search log files with context
rg "ERROR" --type log -C 5

# Find configuration values
rg "database.*password" --type yaml --type json --type conf

# Search for IPs and URLs
rg "\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b" --type log
rg "https?://[^\s]+" --type md --type txt
```

### Git Integration
```bash
# Search only tracked files
rg "pattern" --no-ignore-vcs

# Include ignored files
rg "pattern" --no-ignore

# Search git history (combine with git)
git log -p | rg "pattern" -C 3
```

---

## ⚙️ Configuration

### Configuration File
Create `~/.ripgreprc` for default options:
```bash
# Always show line numbers
--line-number

# Always show 2 lines of context
--context=2

# Don't search binary files
--binary

# Add custom type for config files
--type-add=config:*.{conf,config,ini,yaml,yml,toml}
```

### Environment Variable
```bash
export RIPGREP_CONFIG_PATH=~/.ripgreprc
```

### Shell Aliases
```bash
# Add to ~/.bashrc
alias rgi='rg -i'                    # Case insensitive
alias rgf='rg --files | rg'         # Search filenames
alias rgl='rg -l'                    # List files only
alias rgc='rg -C 5'                  # Always show context
```

---

## 📊 Performance Comparison

| Tool | Large Codebase | Single File | Memory Usage |
|------|---------------|-------------|--------------|
| **ripgrep** | 0.2s ⭐ | 0.01s ⭐ | Low ⭐ |
| ag (Silver Searcher) | 0.8s | 0.03s | Medium |
| ack | 2.1s | 0.1s | Medium |
| grep -r | 3.5s | 0.02s | Low |

### Why ripgrep is faster:
1. **Rust implementation** - Memory safety with zero-cost abstractions
2. **Parallel processing** - Multi-threaded directory traversal
3. **Smart filtering** - Respects .gitignore, skips binary files
4. **Optimized regex** - Uses RE2-style engine for consistent performance

---

## 🛠️ Integration Examples

### With fzf (Fuzzy Finder)
```bash
# Interactive file search with preview
rg --files | fzf --preview 'rg --color=always -C 3 {q} {}'

# Search content interactively
rg --line-number . | fzf --preview 'echo {} | cut -d: -f1 | xargs bat --color=always'
```

### With bat (Syntax Highlighter)
```bash
# Function to search and display with syntax highlighting
rgsearch() {
    local file=$(rg -l "$1" | fzf)
    [[ -n $file ]] && bat "$file"
}
```

### With Git Hooks
```bash
#!/bin/bash
# Pre-commit hook to check for sensitive data
if rg -q "password|secret|api_key" --type js --type py; then
    echo "Error: Potential sensitive data found!"
    rg "password|secret|api_key" --type js --type py -n
    exit 1
fi
```

---

## 💡 Pro Tips

1. **Use file types**: `--type` is much faster than glob patterns
2. **Combine with other tools**: `rg pattern | cut -d: -f1 | sort -u`
3. **Smart case**: ripgrep automatically becomes case-insensitive if pattern is all lowercase
4. **Hidden files**: Use `--hidden` to search hidden files and directories
5. **Binary files**: Use `--text` to search binary files (usually not needed)
6. **Memory usage**: ripgrep uses memory efficiently even on large codebases
7. **Regex engine**: Uses Rust's regex crate, which is fast and safe

---

## 🔧 Common Use Cases

### Development
```bash
# Find all console.log statements
rg "console\.log" --type js

# Find hardcoded URLs
rg "https?://(?!localhost)" --type js --type py

# Find deprecated functions
rg "@deprecated|DEPRECATED" --type java --type js
```

### System Administration
```bash
# Search log files for errors
rg "ERROR|FATAL" /var/log/ -C 2

# Find configuration references
rg "ServerName|Listen" /etc/apache2/ --type conf

# Search for specific user activity
rg "user_123" --type log --type audit
```

### Documentation
```bash
# Find broken links in markdown
rg "\[.*\]\(http" --type md | rg "404|broken"

# Find TODO items in documentation
rg "TODO|FIXME" --type md --type rst
```

---

## 🔗 Related Tools

- **[ag](ag.md)** - The Silver Searcher (alternative text search)
- **[fzf](fzf.md)** - Fuzzy finder (great with ripgrep)
- **[bat](bat.md)** - Syntax highlighter for viewing results
- **[grep](grep.md)** - Traditional Unix text search

---

## 📚 Additional Resources

- [ripgrep User Guide](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)
- [Regex Syntax Guide](https://docs.rs/regex/latest/regex/#syntax)
- [Performance Benchmarks](https://blog.burntsushi.net/ripgrep/)

---

*Use `portx tool ripgrep` to view this page | `portx search ripgrep` to find related tools*

**[⬆️ Back to Top](#ripgrep-rg---v1300)** | **[🏠 Wiki Home](../index.md)**