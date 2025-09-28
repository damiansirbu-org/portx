# PORTX Tools Parameters and Returns Reference

**Total Tools**: 369
**Analysis Date**: 2025-09-27

## Parameter Types

- 🟢 **Path Parameter**: Real file/directory path - CONVERT
- 🔴 **Pattern Parameter**: Search pattern/regex - NEVER CONVERT
- 🟡 **Mixed Parameter**: Context-dependent - CAREFUL HANDLING
- ⚪ **Other Parameter**: Non-path related

## Return Types

- 📁 **File Paths**: Returns file/directory paths
- 📄 **File Content**: Returns file contents only
- 📊 **Structured Data**: JSON/formatted output
- 🔍 **Search Results**: Mixed paths + content
- ⚪ **Other**: Non-path output

## Critical Tools

### 🔥 CRITICAL - git (git-extras)
**Conversion Required**: ESSENTIAL
**Key Parameters**:
- `--git-dir=path` - 🟢 Repository directory
- `--work-tree=path` - 🟢 Working tree directory
- `-C path` - 🟢 Change to directory
**Returns**: 📁/🔍 Command dependent (status→paths, log→metadata)

### ⚡ HIGH PRIORITY

#### fd (fd)
**Conversion Required**: HIGH
**Parameters**:
- `PATTERN` (pos 1) - 🔴 Search pattern - NEVER CONVERT
- `PATH` (pos 2+) - 🟢 Search directories - ALWAYS CONVERT
**Returns**: 📁 Pure file paths (Windows format)

#### rg (ripgrep)
**Conversion Required**: HIGH
**Parameters**:
- `PATTERN` (pos 1) - 🔴 Search regex - NEVER CONVERT
- `PATH` (pos 2+) - 🟢 Search directories - ALWAYS CONVERT
- `--glob=pattern` - 🔴 File pattern - NEVER CONVERT
**Returns**: 🔍 Path:line:content format

#### 7za (7zip)
**Conversion Required**: HIGH
**Parameters**:
- `archive_file` - 🟢 Archive path - CONVERT
- `file_list` - 🟢 Files to archive - CONVERT
- `-o{path}` - 🟢 Output directory (embedded) - CONVERT
**Returns**: 📁 File operation lists (Windows paths)

#### tar (git-extras)
**Conversion Required**: HIGH
**Parameters**:
- `-f archive.tar` - 🟢 Archive file - CONVERT
- `file_list` - 🟢 Files to archive - CONVERT
**Returns**: 📁 File lists in operations

#### gzip (git-extras)
**Conversion Required**: HIGH
**Parameters**:
- `file.txt` - 🟢 File to compress - CONVERT
**Returns**: 📁 Compressed file paths

#### pigz (pigz)
**Conversion Required**: HIGH
**Parameters**:
- `file.txt` - 🟢 File to compress - CONVERT
**Returns**: 📁 Parallel compression file lists

## Parameter Patterns

### Embedded Path Parameters
**Critical Pattern**: `--option=/mnt/c/path`
- `git --git-dir=/mnt/c/repo/.git` → `git --git-dir=C:\repo\.git`
- `7za a -oC:\output` (no conversion needed)

### Positional Conflicts
**Pattern**: Tool with pattern vs path in same position
- `rg PATTERN [PATH...]` - Position 1=pattern, 2+=paths
- `fd PATTERN [PATH...]` - Position 1=pattern, 2+=paths
- `grep PATTERN [PATH...]` - Position 1=pattern, 2+=paths

### Pattern Parameters (NEVER CONVERT)
- File globs: `*.txt`, `**/*.rs`
- Regex patterns: `\d+`, `^test.*\.py$`
- Search patterns: `/mnt/c/.*\.log` (looks like path but is regex)

## Return Format Conversions

### Path Output Conversion
**Required for**: fd, rg, git (some commands), find, es, ag

**Conversion Pattern**:
```
C:\path\file.txt → /mnt/c/path/file.txt
```

**Tool-Specific Examples**:
- **fd**: `C:\src\main.rs` → `/mnt/c/src/main.rs`
- **rg**: `C:\src\main.rs:42:match` → `/mnt/c/src/main.rs:42:match`
- **git status**: `modified: src/main.rs` (relative, no conversion)
- **git ls-files**: `src/main.rs` (relative, no conversion)

### Structured Output (No Conversion)
**Tools**: Most CLI tools, JSON output, metadata
- Build tools (npm, cargo, gradle)
- Network tools (curl, wget)
- System tools (ps, top)
- Package managers (apt, chocolatey)

## Implementation Rules

### Path Conversion Rules
1. **Input Parameters**: Convert Unix paths to Windows for tool execution
2. **Output Results**: Convert Windows paths to Unix for user display
3. **Pattern Parameters**: NEVER convert (breaks regex/globs)
4. **Embedded Parameters**: Parse and convert path portion only

### Critical Exclusions
**NEVER Convert These Patterns**:
- Regex: `\d+`, `^test.*`, `[a-z]+`
- Globs: `*.txt`, `**/*.rs`, `??.log`
- URLs: `http://`, `https://`, `ftp://`
- Pseudo-paths: `/dev/null`, `/proc/`, `/sys/`

### Safety Rules
1. **Read-only tools**: Safe to convert aggressively (rg, fd, find)
2. **Write tools**: Conservative conversion (git, tar, 7za)
3. **System tools**: No conversion unless explicitly path-related
4. **Unknown tools**: Default to no conversion

## Quick Reference

### High-Risk Conversions
- `git --git-dir` - Essential for Git functionality
- `rg PATTERN vs PATH` - Pattern detection critical
- `fd PATTERN vs PATH` - Pattern detection critical
- `7za -o{path}` - Embedded path parsing needed

### Safe Conversions
- Pure file listing tools (find, es)
- File content tools (cat, bat, head, tail)
- Archive extraction (when paths in filenames)

### No Conversion Needed
- Network tools (curl, wget)
- Text processing (awk, sed, grep patterns)
- System monitoring (ps, top, htop)
- Package managers (npm, cargo, apt)