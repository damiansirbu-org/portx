# fzf Package Manual

## Package Information
- **Package Name**: fzf
- **Category**: Text Processing
- **Type**: Fuzzy Finder
- **License**: MIT

## Description
Command-line fuzzy finder for interactive filtering and selection.

General-purpose fuzzy finder that can be used with any list for interactive searching and selection.
Essential tool for improving command-line productivity and workflow automation.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| fzf.exe | Interactive fuzzy finder | Filter and select from lists interactively |

## Common Usage Examples

### Basic Fuzzy Finding
```bash
# Find files in current directory
find . -type f | fzf

# Search command history
history | fzf

# Select from simple list
echo -e "option1\noption2\noption3" | fzf
```

### File Operations
```bash
# Open file in editor
vim "$(find . -type f | fzf)"

# Change directory interactively
cd "$(find . -type d | fzf)"

# Copy file
cp "$(find . -name "*.txt" | fzf)" /destination/

# Delete file (with confirmation)
rm "$(find . -type f | fzf)"
```

### Git Integration
```bash
# Checkout branch
git checkout "$(git branch | fzf | sed 's/^[ *]*//')"

# Show commit
git show "$(git log --oneline | fzf | cut -d' ' -f1)"

# Add files to staging
git add "$(git ls-files -m | fzf)"

# View git log interactively
git log --oneline | fzf --preview 'git show {1}'
```

### Process Management
```bash
# Kill process
ps aux | fzf | awk '{print $2}' | xargs kill

# Monitor specific process
ps aux | fzf --header-lines=1

# Select and describe process
ps aux | fzf --preview 'echo {}' --preview-window down:3:wrap
```

### Directory Navigation
```bash
# Quick directory jumper
function cdf() {
    cd "$(find . -type d | fzf)"
}

# Recent directories (with history)
dirs -v | fzf | cut -f2 | xargs cd

# Bookmark system
function mark() {
    pwd >> ~/.bookmarks
}
function jump() {
    cd "$(cat ~/.bookmarks | fzf)"
}
```

### Advanced Filtering
```bash
# Multi-select mode
find . -type f | fzf --multi

# Custom preview window
find . -name "*.txt" | fzf --preview 'cat {}'

# Preview with syntax highlighting
find . -name "*.py" | fzf --preview 'bat --color=always {}'

# Custom header and prompt
ls | fzf --header="Select file" --prompt="File> "
```

### Shell Integration
```bash
# Bash key bindings (add to ~/.bashrc)
# Ctrl+R for command history
bind '"\C-r": " \C-e\C-u$(history | fzf --tac | sed \"s/ *[0-9]* *//\")\e\C-e\er"'

# Ctrl+T for file finder
bind '"\C-t": " \C-e\C-u$(find . -type f | fzf)\e\C-e\er"'

# Alt+C for directory change
bind '"\ec": " \C-e\C-u$(find . -type d | fzf)\e\C-e\er && cd"'
```

### Custom Functions
```bash
# Fuzzy grep
function fgrep() {
    grep -r "$1" . | fzf
}

# Fuzzy package search
function fpkg() {
    winget search "$1" | fzf
}

# Fuzzy environment variables
function fenv() {
    env | fzf
}

# Fuzzy port finder
function fport() {
    netstat -an | fzf
}
```

### File Content Search
```bash
# Search within files
grep -r "pattern" . | fzf --preview 'echo {}'

# Ripgrep integration
rg --line-number . | fzf --delimiter : --preview 'bat --color=always --highlight-line {2} {1}'

# Ag integration
ag . | fzf --preview 'echo {}'
```

### Docker Integration
```bash
# Select Docker container
docker ps | fzf --header-lines=1

# Execute command in container
docker exec -it "$(docker ps | fzf | awk '{print $1}')" bash

# Remove container
docker rm "$(docker ps -a | fzf | awk '{print $1}')"

# View container logs
docker logs "$(docker ps | fzf | awk '{print $1}')"
```

### Custom Preview Commands
```bash
# File preview with file info
find . -type f | fzf --preview 'file {} && echo "---" && head -20 {}'

# Directory preview
find . -type d | fzf --preview 'ls -la {}'

# Image preview (if available)
find . -name "*.png" | fzf --preview 'echo "Image: {}"'
```

### Configuration Options
```bash
# Set default options
export FZF_DEFAULT_OPTS="--height 40% --border --reverse"

# Custom command for file finding
export FZF_DEFAULT_COMMAND="find . -type f -not -path '*/\.git/*'"

# Colors and appearance
export FZF_DEFAULT_OPTS="--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc"
```

## Key Bindings (Interactive Mode)

### Navigation
- **Ctrl+J/K**: Move down/up
- **Ctrl+N/P**: Move down/up
- **Page Up/Down**: Page navigation
- **Home/End**: First/last item

### Selection
- **Enter**: Select item
- **Tab**: Mark multiple items (multi-select mode)
- **Shift+Tab**: Unmark item
- **Ctrl+A**: Select all
- **Ctrl+D**: Deselect all

### Search
- **Ctrl+U**: Clear query
- **Ctrl+W**: Delete word
- **Ctrl+A/E**: Beginning/end of line
- **Alt+B/F**: Word navigation

### Other
- **Ctrl+C/Esc**: Exit
- **Ctrl+R**: Toggle sort order
- **Ctrl+T**: Toggle preview

## Installation
Interactive fuzzy finder for command-line productivity.
Essential tool for file selection, command history, and workflow automation.

## Dependencies
None - standalone executable with built-in fuzzy matching algorithm.

## Performance Features
- Fast fuzzy matching algorithm
- Real-time filtering as you type
- Memory-efficient for large lists
- Minimal system resource usage
- Highly responsive interface

---
*Part of PORTX Portable Development Environment*