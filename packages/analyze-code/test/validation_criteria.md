# Analyzer Validation Criteria

This document defines what constitutes "meaningful data" from analyzers and how to validate analyzer outputs to ensure they provide valuable insights rather than error messages or empty results.

## Overview

The analyzer validation framework tests all analyzers against comprehensive test files to ensure they return:
1. **Structurally valid output** - Proper JSON format with expected fields
2. **Meaningful content** - Actual analysis data, not error messages
3. **Consistent behavior** - Reliable results across different file types
4. **Performance** - Results within reasonable time limits

## Validation Levels

### Level 1: Basic Output Validation
- **JSON Syntax**: Output must be valid JSON
- **Non-empty**: Output must contain actual data, not empty objects/arrays
- **No failure patterns**: Must not contain error indicators

### Level 2: Structure Validation
- **Required fields**: Each analyzer must include expected fields
- **Field types**: Fields must contain appropriate data types
- **Minimum data**: Must meet minimum data quantity thresholds

### Level 3: Content Quality Validation
- **Semantic correctness**: Analysis results must be logically correct
- **Cross-reference detection**: Must identify relationships between files
- **Language-specific insights**: Must provide language-appropriate analysis

## Analyzer-Specific Criteria

### ctags Analyzer
**Purpose**: Extract code symbols and structures

**Required Output Structure**:
```json
[
  {
    "_type": "tag",
    "name": "function_name",
    "path": "/path/to/file.ext",
    "language": "Python",
    "line": 42,
    "kind": "function",
    "pattern": "/^def function_name/",
    "signature": "function_name(param1, param2)"
  }
]
```

**Validation Criteria**:
- Must be array with at least 1 entry for code files
- Each entry must have: `_type`, `name`, `path`, `language`, `line`, `kind`
- `name` must be non-empty string
- `line` must be positive integer
- `kind` must be valid ctags kind (function, class, variable, etc.)
- Must detect multiple symbols in complex files

**Quality Thresholds**:
- Java files: ≥10 symbols (classes, methods, fields)
- Python files: ≥8 symbols (functions, classes, variables)
- JavaScript files: ≥6 symbols (functions, objects, variables)
- C++ files: ≥12 symbols (classes, methods, templates)
- C# files: ≥10 symbols (classes, methods, properties)

### scc (Source Lines of Code Counter) Analyzer
**Purpose**: Analyze code metrics and complexity

**Required Output Structure**:
```json
{
  "analyzer": "scc",
  "file": "/path/to/file.ext",
  "language": "Python",
  "metrics": {
    "total_lines": 150,
    "code_lines": 120,
    "comment_lines": 20,
    "blank_lines": 10,
    "total_complexity": 25
  }
}
```

**Validation Criteria**:
- Must have: `analyzer`, `file`, `language`, `metrics`
- Metrics must include: `total_lines`, `code_lines`, `total_complexity`
- All numeric values must be non-negative integers
- `total_lines` ≥ `code_lines` + `comment_lines` + `blank_lines`
- `total_complexity` should reflect actual code complexity

**Quality Thresholds**:
- Files >50 lines: `total_complexity` ≥ 5
- Files >100 lines: `total_complexity` ≥ 10
- `code_lines` should be 60-80% of `total_lines` for well-documented code

### treesitter Analyzer
**Purpose**: Parse code into Abstract Syntax Tree

**Required Output Structure**:
```json
{
  "analyzer": "treesitter",
  "language": "python",
  "file": "/path/to/file.py",
  "ast_available": true,
  "functions": [
    {
      "name": "process_data",
      "line_start": 15,
      "line_end": 25,
      "parameters": ["data", "options"]
    }
  ],
  "variable_assignments": [
    {
      "name": "config",
      "line": 5,
      "value_type": "dict"
    }
  ]
}
```

**Validation Criteria**:
- Must have: `analyzer`, `language`, `file`, `ast_available`
- If `ast_available` is true, must have code elements (`functions`, `variable_assignments`, etc.)
- Function entries must have: `name`, `line_start`, `line_end`
- Variable assignments must have: `name`, `line`
- Must detect nested structures in complex files

