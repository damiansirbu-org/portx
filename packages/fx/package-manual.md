# fx Package Manual

## Package Information
- **Package Name**: fx
- **Category**: Text Processing
- **Type**: JSON Viewer/Explorer
- **License**: MIT

## Description
Terminal JSON viewer and processor with interactive exploration and jq-compatible syntax.

Interactive JSON tool for viewing, exploring, and processing JSON data in the terminal.
Features syntax highlighting, interactive browsing, and powerful query capabilities.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| fx.exe | Interactive JSON viewer and processor | Explore and manipulate JSON data interactively |

## Common Usage Examples

### Basic JSON Viewing
```bash
# View JSON file interactively
fx data.json

# Pipe JSON from command
echo '{"name": "John", "age": 30}' | fx

# Process API response
curl -s https://api.github.com/users/octocat | fx

# View large JSON files
fx large-data.json
```

### Interactive Navigation
```bash
# Launch interactive mode
fx data.json

# In interactive mode:
# ↑/↓ - Navigate through object/array items
# →/← - Expand/collapse objects and arrays
# Enter - Select and drill down
# / - Search within JSON
# q - Quit
```

### Non-Interactive Processing
```bash
# Extract specific field
fx data.json .name

# Process array elements
fx data.json '.[0]'

# Apply jq-style filters
fx data.json '.users[] | select(.age > 25)'

# Chain operations
fx data.json '.data | length'
```

### Data Transformation
```bash
# Transform object structure
fx data.json '{name: .fullName, years: .age}'

# Map over arrays
fx data.json '.users | map(.name)'

# Filter and transform
fx data.json '.items | map(select(.active)) | .[].name'

# Group and aggregate
fx data.json 'group_by(.department) | map({dept: .[0].department, count: length})'
```

### Output Formatting
```bash
# Pretty print JSON
fx --raw-output data.json

# Compact output
fx --compact-output data.json

# Raw string output (no quotes)
fx -r data.json '.message'

# Monochrome output
fx --monochrome data.json
```

### File Operations
```bash
# Save processed output
fx data.json '.filtered_data' > output.json

# Process multiple files
fx file1.json file2.json

# Read from stdin
cat data.json | fx '.important_field'
```

### Advanced Queries
```bash
# Complex filtering
fx data.json '.users[] | select(.role == "admin" and .active == true)'

# Mathematical operations
fx data.json '.items | map(.price) | add'

# String manipulation
fx data.json '.users | map(.name | ascii_upcase)'

# Date operations
fx data.json '.events | map(select(.date | strptime("%Y-%m-%d") | mktime > now - 86400))'
```

### API Data Processing
```bash
# GitHub API exploration
curl -s https://api.github.com/repos/microsoft/vscode | fx

# Extract specific data
curl -s https://api.github.com/users/octocat/repos | fx 'map(.name)'

# Process paginated results
curl -s https://jsonplaceholder.typicode.com/posts | fx 'map(select(.userId == 1))'
```

### Configuration Analysis
```bash
# Explore package.json
fx package.json

# Check dependencies
fx package.json '.dependencies | keys'

# Analyze nested configuration
fx config.json '.database.connections[0]'
```

### Data Validation
```bash
# Check for required fields
fx data.json 'map(select(has("required_field"))) | length'

# Validate data types
fx data.json '.users | map(select(.age | type == "number"))'

# Find inconsistencies
fx data.json 'group_by(.type) | map({type: .[0].type, count: length})'
```

### Log Analysis
```bash
# Process structured logs
fx logs.json '.entries[] | select(.level == "error")'

# Time-based filtering
fx logs.json '.logs | map(select(.timestamp | . > "2023-01-01"))'

# Aggregate log levels
fx logs.json 'group_by(.level) | map({level: .[0].level, count: length})'
```

## Interactive Mode Features

### Navigation
- **Arrow Keys**: Navigate through JSON structure
- **Enter**: Expand/collapse objects and arrays
- **Space**: Mark items for selection
- **/** : Search within current view
- **g/G**: Go to beginning/end

### Actions
- **y**: Copy current path to clipboard
- **Y**: Copy current value to clipboard
- **d**: Download current view as file
- **?**: Show help
- **q**: Quit application

### Search and Filter
- **/**:  Search for keys or values
- **n/N**: Navigate between search results
- **Ctrl+f**: Advanced filter mode
- **Esc**: Clear search/filter

## Installation
Interactive JSON viewer and processor with powerful query capabilities.
Essential tool for API development, configuration management, and data analysis.

## Dependencies
None - standalone executable with built-in JSON processing and interactive display.

## Performance Features
- Optimized for large JSON files
- Streaming JSON processing
- Memory-efficient display
- Fast search and navigation
- Syntax highlighting

---
*Part of PORTX Portable Development Environment*