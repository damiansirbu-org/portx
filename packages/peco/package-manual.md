# Peco Package Manual

## Package Information
- **Package Name**: peco
- **Category**: Text Processing
- **Type**: Interactive Filtering
- **License**: MIT

## Description
Simplistic interactive filtering tool for command-line data processing.

Interactive filtering tool that allows real-time filtering and selection from input streams.
Designed for simple and efficient text processing with minimal configuration.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| peco.exe | Interactive filtering tool | Filter and select from command output or files |

## Common Usage Examples

### Basic Filtering
```bash
# Filter command history
history | peco

# Filter files in directory
ls -la | peco

# Filter process list
ps aux | peco

# Filter from file
cat file.txt | peco
```

### Command Integration
```bash
# Change directory interactively
cd $(find . -type d | peco)

# Edit file interactively
vim $(find . -name "*.txt" | peco)

# Kill process interactively
kill $(ps aux | peco | awk '{print $2}')

# Git branch switching
git checkout $(git branch | peco | sed 's/^[ *]*//')
```

### Shell Integration
```bash
# Bash function for directory navigation
function pcd() {
    cd $(find ${1:-.} -type d | peco)
}

# File editing function
function pe() {
    $EDITOR $(find ${1:-.} -type f | peco)
}

# History search function
function ph() {
    $(history | peco | sed 's/^[ ]*[0-9]*[ ]*//')
}
```

## Configuration

### Basic Configuration (~/.peco/config.json)
```json
{
    "Keymap": {
        "C-j": "peco.SelectDown",
        "C-k": "peco.SelectUp",
        "C-f": "peco.ScrollPageDown",
        "C-b": "peco.ScrollPageUp"
    },
    "Style": {
        "Basic": ["on_default", "default"],
        "SavedSelection": ["bold", "on_yellow", "black"],
        "Selected": ["underline", "on_cyan", "black"],
        "Query": ["yellow", "bold"],
        "Matched": ["red", "on_blue"]
    },
    "Prompt": "QUERY>",
    "InitialMatcher": "IgnoreCase"
}
```

### Key Bindings
```json
{
    "Keymap": {
        "C-p": "peco.SelectUp",
        "C-n": "peco.SelectDown",
        "C-u": "peco.ScrollPageUp",
        "C-d": "peco.ScrollPageDown",
        "C-g": "peco.Cancel",
        "Enter": "peco.Finish",
        "Escape": "peco.Cancel",
        "C-c": "peco.Cancel"
    }
}
```

### Custom Styles
```json
{
    "Style": {
        "Basic": ["default"],
        "SavedSelection": ["bold", "yellow"],
        "Selected": ["bold", "cyan"],
        "Query": ["bold", "green"],
        "Matched": ["bold", "red"]
    }
}
```

## Advanced Usage

### Multi-Selection Mode
```bash
# Enable multi-selection with --select-1 option
ls -la | peco --select-1

# Use with xargs for multiple operations
find . -name "*.log" | peco | xargs rm
```

### Custom Matchers
```bash
# Case-sensitive matching
echo -e "Apple\napple\nAPPLE" | peco --initial-matcher CaseSensitive

# Regular expression matching
ps aux | peco --initial-matcher Regexp

# Smart case matching
cat wordlist.txt | peco --initial-matcher SmartCase
```

### Output Control
```bash
# Null terminator for safe file handling
find . -type f -print0 | peco --null

# Custom prompt
ls | peco --prompt "Select file: "

# Initial query
git branch | peco --query "feature/"
```

## Integration Examples

### Git Workflow Enhancement
```bash
# Interactive git log
function glog() {
    git log --oneline | peco | awk '{print $1}' | xargs git show
}

# Interactive git diff
function gdiff() {
    git status --porcelain | peco | awk '{print $2}' | xargs git diff
}

# Interactive git add
function gadd() {
    git status --porcelain | peco | awk '{print $2}' | xargs git add
}
```

### Docker Management
```bash
# Interactive container selection
function dexec() {
    local container=$(docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" | peco | awk '{print $1}')
    if [ -n "$container" ]; then
        docker exec -it $container /bin/bash
    fi
}

# Interactive container logs
function dlogs() {
    local container=$(docker ps --format "table {{.Names}}\t{{.Image}}" | peco | awk '{print $1}')
    if [ -n "$container" ]; then
        docker logs -f $container
    fi
}
```