**Quality Thresholds**:
- Complex files (>100 lines): ≥5 functions or ≥10 variable assignments
- Object-oriented files: Must detect class definitions and methods
- Must identify control structures (if/else, loops) in procedural code

### ast_grep Analyzer
**Purpose**: Pattern matching and code search

**Required Output Structure**:
```json
{
  "analyzer": "ast_grep",
  "language": "java",
  "file": "/path/to/file.java",
  "analysis_summary": {
    "patterns_tried": 8,
    "successful_patterns": 3,
    "total_matches": 15
  },
  "matches": [
    {
      "pattern": "class $NAME",
      "line": 10,
      "match": "class UserService",
      "context": "public class UserService implements Service"
    }
  ]
}
```

**Validation Criteria**:
- Must have: `analyzer`, `language`, `file`, `analysis_summary`
- Summary must have: `patterns_tried`, `successful_patterns`
- `patterns_tried` ≥ `successful_patterns`
- If `successful_patterns` > 0, must have `matches` array
- Matches must have: `pattern`, `line`, `match`

**Quality Thresholds**:
- Must try ≥5 patterns for comprehensive analysis
- Success rate: `successful_patterns`/`patterns_tried` ≥ 20%
- Complex files should have ≥10 total matches

### shellcheck Analyzer
**Purpose**: Shell script static analysis

**Required Output Structure**:
```json
{
  "analyzer": "shellcheck",
  "file": "/path/to/script.sh",
  "status": "analyzed",
  "issues": [
    {
      "line": 25,
      "column": 10,
      "level": "warning",
      "code": "SC2086",
      "message": "Double quote to prevent globbing",
      "suggestion": "Use \"$var\" instead of $var"
    }
  ],
  "summary": {
    "total_issues": 3,
    "errors": 0,
    "warnings": 2,
    "info": 1
  }
}
```

**Validation Criteria**:
- Must have: `analyzer`, `file`, `status`
- Status must be one of: `analyzed`, `no_issues`, `issues_found`
- If status is `issues_found`, must have `issues` array and `summary`
- Issues must have: `line`, `level`, `code`, `message`
- Summary counts must match issues array

**Quality Thresholds**:
- Must analyze without timeout for scripts <500 lines
- Should detect common shell scripting issues
- Must provide actionable suggestions for warnings/errors

### dependency Analyzer
**Purpose**: Analyze import/include dependencies

**Required Output Structure**:
```json
{
  "analyzer": "dependency",
  "file": "/path/to/file.py",
  "language": "python",
  "dependencies": {
    "imports_in_this_file": [
      {
        "name": "json",
        "type": "standard_library",
        "line": 3
      },
      {
        "name": "custom_module",
        "type": "local_import",
        "line": 5,
        "resolved_path": "/path/to/custom_module.py"
      }
    ],
    "resolved_dependencies": [
      {
        "import_name": "custom_module",
        "file_path": "/path/to/custom_module.py",
        "exists": true
      }
    ]
  }
}
```

**Validation Criteria**:
- Must have: `analyzer`, `file`, `language`, `dependencies`
- Dependencies must have: `imports_in_this_file`, `resolved_dependencies`
- Import entries must have: `name`, `type`, `line`
- Resolved entries must have: `import_name`, `file_path`, `exists`
- Must attempt to resolve local imports to actual files

**Quality Thresholds**:
- Files with imports: Must detect ≥80% of actual import statements
- Must distinguish between standard library, third-party, and local imports
- Local import resolution accuracy: ≥70% for files within test directory

### dependency_reverse Analyzer
**Purpose**: Find what imports/references a given file

**Required Output Structure**:
```json
{
  "analyzer": "dependency_reverse", 
  "file": "/path/to/target.py",
  "language": "python",
  "reverse_analysis": {
    "importers": [
      {
        "file": "/path/to/importer.py",
        "line": 8,
        "import_statement": "from target import function"
      }
    ],
    "referrers": [
      {
        "file": "/path/to/config.yaml",
        "line": 45,
        "reference": "scripts/target.py"
      }
    ],
    "total_reverse_deps": 3
  }
}
```

