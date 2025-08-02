# Glow Package Manual

## Package Information
- **Package Name**: glow
- **Category**: Text Processing
- **Type**: Markdown Viewer
- **License**: MIT

## Description
Render markdown on the CLI with pizzazz.

Terminal-based markdown viewer with beautiful rendering, syntax highlighting, and interactive navigation.
Perfect for reading documentation, README files, and markdown content without leaving the terminal.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| glow.exe | Terminal markdown renderer | View and navigate markdown files with style |

## Common Usage Examples

### Basic Markdown Viewing
```bash
# View markdown file
glow README.md

# View from stdin
cat README.md | glow

# View with specific style
glow --style dark README.md
glow --style light README.md
```

### Interactive Mode
```bash
# Launch interactive file browser
glow

# Browse current directory for markdown
glow .

# Browse specific directory
glow docs/

# View with pager
glow --pager README.md
```

### Output Control
```bash
# Print to stdout (no pager)
glow --print README.md

# Specific width
glow --width 80 README.md

# Word wrap control
glow --wrap=80 README.md

# No word wrap
glow --wrap=0 README.md
```

### Style and Appearance
```bash
# Available styles
glow --style auto README.md      # Auto-detect terminal
glow --style dark README.md      # Dark theme
glow --style light README.md     # Light theme
glow --style notty README.md     # No TTY colors

# Custom style
glow --style ~/.config/glow/custom.json README.md
```

### Multiple Files
```bash
# View multiple files
glow file1.md file2.md file3.md

# View all markdown in directory
glow *.md

# Recursive markdown viewing
find . -name "*.md" -exec glow {} \;
```

### Network Sources
```bash
# View markdown from URL
glow https://raw.githubusercontent.com/user/repo/main/README.md

# GitHub repository README
glow github.com/microsoft/vscode

# GitLab repository
glow gitlab.com/user/project
```

### Configuration Options
```bash
# Show line numbers
glow --show-line-numbers README.md

# Local file links only
glow --local README.md

# All link types
glow --all README.md

# Mouse support
glow --mouse README.md
```

## Interactive Mode Features

### Navigation
- **j/k**: Scroll down/up
- **d/u**: Page down/up
- **g/G**: Go to beginning/end
- **Arrow keys**: Navigate
- **Enter**: Open selected file
- **Esc/q**: Quit

### File Browser
- **Enter**: Open markdown file
- **Backspace**: Go up directory
- **Tab**: Autocomplete
- **/**: Search files
- **?**: Show help

### Document Navigation
- **Space**: Page down
- **b**: Page up
- **h**: Show help
- **r**: Refresh
- **m**: Toggle mouse

## Integration Examples

### Git Workflows
```bash
# View commit messages
git log --oneline | head -10 | while read commit; do
    echo "## Commit: $commit"
    git show --format="" --name-only $commit
done | glow

# View pull request template
glow .github/pull_request_template.md

# Documentation review
glow docs/**/*.md
```

### Documentation Browsing
```bash
# Project documentation
glow docs/

# API documentation
glow api-docs/*.md

# Changelog viewing
glow CHANGELOG.md

# License review
glow LICENSE.md
```

### Development Workflow
```bash
# Quick README check
glow README.md

# View contributing guidelines
glow CONTRIBUTING.md

# Check installation instructions
glow docs/installation.md

# Review API reference
glow docs/api/*.md
```

### Content Creation
```bash
# Preview while writing
echo "# My Document" | glow
glow draft.md

# Style testing
glow --style dark content.md
glow --style light content.md

# Width testing
glow --width 60 content.md
glow --width 120 content.md
```

## Advanced Features

### Custom Styling
```json
// ~/.config/glow/styles/custom.json
{
  "document": {
    "color": "#ffffff"
  },
  "heading": {
    "color": "#00ff00",
    "bold": true
  },
  "code": {
    "color": "#ff0000",
    "background_color": "#333333"
  }
}
```

### Environment Variables
```bash
# Default style
export GLOW_STYLE=dark

# Default pager
export GLOW_PAGER=less

# Default width
export GLOW_WIDTH=100
```

### Configuration File
```yaml
# ~/.config/glow/glow.yml
style: "dark"
width: 80
show_all_files: false
local: false
mouse: true
pager: true
```

## Use Cases

### Documentation Reading
```bash
# Technical documentation
glow docs/technical-guide.md

# User manuals
glow manuals/*.md

# API references
glow api-docs/
```

### Content Review
```bash
# Blog post preview
glow blog-posts/new-post.md

# Article editing
glow --width 70 article.md

# Documentation updates
glow updated-docs.md
```

### Educational Material
```bash
# Tutorial viewing
glow tutorials/

# Course material
glow course/lesson-*.md

# Reference guides
glow reference/
```

## Supported Markdown Features
- Headers and subheaders with styling
- **Bold** and *italic* text formatting
- `Inline code` and code blocks with syntax highlighting
- Lists (ordered and unordered)
- Links and link highlighting
- Images (with placeholder text)
- Tables with alignment
- Blockquotes with visual styling
- Horizontal rules
- Strikethrough text

## Installation
Beautiful terminal markdown renderer with syntax highlighting.
Essential tool for reading documentation and markdown content in terminal workflows.

## Dependencies
None - standalone executable with built-in markdown rendering and styling capabilities.

## Performance Features
- Fast markdown parsing and rendering
- Efficient terminal output
- Memory-optimized for large documents
- Responsive keyboard navigation
- Minimal resource usage

---
*Part of PORTX Portable Development Environment*