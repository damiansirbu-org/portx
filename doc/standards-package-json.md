# PORTX Package.json Standards

## Schema Overview

PORTX uses a standardized `package.json` format with two distinct import modes:

### Wrap Mode (Default for Most Packages)
Creates command wrappers for individual executables:

```json
{
  "name": "package-name",
  "version": "1.0.0",
  "description": "Package description (minimum 10 characters)",
  "importType": "wrap",
  "bin": {
    "command-name": {
      "path": "executable.exe",
      "description": "Tool description (minimum 10 characters)",
      "usage": "Usage examples with real commands",
      "dependencies": "windows"
    }
  },
  "tags": ["tag1", "tag2", "tag3", "tag4", "tag5", "tag6"]
}
```

### Path Mode (For Multi-Tool Packages)
Adds entire directories to PATH:

```json
{
  "name": "package-name",
  "version": "1.0.0",
  "description": "Package description",
  "importType": "path",
  "packagePaths": ["./", "./bin"],
  "tags": ["tag1", "tag2", "tag3", "tag4", "tag5", "tag6"]
}
```

## Required Fields

### Core Metadata
- **`name`**: Lowercase alphanumeric with hyphens only
- **`version`**: Semantic version (x.y.z format)
- **`description`**: Minimum 10 characters describing the package

### Import Configuration
- **`importType`**: Must be "wrap", "path", or "auto"
- **`bin`**: Required for "wrap" mode - object mapping command names to executable specs
- **`packagePaths`**: Required for "path" mode - array of relative paths to add to PATH

### Tool Specification (for bin entries)
- **`path`**: Relative path to executable from package root (must end in .exe, .cmd, or .bat)
- **`description`**: Minimum 10 characters describing the tool
- **`usage`**: Real command examples showing practical usage
- **`dependencies`**: Platform requirement ("windows", "linux", "cross-platform")

### Tags
- **`tags`**: Array of categorization tags (minimum 6 recommended, 12-20 optimal)

## Tag Standards

Tags are critical for tool discovery and must comprehensively describe:

### What Goes IN (Input Types)
- `files` - processes files
- `directories` - works with directories  
- `text` - processes text content
- `binary` - handles binary data
- `json` - processes JSON data
- `xml` - handles XML documents
- `csv` - processes CSV files
- `images` - works with image files
- `video` - processes video content
- `audio` - handles audio files
- `archives` - processes compressed files
- `network-traffic` - analyzes network data
- `logs` - processes log files
- `code` - analyzes source code
- `databases` - connects to databases
- `apis` - interfaces with APIs

### What Comes OUT (Output Types)
- `reports` - generates reports
- `formatted-output` - produces formatted text
- `compressed` - creates compressed files
- `encrypted` - outputs encrypted data
- `converted` - transforms file formats
- `analyzed` - provides analysis results
- `visualizations` - creates charts/graphs
- `summaries` - produces condensed information
- `alerts` - generates notifications
- `metrics` - outputs measurements
- `filtered` - provides filtered results

### What the Tool DOES (Primary Actions)
- `search` - finds/locates content
- `filter` - selects subset of data
- `convert` - transforms between formats
- `compress` - reduces file size
- `encrypt` - secures data
- `decrypt` - unseals encrypted data
- `analyze` - examines and reports
- `monitor` - watches for changes
- `backup` - creates copies
- `sync` - synchronizes data
- `download` - retrieves remote content
- `upload` - sends data remotely
- `validate` - checks correctness
- `format` - standardizes appearance
- `extract` - pulls out specific parts
- `merge` - combines multiple inputs
- `split` - divides into parts
- `optimize` - improves performance
- `debug` - troubleshoots issues
- `profile` - measures performance

### Domain/Technology Areas
- `web` - web technologies
- `mobile` - mobile development
- `security` - cybersecurity tools
- `devops` - development operations
- `cloud` - cloud platforms
- `database` - data storage
- `networking` - network operations
- `automation` - task automation
- `testing` - quality assurance
- `deployment` - software release
- `monitoring` - system observation
- `documentation` - doc generation
- `git` - version control
- `docker` - containerization
- `kubernetes` - orchestration
- `aws` - Amazon Web Services
- `azure` - Microsoft Azure
- `android` - Android platform

### Technical Characteristics
- `cli` - command line interface
- `gui` - graphical interface
- `interactive` - requires user input
- `batch` - processes in batches
- `streaming` - handles data streams
- `real-time` - immediate processing
- `cross-platform` - works on multiple OS
- `portable` - no installation required
- `native` - compiled binary
- `scripted` - script-based tool
- `fast` - optimized for speed
- `memory-efficient` - low memory usage
- `multi-threaded` - parallel processing

## Tag Requirements

**Minimum Tags**: Every package must have at least 6 tags covering:
1. Primary input type
2. Primary output type  
3. Main action/function
4. Domain/technology
5. Technical characteristic
6. Secondary function or attribute

**Optimal Tags**: 12-20 tags providing comprehensive coverage for maximum discoverability:
- 2-3 input types
- 2-3 output types
- 3-4 actions/functions
- 2-3 domains/technologies
- 2-3 technical characteristics
- 2-3 additional descriptors

## Examples

### Good Tag Set (18 tags)
```json
"tags": [
  "files", "text", "json", "csv",                    // Input types (4)
  "formatted-output", "reports", "filtered",         // Output types (3) 
  "search", "analyze", "extract", "format",          // Actions (4)
  "development", "data-processing", "cli",           // Domain/tech (3)
  "fast", "cross-platform", "streaming", "batch"    // Characteristics (4)
]
```

### Minimal Tag Set (6 tags)
```json
"tags": [
  "text",           // Input type
  "formatted-output", // Output type
  "search",         // Primary action
  "development",    // Domain
  "cli",           // Interface type
  "fast"           // Key characteristic
]
```

## Validation

All package.json files are validated against the schema at `/schema/package.schema.json` using the validator at `/scripts/validate-json.sh`.

**Validation Requirements:**
- JSON syntax must be valid
- All required fields must be present
- Field formats must match schema patterns
- Conditional requirements must be satisfied (bin for wrap mode, packagePaths for path mode)
- Tags must follow naming conventions (lowercase, alphanumeric with hyphens)

## Migration Notes

When converting from legacy format:
1. Remove all JavaScript comments
2. Extract primary tool from `tools` array for `bin` entry
3. Convert `paths` field to `packagePaths` for path mode packages
4. Ensure comprehensive tag coverage
5. Add proper `importType` specification
6. Validate against schema before committing