**Validation Criteria**:
- Must have: `analyzer`, `file`, `language`, `reverse_analysis`
- Reverse analysis must have: `importers`, `referrers`, `total_reverse_deps`
- Importer entries must have: `file`, `line`, `import_statement`
- Referrer entries must have: `file`, `line`, `reference`
- `total_reverse_deps` must equal sum of importers and referrers

**Quality Thresholds**:
- Must find cross-references between test files (they're designed with them)
- Should detect at least 2 reverse dependencies for interconnected files
- Must search multiple file types for references (code, config, documentation)

## Failure Patterns

The following patterns in output indicate analyzer failure and cause test failure:

### Error Messages
- `"no parser"` - Parser not available for file type
- `"not found"` - File or tool not found
- `"unavailable"` - Analyzer tool not installed
- `"failed to analyze"` - Analysis process failed
- `"empty result"` - No meaningful data extracted

### Technical Issues
- `"timeout"` - Analysis took too long
- `"error:"` - Generic error occurred
- `"exception:"` - Unhandled exception
- `"null"` or `"undefined"` - Missing required data
- Empty JSON objects `{}` or arrays `[]` when data expected

### Output Quality Issues
- Response contains only error fields
- Required fields missing or null
- Numeric fields with impossible values (negative line numbers)
- Malformed JSON syntax
- Response smaller than 50 characters (likely just error message)

## Cross-Reference Validation

Test files are designed with explicit cross-references to validate dependency analyzers:

### Reference Network
- **TestService.java** references: User.java, DatabaseConnection.java, JsonHelper.js
- **json_helper.py** references: config.yaml, TestService.java, scripts
- **tests.js** references: package.json, config.yaml, execute_tests.sh
- **UserService.cs** references: DatabaseConnection, User, json_helper.py
- **config.yaml** references: All service files, database, external services
- **execute_tests.sh** references: All test files, config.yaml

### Validation Requirements
- Dependency analyzer must detect ≥60% of explicit references
- dependency_reverse analyzer must find reverse references
- References across different file types must be detected
- Helm chart references to services must be identified

## Performance Requirements

### Time Limits
- **ctags**: <5 seconds per file
- **scc**: <3 seconds per file  
- **treesitter**: <10 seconds per file
- **ast_grep**: <15 seconds per file
- **shellcheck**: <8 seconds per file
- **dependency**: <12 seconds per file
- **dependency_reverse**: <20 seconds per file (searches multiple files)

### Resource Usage
- Memory usage should not exceed 500MB per analyzer
- CPU usage spikes are acceptable but should not exceed 2 minutes
- Temporary files must be cleaned up after analysis

## Test Environment

### Test File Characteristics
- **Complexity**: Files designed with realistic complexity
- **Size**: Range from 50-500 lines to test scalability
- **Cross-references**: Explicit references between files
- **Language features**: Use modern language features and patterns
- **Comments**: Include documentation and cross-reference comments

### Execution Environment
- **Platform**: Windows with Git Bash (MINGW64)
- **Python**: 3.8+ required
- **Tools**: ctags, scc, shellcheck should be available
- **Timeout**: 30-second timeout per analyzer execution
- **Parallelism**: Tests can run in parallel for performance

## Quality Gates

### Pass Criteria (Per Analyzer)
- **100%**: No failures, all validations pass
- **≥90%**: Excellent quality, minor edge cases
- **≥80%**: Good quality, acceptable for production
- **≥70%**: Fair quality, needs improvement
- **≥60%**: Poor quality, significant issues
- **<60%**: Failing quality, major rework needed

### Overall Test Suite
- **≥80% pass rate**: Excellent overall quality
- **≥60% pass rate**: Good overall quality
- **≥40% pass rate**: Needs improvement
- **<40% pass rate**: Critical issues requiring immediate attention

### Continuous Improvement
- Failed tests should be investigated and fixed
- New validation criteria should be added as analyzers improve
- Performance benchmarks should be updated as tools evolve
- Test files should be enhanced to cover more edge cases

## Usage

Run the comprehensive test suite:
```bash
bash run_analyzer_tests.sh
```

Run individual Bats tests:
```bash
bats analyzer_validation.bats
```

View detailed results:
```bash
cat reports/test_summary.json
cat reports/test_execution.log
```

The validation framework provides detailed reporting, performance metrics, and quality assessment to ensure analyzer reliability and usefulness.