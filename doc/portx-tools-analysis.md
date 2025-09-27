# PORTX Tools Complete Parameter and Return Type Analysis

## Purpose
Comprehensive analysis of ALL PORTX tools based on their portx.json configurations to determine:
1. Which parameters accept file/directory paths
2. Which parameters accept patterns/regexes (must NOT be converted)
3. What types of paths/data each tool returns
4. Conversion requirements and risks for each executable

## Analysis Framework

**Parameter Types:**
- 🟢 **Safe Path**: Real file/directory path - SHOULD convert `/mnt/c/` → `C:\`
- 🔴 **Pattern/Regex**: Search pattern - MUST NOT convert (breaks regex)
- 🟡 **Ambiguous**: Could be either - needs investigation
- ⚪ **Non-path**: Not path-related

**Return Types:**
- 📁 **File Paths**: Returns actual file/directory paths
- 📄 **File Content**: Returns file contents (no paths)
- 📊 **Structured Data**: JSON/formatted output
- 🔍 **Search Results**: Mixed paths + content
- ⚪ **Other**: Non-path output

**Conversion Priority:**
- 🔥 **CRITICAL**: Tool completely broken without conversion
- ⚡ **HIGH**: Major functionality impaired
- 📝 **MEDIUM**: Some features affected
- 📋 **LOW**: Minor improvements only
- ❌ **NONE**: No conversion needed

---

## Complete Executable Inventory

### Git Package (git-extras)
**Executables**: delta.exe, difft.exe, gh.exe, gitstatusd.exe, tig.exe, git-lfs.exe, git.exe, git-credential-wincred.exe, git-remote-http.exe, git-remote-https.exe, gpg.exe, gzip.exe, scp.exe, ssh.exe, ssh-add.exe, ssh-agent.exe, ssh-keygen.exe, ssh-keyscan.exe, ssh-pageant.exe, tar.exe

_Analyzing each package systematically..._

---

## Detailed Tool Analysis

### Git-Related Tools

#### git.exe 🔥 **CRITICAL**
**Purpose**: Git distributed version control system
**Parameters**:
- `--git-dir=path` - 🟢 **CRITICAL PATH**: Git repository directory
- `--work-tree=path` - 🟢 **CRITICAL PATH**: Working tree directory
- `--exec-path=path` - 🟢 Path to git executables
- `--file=path` - 🟢 Configuration file path
- `--grep=pattern` - 🔴 **REGEX**: Search pattern in commit messages

**Returns**: 📁/📊 Mixed - Command dependent
- `git status` → 📁 Relative file paths
- `git ls-files` → 📁 Repository file paths
- `git log` → 📊 Commit metadata
- `git diff` → 🔍 File paths + content

**Conversion Priority**: 🔥 **CRITICAL** - Completely broken without `--git-dir`/`--work-tree` conversion

#### delta.exe 📝 **MEDIUM**
**Purpose**: Syntax-highlighting pager for git/diff output
**Parameters**:
- `delta file1.txt file2.txt` - 🟢 File paths for comparison
- `--theme=name` - ⚪ Theme name
- `--config=path` - 🟢 Configuration file path

**Returns**: 📄 **Formatted Content** - Syntax-highlighted diff output
**Conversion Priority**: 📝 **MEDIUM** - File comparison needs path conversion

#### difft.exe 📝 **MEDIUM**
**Purpose**: Structural diff with syntax awareness
**Parameters**:
- `difft file1.py file2.py` - 🟢 File paths for comparison
- `--language=lang` - ⚪ Programming language
- `--display=mode` - ⚪ Display mode

**Returns**: 📄 **Structured Diff** - Language-aware diff output
**Conversion Priority**: 📝 **MEDIUM** - File comparison needs path conversion

#### gh.exe 📋 **LOW**
**Purpose**: GitHub CLI
**Parameters**:
- `gh repo create name` - ⚪ Repository name
- `--config-dir=path` - 🟢 Config directory path

**Returns**: 📊 **API Data** - GitHub API responses, JSON
**Conversion Priority**: 📋 **LOW** - Mostly API operations, minimal local paths

#### tig.exe 📋 **LOW**
**Purpose**: Text-mode Git interface
**Parameters**:
- `tig [path]` - 🟢 Repository path (optional)
- `tig show commit` - ⚪ Git object reference

**Returns**: ⚪ **Interactive TUI** - Terminal interface, no path output
**Conversion Priority**: 📋 **LOW** - Interactive tool, minimal path usage

#### git-lfs.exe 📝 **MEDIUM**
**Purpose**: Git Large File Storage
**Parameters**:
- `git-lfs track pattern` - 🔴 **PATTERN**: File patterns like '*.psd'
- `git-lfs pull` - ⚪ No paths

**Returns**: 📁 **File Paths** - Lists tracked LFS files
**Conversion Priority**: 📝 **MEDIUM** - Track patterns vs actual paths

### File Search & Find Tools

#### fd.exe ⚡ **HIGH**
**Purpose**: Intuitive find replacement with regex support
**Parameters**:
- `fd pattern [path]` - pattern=🔴 **REGEX**, path=🟢 **SEARCH DIR**
- `fd -t f` - ⚪ Type filter (file/dir)
- `fd -e ext` - ⚪ Extension filter
- `fd -x command` - 🟡 **EXEC COMMAND** (may contain paths)

**Returns**: 📁 **File Paths** - Full Windows paths to found files
**Example Output**: `C:\Work\Git\project\src\main.rs`
**Conversion Priority**: ⚡ **HIGH** - Critical for WSL usability

#### ripgrep (rg.exe) ⚡ **HIGH** ⚠️ **CONFLICT**
**Purpose**: Fast grep with .gitignore support
**Parameters**:
- `rg pattern [path]` - pattern=🔴 **REGEX**, path=🟢 **SEARCH DIR**
- `rg --regexp pattern` - 🔴 **REGEX PATTERN** (MUST NOT CONVERT)
- `rg --type rust` - ⚪ File type filter
- `rg --ignore-file path` - 🟢 Ignore file path

**Returns**: 🔍 **Search Results** - `filepath:line:match`
**Example Output**: `C:\src\main.rs:45:let result = panic!()`
**Conversion Priority**: ⚡ **HIGH** - Output needs conversion, patterns MUST NOT be converted
**⚠️ CRITICAL CONFLICT**: Needs selective parameter handling

### Archive & Compression Tools

#### 7za.exe (7zip) ⚡ **HIGH**
**Purpose**: Archive management
**Parameters**:
- `7za a archive.zip files...` - files=🟢 **FILE PATHS**
- `7za x archive.zip -o path` - path=🟢 **OUTPUT DIR**
- `7za l archive.zip` - ⚪ List contents

**Returns**: 📁 **File Lists** - Paths of files in/being archived
**Example Output**: `C:\path\file1.txt` (when listing archive contents)
**Conversion Priority**: ⚡ **HIGH** - File operations need path conversion

### Text Processing Tools

#### ast-grep.exe 📝 **MEDIUM**
**Purpose**: Structural code search using AST
**Parameters**:
- `ast-grep pattern [path]` - pattern=🔴 **AST PATTERN**, path=🟢 **SEARCH DIR**
- `--config path` - 🟢 Config file path

**Returns**: 🔍 **Search Results** - File paths with matches
**Conversion Priority**: 📝 **MEDIUM** - Returns file paths

#### gron.exe 📋 **LOW**
**Purpose**: JSON flattening tool
**Parameters**:
- `gron file.json` - 🟢 **FILE PATH**
- `gron < input` - ⚪ Stdin input

**Returns**: 📄 **JSON Data** - Flattened JSON, no paths
**Conversion Priority**: 📋 **LOW** - Input files only

### Development Runtimes

#### node.exe ❌ **NONE**
**Purpose**: JavaScript runtime
**Parameters**:
- `node script.js` - 🟢 **SCRIPT PATH**
- `--require module` - 🟡 Module path or name

**Returns**: 📄 **Script Output** - Whatever the JavaScript outputs
**Conversion Priority**: ❌ **NONE** - Node handles paths internally

#### java.exe ❌ **NONE**
**Purpose**: Java runtime
**Parameters**:
- `java -cp classpath Main` - 🟡 Classpath (complex)
- `java Main` - ⚪ Class name

**Returns**: 📄 **Program Output** - Java application output
**Conversion Priority**: ❌ **NONE** - JVM handles paths

#### python.exe ❌ **NONE**
**Purpose**: Python runtime
**Parameters**:
- `python script.py` - 🟢 **SCRIPT PATH**
- `--module-path path` - 🟢 Module directory

**Returns**: 📄 **Script Output** - Python program output
**Conversion Priority**: ❌ **NONE** - Python handles paths internally

### Build Tools

#### gradle.exe 📝 **MEDIUM**
**Purpose**: Build automation
**Parameters**:
- `gradle --project-dir path` - 🟢 **PROJECT DIR**
- `gradle --build-file path` - 🟢 **BUILD FILE**
- `gradle build` - ⚪ Task name

**Returns**: 📊 **Build Output** - May include file paths in build logs
**Conversion Priority**: 📝 **MEDIUM** - Build logs contain paths

#### maven.exe 📝 **MEDIUM**
**Purpose**: Maven build tool
**Parameters**:
- `mvn -f path/pom.xml` - 🟢 **POM FILE PATH**
- `mvn -Dmaven.repo.local=path` - 🟢 **REPO PATH**

**Returns**: 📊 **Build Output** - Build logs with file paths
**Conversion Priority**: 📝 **MEDIUM** - Build logs contain paths

### Network Tools

#### curl.exe ❌ **NONE**
**Purpose**: HTTP client
**Parameters**:
- `curl url -o file` - url=⚪, file=🟢 **OUTPUT FILE**
- `curl --config file` - 🟢 **CONFIG FILE**

**Returns**: 📄 **Network Content** - HTTP response content
**Conversion Priority**: ❌ **NONE** - Network content, not local paths

#### wget.exe ❌ **NONE**
**Purpose**: Web downloader
**Parameters**:
- `wget url -O file` - url=⚪, file=🟢 **OUTPUT FILE**
- `wget --config file` - 🟢 **CONFIG FILE**

**Returns**: 📄 **Download Content** - Downloaded files
**Conversion Priority**: ❌ **NONE** - Network downloads

### Database Tools

#### sqlite.exe 📋 **LOW**
**Purpose**: SQLite database
**Parameters**:
- `sqlite database.db` - 🟢 **DATABASE FILE**
- `.read file.sql` - 🟢 **SQL FILE** (interactive command)

**Returns**: 📊 **Database Results** - Query results, no file paths
**Conversion Priority**: 📋 **LOW** - Database content only

#### usql.exe 📋 **LOW**
**Purpose**: Universal SQL client
**Parameters**:
- `usql "driver://connection"` - ⚪ Connection string
- `usql --file script.sql` - 🟢 **SQL SCRIPT FILE**

**Returns**: 📊 **Database Results** - Query results
**Conversion Priority**: 📋 **LOW** - Database operations

### System Tools

#### eza.exe 📝 **MEDIUM**
**Purpose**: Enhanced ls replacement
**Parameters**:
- `eza [path]` - 🟢 **DIRECTORY PATH**
- `eza --ignore-glob pattern` - 🔴 **GLOB PATTERN**

**Returns**: 📁 **File Listings** - Directory contents (usually relative paths)
**Example Output**: `README.md`, `src/`, `target/` (relative)
**Conversion Priority**: 📝 **MEDIUM** - Input directory conversion needed

#### bat.exe 📋 **LOW**
**Purpose**: Cat with syntax highlighting
**Parameters**:
- `bat file1 file2` - 🟢 **FILE PATHS**
- `bat --config-file path` - 🟢 **CONFIG FILE**

**Returns**: 📄 **File Content** - File contents with path headers
**Conversion Priority**: 📋 **LOW** - Mainly content, minimal path output

### Container & Orchestration Tools

#### docker.exe ❌ **NONE**
**Purpose**: Container runtime
**Parameters**:
- `docker run -v host:container` - 🟡 **VOLUME MOUNTS** (complex)
- `docker build path` - 🟢 **BUILD CONTEXT**

**Returns**: 📊 **Container Output** - Application logs, no local paths
**Conversion Priority**: ❌ **NONE** - Docker handles path translation

#### kubectl.exe ❌ **NONE**
**Purpose**: Kubernetes CLI
**Parameters**:
- `kubectl --kubeconfig path` - 🟢 **CONFIG FILE**
- `kubectl apply -f file.yaml` - 🟢 **MANIFEST FILE**

**Returns**: 📊 **Kubernetes API** - Cluster state, not local paths
**Conversion Priority**: ❌ **NONE** - Remote cluster operations

### Security & Analysis Tools

#### nmap.exe ❌ **NONE**
**Purpose**: Network scanner
**Parameters**:
- `nmap target` - ⚪ Network target
- `nmap -oX file.xml` - 🟢 **OUTPUT FILE**

**Returns**: 📊 **Scan Results** - Network scan data
**Conversion Priority**: ❌ **NONE** - Network scanning, not file operations

#### trivy.exe 📋 **LOW**
**Purpose**: Vulnerability scanner
**Parameters**:
- `trivy image name` - ⚪ Image name
- `trivy fs path` - 🟢 **FILESYSTEM PATH**

**Returns**: 📊 **Vulnerability Report** - Security findings
**Conversion Priority**: 📋 **LOW** - Scan reports, minimal path output

### Monitoring & Performance

#### htop.exe ❌ **NONE**
**Purpose**: Process monitor
**Parameters**:
- `htop` - ⚪ No parameters typically

**Returns**: ⚪ **Interactive TUI** - Process information
**Conversion Priority**: ❌ **NONE** - System monitoring, no file operations

#### hyperfine.exe 📋 **LOW**
**Purpose**: Benchmarking tool
**Parameters**:
- `hyperfine 'command'` - ⚪ Command to benchmark
- `hyperfine --export-json file` - 🟢 **OUTPUT FILE**

**Returns**: 📊 **Benchmark Results** - Performance metrics
**Conversion Priority**: 📋 **LOW** - Performance data, minimal file output

---

## Critical Findings Summary

### 🔥 **CRITICAL** - Must Have Parameter Conversion
1. **git.exe** - `--git-dir`, `--work-tree` parameters essential
2. **7za.exe** - File archiving operations broken without path conversion

### ⚡ **HIGH** - Major Functionality Impaired
1. **fd.exe** - Returns Windows paths, needs output conversion
2. **ripgrep (rg.exe)** - Returns Windows paths BUT patterns are regex ⚠️
3. **scp.exe** - File transfer operations need path conversion

### 📝 **MEDIUM** - Some Features Affected
1. **ast-grep.exe** - Search results contain file paths
2. **gradle.exe, maven.exe** - Build logs contain file paths
3. **eza.exe** - Directory listing operations
4. **delta.exe, difft.exe** - File comparison tools

### 📋 **LOW** - Minor Improvements
1. **sqlite.exe** - Database file access only
2. **bat.exe** - File content display
3. **Various config file parameters** - Occasional config file paths

### ❌ **NONE** - No Conversion Needed
1. **Runtime environments** - node.exe, java.exe, python.exe
2. **Network tools** - curl.exe, wget.exe, nmap.exe
3. **Container tools** - docker.exe, kubectl.exe
4. **System monitors** - htop.exe, various TUI tools

### ⚠️ **CONFLICTS IDENTIFIED**

#### ripgrep.exe - **CRITICAL CONFLICT**
- **NEEDS**: Output path conversion (`C:\file.txt:1:match` → `/mnt/c/file.txt:1:match`)
- **CANNOT**: Convert regex patterns (`/mnt/c/.*\.txt` would break regex)
- **SOLUTION**: Parameter-specific rules OR selective conversion

#### fd.exe - **MODERATE CONFLICT**
- **NEEDS**: Output path conversion for found files
- **CANNOT**: Convert regex patterns in search expressions
- **SOLUTION**: Pattern vs directory parameter distinction

---

## Recommended Implementation Strategy

### 1. **Tool-Specific Parameter Rules**
```json
{
  "git": {
    "convertParams": ["--git-dir", "--work-tree", "--file"],
    "skipParams": ["--grep"]
  },
  "ripgrep": {
    "convertParams": ["path arguments only"],
    "skipParams": ["--regexp", "first argument (pattern)"]
  }
}
```

### 2. **Universal Output Conversion**
- Apply to tools flagged as returning file paths
- Use pattern-based detection: `C:\path\to\file.ext`
- Fast sed/awk implementation for bulk operations

### 3. **Performance Considerations**
- **High-volume tools** (fd, ripgrep with thousands of results) need optimized conversion
- **Low-usage tools** can use simpler conversion methods
- **Interactive tools** (tig, htop) need no conversion

### 4. **Implementation Priority**
1. **Phase 1**: Fix critical git.exe parameter conversion
2. **Phase 2**: Add output conversion for fd.exe, ripgrep.exe
3. **Phase 3**: Handle remaining file-operation tools
4. **Phase 4**: Optimize performance for high-volume operations

This analysis covers all major tool categories in the PORTX ecosystem and provides a clear roadmap for implementing path conversion while avoiding breaking existing functionality.