### SSH Connection Manager
```bash
# SSH host selection from config
function pssh() {
    local host=$(grep "^Host " ~/.ssh/config | awk '{print $2}' | peco)
    if [ -n "$host" ]; then
        ssh $host
    fi
}

# SSH with custom hosts list
function pssh2() {
    local host=$(echo -e "server1\nserver2\nserver3" | peco)
    if [ -n "$host" ]; then
        ssh user@$host
    fi
}
```

### Log File Analysis
```bash
# Interactive log viewer
function plogs() {
    local logfile=$(find /var/log -name "*.log" 2>/dev/null | peco)
    if [ -n "$logfile" ]; then
        tail -f "$logfile"
    fi
}

# Error pattern search
function perror() {
    grep -r "ERROR\|FAIL\|CRITICAL" /var/log/ | peco
}
```

## Command-Line Options

### Basic Options
```bash
# Specify initial filter
peco --initial-filter "error"

# Set buffer size
peco --buffer-size 1000

# Enable debugging
peco --debug

# Show version
peco --version
```

### Matcher Options
```bash
# Available matchers
peco --initial-matcher IgnoreCase    # Default
peco --initial-matcher CaseSensitive
peco --initial-matcher SmartCase
peco --initial-matcher Regexp
peco --initial-matcher Fuzzy
```

### Display Options
```bash
# Custom layout
peco --layout bottom-up
peco --layout top-down

# No color output
peco --no-color

# Reverse output order
peco --reverse
```

## Scripting and Automation

### Batch Processing
```bash
# Process multiple selections
function batch_edit() {
    find . -name "*.txt" | peco | while read file; do
        echo "Processing: $file"
        # Perform operations on $file
    done
}
```

### Error Handling
```bash
# Safe peco usage with error checking
function safe_peco() {
    local selection=$(echo "$1" | peco)
    if [ $? -eq 0 ] && [ -n "$selection" ]; then
        echo "$selection"
        return 0
    else
        echo "No selection made" >&2
        return 1
    fi
}
```

### Complex Workflows
```bash
# Multi-step selection process
function complex_workflow() {
    # Step 1: Select project
    local project=$(ls ~/projects | peco --prompt "Select project: ")
    [ -z "$project" ] && return 1
    
    # Step 2: Select file in project
    local file=$(find ~/projects/$project -name "*.py" | peco --prompt "Select file: ")
    [ -z "$file" ] && return 1
    
    # Step 3: Edit selected file
    $EDITOR "$file"
}
```

## Performance Considerations

### Large Data Sets
```bash
# Optimize for large inputs
cat large_file.txt | peco --buffer-size 10000

# Use with head for initial filtering
find / -name "*.log" 2>/dev/null | head -1000 | peco
```

### Memory Management
```bash
# Stream processing for large outputs
ps aux | head -100 | peco

# Limit initial results
ls -la | head -50 | peco
```

## Comparison with Similar Tools

### vs fzf
- Peco: Simpler, more straightforward
- fzf: More features, faster for large datasets

### vs percol
- Peco: Go-based, single binary
- percol: Python-based, more customizable

### Use Cases for Peco
- Simple filtering tasks
- Basic interactive selection
- Lightweight command-line enhancement
- Learning interactive filtering concepts

## Troubleshooting

### Common Issues
```bash
# UTF-8 encoding issues
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Terminal compatibility
export TERM=xterm-256color

# Config file location
echo $HOME/.peco/config.json
```

### Debug Mode
```bash
# Enable debug output
peco --debug 2>debug.log

# Check configuration
peco --version
cat ~/.peco/config.json
```

## Use Cases

### Development Workflows
- Interactive file selection
- Git command enhancement
- Process management
- Log file analysis

### System Administration
- Service management
- Configuration file editing
- Package selection
- Network troubleshooting

### Data Processing
- CSV file filtering
- Log analysis
- Text processing pipelines
- Command output filtering

### Daily Productivity
- Command history searching
- Directory navigation
- File management
- Quick reference lookup

## Installation
Simplistic interactive filtering tool for command-line productivity.
Essential for basic interactive selection and filtering workflows.

## Dependencies
None - standalone executable with minimal system requirements.

## Performance Features
- Fast startup time
- Low memory usage
- Efficient text processing
- Responsive interface
- Simple configuration

---
*Part of PORTX Portable Development Environment*