# jq Package Manual

## Package Information
- **Package Name**: jq
- **Category**: Text Processing
- **Type**: JSON Processor
- **License**: MIT

## Description
Command-line JSON processor for parsing, filtering, and transforming JSON data.

Lightweight and flexible tool for working with JSON from command line and scripts.
Essential for API testing, data transformation, and JSON manipulation workflows.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| jq.exe | JSON command-line processor | Parse, filter, and transform JSON data |

## Common Usage Examples

### Basic JSON Operations
```bash
# Pretty-print JSON
echo '{"name":"John","age":30}' | jq '.'

# Extract specific field
echo '{"name":"John","age":30}' | jq '.name'

# Extract multiple fields
echo '{"name":"John","age":30}' | jq '.name, .age'
```

### Array Operations
```bash
# Process array elements
echo '[1,2,3,4,5]' | jq '.[]'

# Filter array elements
echo '[1,2,3,4,5]' | jq '.[] | select(. > 3)'

# Map over array
echo '[1,2,3]' | jq 'map(. * 2)'

# Get array length
echo '[1,2,3,4,5]' | jq 'length'
```

### Object Manipulation
```bash
# Add new field
echo '{"name":"John"}' | jq '. + {"age": 30}'

# Remove field
echo '{"name":"John","age":30}' | jq 'del(.age)'

# Rename field
echo '{"name":"John"}' | jq '{full_name: .name}'

# Merge objects
echo '{"a":1} {"b":2}' | jq -s '.[0] + .[1]'
```

### Complex Filtering
```bash
# Filter objects in array
echo '[{"name":"John","age":30},{"name":"Jane","age":25}]' | jq '.[] | select(.age > 27)'

# Group by field
echo '[{"dept":"IT","name":"John"},{"dept":"HR","name":"Jane"},{"dept":"IT","name":"Bob"}]' | jq 'group_by(.dept)'

# Sort by field
echo '[{"name":"John","age":30},{"name":"Jane","age":25}]' | jq 'sort_by(.age)'
```

### API Response Processing
```bash
# Extract data from API response
curl -s https://api.github.com/users/octocat | jq '.name, .public_repos'

# Process paginated API results
curl -s https://api.github.com/users/octocat/repos | jq '.[].name'

# Filter and transform API data
curl -s https://jsonplaceholder.typicode.com/posts | jq '.[] | select(.userId == 1) | {title, body}'
```

### Advanced Features
```bash
# Conditional expressions
echo '[1,2,3,4,5]' | jq 'map(if . > 3 then "big" else "small" end)'

# String manipulation
echo '{"name":"john doe"}' | jq '.name | split(" ") | map(. | ascii_upcase) | join(" ")'

# Date handling
echo '{"timestamp":"2023-01-01T12:00:00Z"}' | jq '.timestamp | strptime("%Y-%m-%dT%H:%M:%SZ") | strftime("%Y-%m-%d")'

# Math operations
echo '[1,2,3,4,5]' | jq 'add / length'
```

### File Processing
```bash
# Process JSON file
jq '.users[] | select(.active == true)' users.json

# Output to file
jq '.users[] | {name, email}' users.json > filtered_users.json

# Process multiple JSON files
jq -s '.[0] + .[1]' file1.json file2.json
```

### Output Formatting
```bash
# Raw output (no quotes)
echo '{"message":"Hello World"}' | jq -r '.message'

# Compact output
echo '{"name":"John","age":30}' | jq -c '.'

# Tab-separated values
echo '[{"name":"John","age":30},{"name":"Jane","age":25}]' | jq -r '.[] | [.name, .age] | @tsv'

# CSV output
echo '[{"name":"John","age":30},{"name":"Jane","age":25}]' | jq -r '.[] | [.name, .age] | @csv'
```

## Installation
Lightweight JSON processor for command-line data manipulation.
Essential tool for working with APIs, configuration files, and data transformation.

## Dependencies
None - standalone executable for JSON processing.

## Use Cases
- API response processing
- Configuration file manipulation
- Data transformation pipelines
- Log analysis and filtering
- DevOps automation scripts

---
*Part of PORTX Portable Development Environment*