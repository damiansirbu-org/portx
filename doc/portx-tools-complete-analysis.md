# PORTX Tools Complete Parameter and Return Type Analysis

## Executive Summary
**Total Packages Analyzed**: 220
**Total Executables Found**: 369

### Conversion Priority Breakdown
- **🔥 CRITICAL**: 1 tools
- **⚡ HIGH**: 12 tools
- **📝 MEDIUM**: 23 tools
- **📋 LOW**: 23 tools
- **❌ NONE**: 47 tools
- **🟡 REVIEW**: 263 tools

### Tool Category Distribution
- **Archive/Compression**: 6 tools
- **Build Tools**: 8 tools
- **Container/Orchestration**: 5 tools
- **Database Tools**: 9 tools
- **Development Runtime**: 17 tools
- **File Search**: 10 tools
- **Media/Graphics**: 2 tools
- **Network Tools**: 16 tools
- **Other/Utility**: 263 tools
- **Security/Analysis**: 6 tools
- **System/Monitoring**: 10 tools
- **Text Processing**: 6 tools
- **Version Control**: 11 tools

---

## 🔥 CRITICAL Priority Tools

### Version Control

#### git (git-extras)
**Purpose**: Git distributed version control system for tracking changes in source code
**Parameters**: 🟢 CRITICAL: --git-dir, --work-tree
**Returns**: 📁🔍 Mixed paths+content
**Conversion Priority**: 🔥 CRITICAL
**Usage Example**: `git init # Initialize repository\ngit add . # Stage all changes\ngit commit -m 'message' # Commit ch...`

## ⚡ HIGH Priority Tools

### Archive/Compression

#### 7za (7zip)
**Purpose**: LZMA2 compression archiver with AES-256 encryption and multithreading
**Parameters**: 🟢 File paths for archive ops
**Returns**: 📁 File Lists (Windows paths)
**Conversion Priority**: ⚡ HIGH
**Usage Example**: `7za a -t7z -mx=9 -mfb=64 -md=32m -ms=on backup.7z *.* # Maximum LZMA2 compression with 32MB dictiona...`

#### gzip (git-extras)
**Purpose**: GNU compression utility used by Git for efficient object storage and transfer
**Parameters**: 🟢 File paths for archive ops
**Returns**: 📁 File Lists (Windows paths)
**Conversion Priority**: ⚡ HIGH
**Usage Example**: `gzip file.txt # Compress file\ngzip -d file.txt.gz # Decompress file\n# Used internally by Git for o...`

#### pigz (pigz)
**Purpose**: Parallel gzip compression utility that utilizes multiple cores for faster compression
**Parameters**: 🟢 File paths for archive ops
**Returns**: 📁 File Lists (Windows paths)
**Conversion Priority**: ⚡ HIGH
**Usage Example**: `pigz file.txt # Compress file.txt to file.txt.gz...`

#### rarun2 (radare2)
**Purpose**: Process launcher and runtime environment controller for debugging and analysis
**Parameters**: 🟢 File paths for archive ops
**Returns**: 📁 File Lists (Windows paths)
**Conversion Priority**: ⚡ HIGH
**Usage Example**: `rarun2 program=target.exe\nrarun2 program=target.exe arg1=value\nrarun2 stdin=input.txt program=targ...`

#### tar (git-extras)
**Purpose**: Archive utility used by Git for creating and extracting compressed archives
**Parameters**: 🟢 File paths for archive ops
**Returns**: 📁 File Lists (Windows paths)
**Conversion Priority**: ⚡ HIGH
**Usage Example**: `tar -czf archive.tar.gz directory/ # Create compressed archive\ntar -xzf archive.tar.gz # Extract ar...`

#### uefi-extract (uefitools)
**Purpose**: Extract and analyze UEFI firmware images, modules, and components
**Parameters**: 🟢 File paths for archive ops
**Returns**: 📁 File Lists (Windows paths)
**Conversion Priority**: ⚡ HIGH
**Usage Example**: `UEFIExtract firmware.fd\nUEFIExtract -dump firmware.fd output/\nUEFIExtract -info firmware.fd\nUEFIE...`

### File Search

#### fd (fd)
**Purpose**: Intuitive find replacement with smart defaults, regex support, and parallel execution
**Parameters**: 🔴🟢 PATTERN+PATH mixed
**Returns**: 📁 File Paths (Windows)
**Conversion Priority**: ⚡ HIGH
**Usage Example**: `fd '^test.*\.rs$' src/ # Regex filename search\nfd -t f -x wc -l {} # Count lines in all files\nfd -...`

#### findlinks64 (sysinternals)
**Purpose**: Find all hard links to a file and display file link information on NTFS volumes
**Parameters**: 🔴🟢 PATTERN+PATH mixed
**Returns**: 📁 File Paths (Windows)
**Conversion Priority**: ⚡ HIGH
**Usage Example**: `FindLinks64 file.txt # Find all hard links to file\nFindLinks64 -v /path # Verbose output for path\n...`

#### rafind2 (radare2)
**Purpose**: Advanced search tool for finding patterns, strings, and bytes in binary files
**Parameters**: 🔴🟢 PATTERN+PATH mixed
**Returns**: 📁 File Paths (Windows)
**Conversion Priority**: ⚡ HIGH
**Usage Example**: `rafind2 -s 'string' file.bin\nrafind2 -x 4142434445 file.bin\nrafind2 -e /regex/i file.bin\nrafind2 ...`

#### rg (ripgrep)
**Purpose**: Rust-powered search that respects .gitignore while delivering grep-impossible speeds
**Parameters**: 🔴⚡ PATTERN+PATH conflict
**Returns**: 🔍 Search Results (Windows paths)
**Conversion Priority**: ⚡ HIGH
**Usage Example**: `rg 'TODO|FIXME|XXX' --type rust\nrg -C3 'panic!' --type rust\nrg --files-with-matches 'deprecated' |...`

#### rgr (repgrep)
**Purpose**: Interactive grep-and-replace tool using ripgrep - provides live preview of search and replace operations with confirmation
**Parameters**: 🔴⚡ PATTERN+PATH conflict
**Returns**: 🔍 Search Results (Windows paths)
**Conversion Priority**: ⚡ HIGH
**Usage Example**: `rgr 'pattern' 'replacement'\nrgr -t py 'old_function' 'new_function'\nrgr --no-confirm 'bug' 'fix'...`

### Network Tools

#### scp (git-extras)
**Purpose**: Secure Copy Protocol for encrypted file transfers over SSH
**Parameters**: 🟢 File transfer paths
**Returns**: 📄 Transfer status
**Conversion Priority**: ⚡ HIGH
**Usage Example**: `scp file.txt user@server:/path/ # Copy file to remote\nscp user@server:/path/file.txt . # Copy from ...`

## 📝 MEDIUM Priority Tools

### Build Tools

#### bazel (bazel)
**Purpose**: Extensible build system supporting multiple languages with hermetic builds, remote execution, and incremental compilation
**Parameters**: 🟢 Project/build file paths
**Returns**: 📊 Build logs (contain file paths)
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `bazel build //... # Build all targets\nbazel test //... # Run all tests\nbazel run //main:hello # Ru...`

#### gradle (gradle)
**Purpose**: Gradle build automation tool with dependency management, multi-project builds, and incremental compilation
**Parameters**: 🟢 Project/build file paths
**Returns**: 📊 Build logs (contain file paths)
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `gradle build | gradle dependencies | gradle clean test | gradle assemble --parallel...`

#### make_f2fs (android-filesystem-tools)
**Purpose**: F2FS formatter with encryption and zoned block device support
**Parameters**: 🟢 Project/build file paths
**Returns**: 📊 Build logs (contain file paths)
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `make_f2fs -f -l system /dev/sdX # Format with label and force\nmake_f2fs -O encrypt -C utf8:strict /...`

#### mvn (maven)
**Purpose**: Maven build automation tool for Java projects with dependency management, compilation, testing, and deployment
**Parameters**: 🟢 Project/build file paths
**Returns**: 📊 Build logs (contain file paths)
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `mvn clean install | mvn dependency:tree | mvn compile test | mvn package -DskipTests...`

#### mvnDebug (maven)
**Purpose**: Maven with debug mode enabled for troubleshooting builds and plugin development
**Parameters**: 🟢 Project/build file paths
**Returns**: 📊 Build logs (contain file paths)
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `mvnDebug clean compile | mvnDebug test | mvnDebug -X clean install...`

#### ninja (ninja)
**Purpose**: Small build system with focus on speed - designed to be generated by higher-level build systems like CMake and Meson
**Parameters**: 🟢 Project/build file paths
**Returns**: 📊 Build logs (contain file paths)
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `ninja # Build all targets\nninja -j 4 # Build with 4 parallel jobs\nninja -t clean # Clean all build...`

#### premake (premake)
**Purpose**: Build script generator supporting Visual Studio, Xcode, makefiles, and more from Lua configuration scripts
**Parameters**: 🟢 Project/build file paths
**Returns**: 📊 Build logs (contain file paths)
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `premake5 vs2022 # Generate Visual Studio 2022 solution...`

#### tiny-libmaker (tinycc)
**Purpose**: Create static library archives (.lib) from object files for TinyCC
**Parameters**: 🟢 Project/build file paths
**Returns**: 📊 Build logs (contain file paths)
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `tiny_libmaker library.lib object1.o object2.o\ntiny_libmaker mylib.lib *.o\ntiny_libmaker -v library...`

### File Search

#### ast-grep (ast-grep)
**Purpose**: Tree-sitter powered structural code search with pattern matching
**Parameters**: 🟢 Search paths only
**Returns**: 🔍 Search Results
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `ast-grep --pattern 'console.log($$$)' src/ # Find all console.log calls\nast-grep --pattern 'functio...`

#### bandwhich (bandwhich)
**Purpose**: Real-time network monitor with process-level bandwidth tracking
**Parameters**: 🟢 Search paths only
**Returns**: 🔍 Search Results
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `bandwhich # Monitor all network interfaces with process details\nbandwhich -i Wi-Fi # Monitor specif...`

#### semgrep (semgrep)
**Purpose**: Lightweight static analysis tool with pattern-based scanning for security vulnerabilities and code quality issues
**Parameters**: 🟢 Search paths only
**Returns**: 🔍 Search Results
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `semgrep --help...`

#### subfinder (subfinder)
**Purpose**: Passive subdomain discovery tool using multiple online sources
**Parameters**: 🟢 Search paths only
**Returns**: 🔍 Search Results
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `subfinder -d example.com\nsubfinder -dL domains.txt\nsubfinder -d example.com -o results.txt\nsubfin...`

#### uefi-find (uefitools)
**Purpose**: Search for patterns, strings, and signatures within UEFI firmware images
**Parameters**: 🟢 Search paths only
**Returns**: 🔍 Search Results
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `UEFIFind firmware.fd text 'string_to_find'\nUEFIFind firmware.fd hex '48656C6C6F'\nUEFIFind firmware...`

### Version Control

#### git-cliff (git-cliff)
**Purpose**: Smart changelog generator from git history using conventional commits with templating support
**Parameters**: 🟢 Repository paths
**Returns**: 📁 File paths
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `git-cliff\ngit-cliff --tag v1.0.0\ngit-cliff --latest\ngit-cliff --config cliff.toml...`

#### git-credential-wincred (git-extras)
**Purpose**: Windows Credential Manager integration for Git authentication
**Parameters**: 🟢 Repository paths
**Returns**: 📁 File paths
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `git config --global credential.helper wincred # Enable Windows credential storage\n# Automatically s...`

#### git-lfs (git-extras)
**Purpose**: Git Large File Storage extension for versioning large binary files efficiently
**Parameters**: 🟢 Repository paths
**Returns**: 📁 File paths
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `git lfs install # Initialize LFS in repository\ngit lfs track '*.psd' '*.zip' # Track large file typ...`

#### git-remote-http (git-extras)
**Purpose**: Git HTTP/HTTPS protocol handler for remote repository access
**Parameters**: 🟢 Repository paths
**Returns**: 📁 File paths
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `# Used internally by Git for HTTP remote operations\ngit clone https://github.com/user/repo.git # Cl...`

#### git-remote-https (git-extras)
**Purpose**: Git HTTPS protocol handler with SSL/TLS support for secure remote access
**Parameters**: 🟢 Repository paths
**Returns**: 📁 File paths
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `# Used internally by Git for HTTPS remote operations\n# Provides secure transport layer for Git oper...`

#### gitleaks (gitleaks)
**Purpose**: SAST tool for detecting hardcoded secrets like passwords, api keys, and tokens in git repositories
**Parameters**: 🟢 Repository paths
**Returns**: 📁 File paths
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `gitleaks detect\ngitleaks detect --source .\ngitleaks detect --verbose\ngitleaks protect --staged...`

#### gitstatusd (git-extras)
**Purpose**: High-performance git status daemon for responsive terminal prompts
**Parameters**: 🟢 Repository paths
**Returns**: 📁 File paths
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `gitstatusd # Run status daemon\nexport GITSTATUS_DAEMON=$PWD/gitstatusd.exe # Set daemon path\n# Use...`

#### gitui (gitui)
**Purpose**: Blazing fast terminal UI for Git with keyboard-driven workflow
**Parameters**: 🟢 Repository paths
**Returns**: 📁 File paths
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `gitui # Launch Git TUI\nTab - Switch between panels\nc - Commit changes\nf - Fetch from remote\np - ...`

#### lazygit (lazygit)
**Purpose**: Terminal UI for Git commands with intuitive keyboard shortcuts
**Parameters**: 🟢 Repository paths
**Returns**: 📁 File paths
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `lazygit # Launch Git TUI\nSpace - Stage/unstage files, c - Commit\na - Stage all changes, p - Pull f...`

#### ravc2 (radare2)
**Purpose**: Version control system for radare2 projects and analysis session management
**Parameters**: 🟢 Repository paths
**Returns**: 📁 File paths
**Conversion Priority**: 📝 MEDIUM
**Usage Example**: `ravc2 init project_name\nravc2 save checkpoint1\nravc2 load checkpoint1\nravc2 diff checkpoint1 chec...`

## 📋 LOW Priority Tools

### Database Tools

#### adb (adb)
**Purpose**: Android Debug Bridge for device management and wireless debugging
**Parameters**: 🟢 DB file/script paths
**Returns**: 📊 Database results
**Conversion Priority**: 📋 LOW
**Usage Example**: `adb devices -l # List connected devices with detailed transport info...`

#### adb (scrcpy)
**Purpose**: Android Debug Bridge for device communication and debugging
**Parameters**: 🟢 DB file/script paths
**Returns**: 📊 Database results
**Conversion Priority**: 📋 LOW
**Usage Example**: `adb devices\nadb shell\nadb install app.apk\nadb pull /sdcard/file.txt .\nadb push file.txt /sdcard/...`

#### dblab (dblab)
**Purpose**: Modern database client TUI supporting PostgreSQL, MySQL, Oracle with SSH tunneling, SSL, and advanced query features
**Parameters**: 🟢 DB file/script paths
**Returns**: 📊 Database results
**Conversion Priority**: 📋 LOW
**Usage Example**: `dblab --url 'postgres://user:pass@host:port/db' # Connect to PostgreSQL\ndblab --driver mysql --host...`

#### duckdb (duckdb)
**Purpose**: Fast analytical SQL database with rich SQL syntax - single dependency-free executable for CSV/JSON/Parquet analysis
**Parameters**: 🟢 DB file/script paths
**Returns**: 📊 Database results
**Conversion Priority**: 📋 LOW
**Usage Example**: `duckdb\nduckdb database.db\nduckdb :memory: -c "SELECT * FROM 'data.csv'"\nduckdb -c "SELECT COUNT(*...`

#### lazysql (lazysql)
**Purpose**: Interactive terminal UI for browsing and querying SQL databases with vim-like navigation
**Parameters**: 🟢 DB file/script paths
**Returns**: 📊 Database results
**Conversion Priority**: 📋 LOW
**Usage Example**: `lazysql # Connect to database interactively\nlazysql -host localhost -port 5432 -user postgres -dbna...`

#### sqldiff (sqlite)
**Purpose**: Compare and display differences between two SQLite database files
**Parameters**: 🟢 DB file/script paths
**Returns**: 📊 Database results
**Conversion Priority**: 📋 LOW
**Usage Example**: `sqldiff database1.db database2.db\nsqldiff --summary db1.db db2.db\nsqldiff --changeset changes.db d...`

#### sqlite3 (sqlite)
**Purpose**: SQLite command-line shell for database operations and queries
**Parameters**: 🟢 DB file/script paths
**Returns**: 📊 Database results
**Conversion Priority**: 📋 LOW
**Usage Example**: `sqlite3 database.db\nsqlite3 -header -csv database.db 'SELECT * FROM users;'\nsqlite3 database.db < ...`

#### sqlite3-analyzer (sqlite)
**Purpose**: Analyze SQLite database structure and provide detailed storage statistics
**Parameters**: 🟢 DB file/script paths
**Returns**: 📊 Database results
**Conversion Priority**: 📋 LOW
**Usage Example**: `sqlite3_analyzer database.db\nsqlite3_analyzer database.db > report.txt\nsqlite3_analyzer --help...`

#### usql (usql)
**Purpose**: Universal SQL client supporting PostgreSQL, MySQL, SQLite, Oracle, SQL Server and many others
**Parameters**: 🟢 DB file/script paths
**Returns**: 📊 Database results
**Conversion Priority**: 📋 LOW
**Usage Example**: `usql postgres://user:pass@host/db\nusql mysql://user:pass@host/db\nusql sqlite:database.db\nusql 'SE...`

### Media/Graphics

#### convert (path-utils)
**Purpose**: Path format converter between Windows and UNIX-style paths
**Parameters**: 🟢 Input/output file paths
**Returns**: 📄 Media content
**Conversion Priority**: 📋 LOW
**Usage Example**: `convert -w /c/path\nconvert -u 'C:\\path'...`

#### mediainfo (mediainfo)
**Purpose**: Extract detailed technical and metadata information from video, audio, and image files
**Parameters**: 🟢 Input/output file paths
**Returns**: 📄 Media content
**Conversion Priority**: 📋 LOW
**Usage Example**: `mediainfo video.mp4\nmediainfo --Output=JSON video.mp4\nmediainfo --Output=XML audio.mp3\nmediainfo ...`

### Security/Analysis

#### hashdeep (hashdeep)
**Purpose**: Recursive file hashing tool for digital forensics and integrity verification
**Parameters**: 🟢 Target file/dir paths
**Returns**: 📊 Scan results
**Conversion Priority**: 📋 LOW
**Usage Example**: `hashdeep -r /path/to/investigate # Recursive hashing\nhashdeep -c baseline.txt # Compare against bas...`

#### osv-scanner (osv-scanner)
**Purpose**: Comprehensive vulnerability scanner for open source dependencies with guided remediation and container image scanning
**Parameters**: 🟢 Target file/dir paths
**Returns**: 📊 Scan results
**Conversion Priority**: 📋 LOW
**Usage Example**: `osv-scanner --help...`

#### rahash2 (radare2)
**Purpose**: Cryptographic hash calculator supporting multiple algorithms for file integrity verification
**Parameters**: 🟢 Target file/dir paths
**Returns**: 📊 Scan results
**Conversion Priority**: 📋 LOW
**Usage Example**: `rahash2 file.exe\nrahash2 -a md5 file.exe\nrahash2 -a sha256 file.exe\nrahash2 -c hash_to_verify fil...`

#### rustscan (rustscan)
**Purpose**: Ultra-fast port scanner with Nmap integration for network discovery
**Parameters**: 🟢 Target file/dir paths
**Returns**: 📊 Scan results
**Conversion Priority**: 📋 LOW
**Usage Example**: `rustscan -a 192.168.1.1\nrustscan -p 80,443,22 192.168.1.1\nrustscan --ulimit 5000 192.168.1.0/24\nr...`

#### sonar-scanner (sonar-scanner)
**Purpose**: Multi-language static code analyzer that detects bugs, vulnerabilities, and code smells for SonarQube/SonarCloud integration
**Parameters**: 🟢 Target file/dir paths
**Returns**: 📊 Scan results
**Conversion Priority**: 📋 LOW
**Usage Example**: `sonar-scanner -Dsonar.projectKey=myproject -Dsonar.sources=src...`

#### terrascan (terrascan)
**Purpose**: Comprehensive IaC security scanner for detecting misconfigurations, compliance violations, and security risks before cloud provisioning
**Parameters**: 🟢 Target file/dir paths
**Returns**: 📊 Scan results
**Conversion Priority**: 📋 LOW
**Usage Example**: `terrascan scan -t terraform -d /path/to/terraform...`

### Text Processing

#### bat (bat)
**Purpose**: Enhanced cat with syntax highlighting and Git change markers
**Parameters**: 🟢 Input file paths
**Returns**: 📄 File content
**Conversion Priority**: 📋 LOW
**Usage Example**: `bat main.py # Syntax highlighted file display\nbat -n file.js # Show line numbers only\nbat -A confi...`

#### bats (bats)
**Purpose**: Run BATS test suites with comprehensive reporting and TAP output
**Parameters**: 🟢 Input file paths
**Returns**: 📄 File content
**Conversion Priority**: 📋 LOW
**Usage Example**: `bats test.bats # Run single test file\nbats test/ # Run all tests in directory\nbats --tap test.bats...`

#### less (nushell)
**Purpose**: Less pager included with Nushell distribution
**Parameters**: 🟢 Input file paths
**Returns**: 📄 File content
**Conversion Priority**: 📋 LOW

#### mdcat (mdcat)
**Purpose**: Cat for markdown - display markdown files in terminal with syntax highlighting, tables, and images
**Parameters**: 🟢 Input file paths
**Returns**: 📄 File content
**Conversion Priority**: 📋 LOW
**Usage Example**: `mdcat README.md\nmdcat --help\nmdcat --local file.md\ncat file.md | mdcat...`

#### ncat (nmap)
**Purpose**: Nmap's network Swiss Army knife for connectivity and data transfer
**Parameters**: 🟢 Input file paths
**Returns**: 📄 File content
**Conversion Priority**: 📋 LOW
**Usage Example**: `ncat -l 8080\nncat example.com 80\nncat --broker --listen 8080\nncat --ssl example.com 443\necho 'GE...`

#### socat (socat)
**Purpose**: Netcat on steroids - establishes two bidirectional byte streams and transfers data between them with support for files, pipes, devices, sockets, SSL, proxy connections
**Parameters**: 🟢 Input file paths
**Returns**: 📄 File content
**Conversion Priority**: 📋 LOW
**Usage Example**: `socat TCP4-LISTEN:80,fork TCP4:192.168.1.10:80\nsocat - TCP4:www.example.com:80\nsocat TCP4-LISTEN:8...`

## ❌ NONE Priority Tools

### Container/Orchestration

#### docker-compose (docker-compose)
**Purpose**: YAML-based multi-container orchestration with networking and volumes
**Parameters**: 🟢 Config/volume paths only
**Returns**: 📊 Container output
**Conversion Priority**: ❌ NONE
**Usage Example**: `docker-compose up -d --build # Build and run in background\ndocker-compose logs -f webapp # Follow s...`

#### helm (helm)
**Purpose**: Kubernetes package manager with templating, versioning, and application lifecycle management
**Parameters**: 🟢 Config/volume paths only
**Returns**: 📊 Container output
**Conversion Priority**: ❌ NONE
**Usage Example**: `helm upgrade --install myapp ./chart --wait --timeout=300s # Deploy with rollback safety\nhelm rollb...`

#### helmfile (helmfile)
**Purpose**: Declarative Helm chart deployment tool with environment management
**Parameters**: 🟢 Config/volume paths only
**Returns**: 📊 Container output
**Conversion Priority**: ❌ NONE
**Usage Example**: `helmfile apply # Deploy all charts\nhelmfile -e production apply # Deploy to specific environment\nh...`

#### kubectl (k8)
**Purpose**: Kubernetes CLI for cluster management and application deployment
**Parameters**: 🟢 Config/volume paths only
**Returns**: 📊 Container output
**Conversion Priority**: ❌ NONE
**Usage Example**: `kubectl get pods -A # List all pods\nkubectl apply -f deployment.yaml # Apply configuration\nkubectl...`

#### lazydocker (lazydocker)
**Purpose**: Terminal UI for Docker and Docker Compose with mouse support
**Parameters**: 🟢 Config/volume paths only
**Returns**: 📊 Container output
**Conversion Priority**: ❌ NONE
**Usage Example**: `lazydocker # Launch Docker TUI\nm - View container logs, e - Execute command in container\nx - Remov...`

### Development Runtime

#### go (go)
**Purpose**: Go programming language compiler and build tool with modules support
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `go mod init myproject # Initialize new Go module...`

#### gofmt (go)
**Purpose**: Go source code formatter with automatic code style enforcement
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `gofmt -w *.go # Format and write back Go files...`

#### gojq (gojq)
**Purpose**: Pure Go jq implementation with enhanced Unicode support, arbitrary-precision arithmetic, and YAML input/output - maintains precision for large integers unlike standard jq
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `gojq '.users[] | select(.age > 21)' data.json\necho '{"large": 12345678901234567890}' | gojq '.large...`

#### gosec (gosec)
**Purpose**: Go security checker that scans Go AST and SSA for security vulnerabilities - static analysis security testing tool
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `gosec ./...\ngosec -fmt json -out results.json ./...\ngosec -exclude G104 ./...\ngosec -include G401...`

#### java (java)
**Purpose**: Java runtime environment for executing Java applications and JAR files
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `java -version | java -jar app.jar | java MyClass...`

#### javac (java)
**Purpose**: Java compiler for compiling Java source files to bytecode
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `javac MyClass.java | javac -cp lib/*.jar src/*.java | javac -d build src/*.java...`

#### javadoc (java)
**Purpose**: Java documentation generator for creating API documentation from source code
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `javadoc *.java | javadoc -d docs -sourcepath src com.example | javadoc -classpath lib/*.jar *.java...`

#### javap (java)
**Purpose**: Java class file disassembler for analyzing bytecode and class structure
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `javap MyClass | javap -c -verbose MyClass.class | javap -classpath lib MyClass...`

#### javaw (java)
**Purpose**: Java runtime environment for GUI applications (runs without console window)
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `javaw -jar gui-app.jar | javaw MyGUIClass | javaw -version...`

#### logonsessions64 (sysinternals)
**Purpose**: Display active logon sessions and associated processes on the local system
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `LogonSessions64 # Show all logon sessions\nLogonSessions64 -p # Include process information\nLogonSe...`

#### node (node)
**Purpose**: Node.js JavaScript runtime engine for server-side and command-line applications
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `node app.js # Run JavaScript application...`

#### npm (node)
**Purpose**: Node Package Manager for installing and managing JavaScript packages
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `npm install express # Install package locally...`

#### pipelist64 (sysinternals)
**Purpose**: Display named pipes on the system and processes that have them open
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `pipelist64 # List all named pipes\npipelist64 -v # Verbose pipe information\npipelist64 pipe_name # ...`

#### pnpm (pnpm)
**Purpose**: Performant npm alternative with content-addressable storage and strict dependency isolation
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `pnpm install\npnpm add package-name\npnpm run build\npnpm create vite my-app\npnpm store prune...`

#### python (python-runtime)
**Purpose**: Python 3.12.8 interpreter with standard library for running scripts and hooks
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `python script.py\npython -c "print('Hello World')"\npython -m json.tool file.json\npython --version\...`

#### pythonw (python-runtime)
**Purpose**: Python 3.12.8 interpreter without console window for GUI applications
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `pythonw gui_script.py\npythonw -c "import tkinter; tkinter.Tk().mainloop()"...`

#### yarn (yarn)
**Purpose**: JavaScript package manager with improved performance and security
**Parameters**: 🟢 Script/source paths only
**Returns**: 📄 Program output
**Conversion Priority**: ❌ NONE
**Usage Example**: `yarn add <package>\nyarn install\nyarn add express\nyarn add --dev webpack\nyarn remove lodash\nyarn...`

### Network Tools

#### curlie (curlie)
**Purpose**: Modern curl frontend combining curl's power with HTTPie's ease of use - supports all curl features with syntax highlighting and intuitive header syntax
**Parameters**: 🟢 Config/output files only
**Returns**: 📄 Network content
**Conversion Priority**: ❌ NONE
**Usage Example**: `curlie GET httpbin.org/json # Simple GET request...`

#### gping (gping)
**Purpose**: Ping with a graph - visual network latency monitor with real-time charts
**Parameters**: 🟢 Config/output files only
**Returns**: 📄 Network content
**Conversion Priority**: ❌ NONE
**Usage Example**: `gping google.com # Ping with graph\ngping 8.8.8.8 1.1.1.1 # Compare multiple hosts\ngping --simple-g...`

#### httpx (httpx)
**Purpose**: Fast HTTP toolkit for web reconnaissance and security testing
**Parameters**: 🟢 Config/output files only
**Returns**: 📄 Network content
**Conversion Priority**: ❌ NONE
**Usage Example**: `httpx -l domains.txt # Probe HTTP services\nhttpx -sc -title -tech-detect -l hosts.txt # Full reconn...`

#### nmap (nmap)
**Purpose**: Network reconnaissance engine with NSE scripts for deep service enumeration and OS fingerprinting
**Parameters**: 🟢 Config/output files only
**Returns**: 📄 Network content
**Conversion Priority**: ❌ NONE
**Usage Example**: `nmap -sS -O target.com\nnmap --script vuln target.com\nnmap -sV --script discovery target.com\nnmap ...`

#### nping (nmap)
**Purpose**: Advanced ping utility with custom packet crafting and network troubleshooting capabilities
**Parameters**: 🟢 Config/output files only
**Returns**: 📄 Network content
**Conversion Priority**: ❌ NONE
**Usage Example**: `nping --tcp -p 80 target.com\nnping --udp -p 53 dns-server.com\nnping --icmp target.com\nnping --arp...`

#### psping64 (sysinternals)
**Purpose**: Enhanced ping utility with TCP ping, latency testing, and bandwidth measurement capabilities
**Parameters**: 🟢 Config/output files only
**Returns**: 📄 Network content
**Conversion Priority**: ❌ NONE
**Usage Example**: `psping64 hostname # ICMP ping\npsping64 -t hostname:80 # TCP ping to port\npsping64 -l 1024 -n 100 h...`

#### sqlite3-rsync (sqlite)
**Purpose**: Synchronize SQLite databases over network connections with incremental updates
**Parameters**: 🟢 Config/output files only
**Returns**: 📄 Network content
**Conversion Priority**: ❌ NONE
**Usage Example**: `sqlite3_rsync client.db server_url\nsqlite3_rsync --server database.db\nsqlite3_rsync --download rem...`

#### ssh (git-extras)
**Purpose**: OpenSSH client for secure shell connections and Git SSH transport
**Parameters**: 🟢 Config/output files only
**Returns**: 📄 Network content
**Conversion Priority**: ❌ NONE
**Usage Example**: `ssh user@server # Connect to remote server\nssh -i ~/.ssh/id_rsa user@server # Use specific key\nssh...`

#### ssh-add (git-extras)
**Purpose**: SSH authentication agent for managing private keys in memory
**Parameters**: 🟢 Config/output files only
**Returns**: 📄 Network content
**Conversion Priority**: ❌ NONE
**Usage Example**: `ssh-add ~/.ssh/id_rsa # Add private key to agent\nssh-add -l # List loaded keys\nssh-add -D # Remove...`

#### ssh-agent (git-extras)
**Purpose**: SSH authentication agent daemon for secure key management
**Parameters**: 🟢 Config/output files only
**Returns**: 📄 Network content
**Conversion Priority**: ❌ NONE
**Usage Example**: `eval $(ssh-agent -s) # Start SSH agent\nssh-agent -k # Kill SSH agent\n# Runs in background to manag...`

#### ssh-keygen (git-extras)
**Purpose**: SSH key generation utility for creating authentication key pairs
**Parameters**: 🟢 Config/output files only
**Returns**: 📄 Network content
**Conversion Priority**: ❌ NONE
**Usage Example**: `ssh-keygen -t rsa -b 4096 -C 'email@example.com' # Generate RSA key\nssh-keygen -t ed25519 -C 'email...`

#### ssh-keyscan (git-extras)
**Purpose**: SSH host key scanner for collecting and verifying server fingerprints
**Parameters**: 🟢 Config/output files only
**Returns**: 📄 Network content
**Conversion Priority**: ❌ NONE
**Usage Example**: `ssh-keyscan github.com >> ~/.ssh/known_hosts # Add GitHub host key\nssh-keyscan -H github.com # Hash...`

#### ssh-pageant (git-extras)
**Purpose**: Bridge between OpenSSH and PuTTY Pageant for Windows SSH key management
**Parameters**: 🟢 Config/output files only
**Returns**: 📄 Network content
**Conversion Priority**: ❌ NONE
**Usage Example**: `ssh-pageant # Start pageant bridge\n# Allows OpenSSH to use PuTTY Pageant keys\n# Enables single sig...`

#### wget (wget)
**Purpose**: Network downloader for retrieving files from web servers using HTTP, HTTPS, and FTP
**Parameters**: 🟢 Config/output files only
**Returns**: 📄 Network content
**Conversion Priority**: ❌ NONE
**Usage Example**: `wget https://example.com/file.zip\nwget -r -np -k https://site.com/\nwget --user=username --password...`

#### win-sshproxy (podman)
**Purpose**: SSH proxy helper for Windows Podman machine communication and tunneling
**Parameters**: 🟢 Config/output files only
**Returns**: 📄 Network content
**Conversion Priority**: ❌ NONE
**Usage Example**: `win-sshproxy -logfile proxy.log\nwin-sshproxy -debug -remote-host podman-machine...`

### System/Monitoring

#### btop (btop)
**Purpose**: Interactive resource monitor with mouse support and colorful interface
**Parameters**: ⚪ System targets only
**Returns**: ⚪ System info
**Conversion Priority**: ❌ NONE
**Usage Example**: `btop # Launch full-featured system monitor...`

#### ctop (ctop)
**Purpose**: Container metrics dashboard with real-time monitoring - provides a concise overview of metrics for multiple containers
**Parameters**: ⚪ System targets only
**Returns**: ⚪ System info
**Conversion Priority**: ❌ NONE
**Usage Example**: `ctop\nctop -a\nctop -scale-cpu\nctop -sortField=cpu...`

#### officetopdf (officetopdf)
**Purpose**: Convert Word, Excel, PowerPoint documents to PDF using Microsoft Office automation
**Parameters**: ⚪ System targets only
**Returns**: ⚪ System info
**Conversion Priority**: ❌ NONE
**Usage Example**: `OfficeToPDF.exe document.docx output.pdf\nOfficeToPDF.exe spreadsheet.xlsx report.pdf\nOfficeToPDF.e...`

#### psexec64 (sysinternals)
**Purpose**: Execute processes remotely and locally with different user credentials and system privileges
**Parameters**: ⚪ System targets only
**Returns**: ⚪ System info
**Conversion Priority**: ❌ NONE
**Usage Example**: `PsExec64 \\remote-pc cmd # Run command on remote system\nPsExec64 -s cmd # Run as SYSTEM account\nPs...`

#### psfile64 (sysinternals)
**Purpose**: Display files opened remotely via file shares and optionally close them
**Parameters**: ⚪ System targets only
**Returns**: ⚪ System info
**Conversion Priority**: ❌ NONE
**Usage Example**: `psfile64 # Show all remote file opens\npsfile64 \\remote-pc # Files on specific system\npsfile64 -c ...`

#### psgetsid64 (sysinternals)
**Purpose**: Display Security Identifier (SID) for user accounts on local or remote systems
**Parameters**: ⚪ System targets only
**Returns**: ⚪ System info
**Conversion Priority**: ❌ NONE
**Usage Example**: `PsGetsid64 username # Get SID for user\nPsGetsid64 \\remote-pc username # Remote user SID\nPsGetsid6...`

#### psinfo64 (sysinternals)
**Purpose**: Display system information including hardware, OS version, and installed software
**Parameters**: ⚪ System targets only
**Returns**: ⚪ System info
**Conversion Priority**: ❌ NONE
**Usage Example**: `psinfo64 # Local system info\npsinfo64 \\remote-pc # Remote system info\npsinfo64 -h # Hardware deta...`

#### pskill64 (sysinternals)
**Purpose**: Kill processes by name or process ID on local or remote systems
**Parameters**: ⚪ System targets only
**Returns**: ⚪ System info
**Conversion Priority**: ❌ NONE
**Usage Example**: `pskill64 notepad # Kill by process name\npskill64 1234 # Kill by PID\npskill64 \\remote-pc notepad #...`

#### pslist64 (sysinternals)
**Purpose**: Display detailed information about running processes including CPU usage and memory statistics
**Parameters**: ⚪ System targets only
**Returns**: ⚪ System info
**Conversion Priority**: ❌ NONE
**Usage Example**: `PsList64 # List all processes\nPsList64 -m # Include memory usage\nPsList64 -t # Show process tree\n...`

#### psloggedon64 (sysinternals)
**Purpose**: Display locally and remotely logged on users with logon times and session information
**Parameters**: ⚪ System targets only
**Returns**: ⚪ System info
**Conversion Priority**: ❌ NONE
**Usage Example**: `PsLoggedon64 # Show local logons\nPsLoggedon64 \\remote-pc # Remote system logons\nPsLoggedon64 -l #...`

## 🟡 REVIEW Priority Tools

### Other/Utility

#### accesschk64 (sysinternals)
**Purpose**: Display access permissions for files, registry keys, and Windows services
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `accesschk64 -s /path # Show access for path\naccesschk64 -q -u user service # Check service access\n...`

#### act (act)
**Purpose**: Local GitHub Actions runner - run workflows and actions locally for faster development and testing
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `act\nact -l\nact -j test\nact push\nact --secret-file .secrets...`

#### adrestore64 (sysinternals)
**Purpose**: Restore deleted Active Directory objects from tombstone state
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `adrestore64 -r "CN=DeletedUser,CN=Deleted Objects,DC=domain,DC=com" # Restore deleted user\nadrestor...`

#### ag (ag)
**Purpose**: Ultra-fast code search with .gitignore filtering and PCRE regex
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `ag 'TODO|FIXME' --color --group # Search for todos with colored grouped output...`

#### age-keygen (age)
**Purpose**: X25519 keypair generator with secure defaults and SSH integration
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `age-keygen -o key.txt # Generate new X25519 keypair\nage-keygen -y key.txt # Extract public key from...`

#### analyze-code (analyze-code)
**Purpose**: Main code analysis tool that executes inspect and verify analyzers on source files
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `analyze-code <file_path> [inspect|verify|both] - Analyze source files with configurable analyzer mod...`

#### aria2c (aria2)
**Purpose**: Ultra fast download utility with support for HTTP/HTTPS, FTP, SFTP, BitTorrent, and Metalink - supports multi-connection downloads and resuming
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `aria2c https://example.com/file.zip\naria2c -x 16 -s 16 https://example.com/largefile.zip\naria2c fi...`

#### atac (atac)
**Purpose**: TUI API client (Postman alternative) with async requests, authentication, and collection management
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `atac\natac --help\natac --version\natac --directory my-collection...`

#### autorunsc64 (sysinternals)
**Purpose**: Command-line version of Autoruns showing programs configured to run during startup
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `autorunsc64 -a # Show all autorun entries\nautorunsc64 -m # Show only Microsoft entries\nautorunsc64...`

#### aws (aws)
**Purpose**: AWS CLI v2 with improved JSON handling and SSO authentication
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `aws configure sso # Setup SSO authentication\naws s3 sync ./local s3://bucket/path --delete # Sync w...`

#### basename (path-utils)
**Purpose**: Extract filename component from file path by removing directory prefix
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `basename /path/to/file.txt\nbasename /path/to/file.txt .txt\nbasename $(pwd)...`

#### binsider (binsider)
**Purpose**: Analyze ELF binaries and executables with comprehensive TUI interface featuring static analysis, dynamic analysis, strings extraction, and hexdump
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `binsider binary.exe # Analyze executable\nbinsider --tab strings binary.exe # Start with strings tab...`

#### binskim (binskim)
**Purpose**: PE/MSIL security analyzer with comprehensive vulnerability detection
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `BinSkim analyze app.exe --output results.sarif # Analyze single binary to SARIF\nBinSkim analyze *.d...`

#### broot (broot)
**Purpose**: Navigate directories with tree view, fuzzy search, and file operations - better way to explore filesystem
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `broot\nbroot --help\nbroot -s (show sizes)\nbroot -g (show git status)\nbroot -h (show hidden files)...`

#### btm (bottom)
**Purpose**: System monitor with CPU, memory, network, and temperature monitoring - htop alternative
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `btm\nbtm --help\nbtm --basic\nbtm --battery\nbtm --expanded...`

#### bun (bun)
**Purpose**: All-in-one JavaScript toolkit with native performance and Zig implementation
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `bun install # Ultra-fast package installation with global cache...`

#### capinfos (wireshark-cli)
**Purpose**: Print information about capture files
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `capinfos capture.pcap\ncapinfos -t -c -s *.pcap\ncapinfos -T capture.pcap...`

#### capture2text (capture2text)
**Purpose**: GUI OCR tool with hotkey screen capture and multi-language support
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `Capture2Text.exe # Launch OCR GUI with hotkey configuration...`

#### capture2text-cli (capture2text)
**Purpose**: Command-line OCR for batch text extraction from images
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `Capture2Text_CLI.exe -i image.png -o text.txt # Extract text to file...`

#### chdig (chdig)
**Purpose**: Comprehensive TUI interface for ClickHouse database administration and monitoring with real-time insights
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `chdig queries # Show running queries\nchdig --url clickhouse://localhost:8123 slow-queries # Monitor...`

#### chkfont (figlet)
**Purpose**: Check and validate FIGlet font files for compatibility and correctness
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `chkfont fonts/standard.flf\nchkfont fonts/*.flf...`

#### choco (chocolatey)
**Purpose**: The Package Manager for Windows - automates installation, upgrade, and removal of Windows software packages
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `choco install package\nchoco upgrade all\nchoco list --local-only\nchoco uninstall package\nchoco se...`

#### choose (choose)
**Purpose**: Human-friendly field selection tool with Python-like syntax - easier than cut/awk for rapid shell use with negative indexing and regex separators
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `echo 'one two three' | choose 0 # Select first field (zero-indexed)\necho 'one two three four' | cho...`

#### circo (graphviz)
**Purpose**: Circular layout for graphs
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `circo -Tpng input.dot -o output.png...`

#### cloc (cloc)
**Purpose**: Multi-language source code line counter with complexity metrics
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `cloc src/ # Count lines in source directory...`

#### clockres64 (sysinternals)
**Purpose**: Display system clock resolution and timer information for performance analysis
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `clockres64 # Show clock resolution\nclockres64 -c # Continuous monitoring\nclockres64 -h # High prec...`

#### conda (python-micromamba)
**Purpose**: Cross-platform package manager for Python and R ecosystems, fully self-contained executable
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `conda create -n myenv python=3.11\nconda install numpy pandas scipy\nconda list\nconda env list\ncon...`

#### conftest (conftest)
**Purpose**: Write tests against structured configuration data using Rego - supports Kubernetes manifests, Dockerfiles, Terraform plans, and more
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `conftest test deployment.yaml\nconftest verify --policy policy/ manifests/\nconftest test --update g...`

#### contig64 (sysinternals)
**Purpose**: Defragment individual files or analyze file fragmentation on NTFS volumes
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `Contig64 -a file.txt # Analyze fragmentation\nContig64 -f file.txt # Defragment file\nContig64 -s /p...`

#### coreinfo64 (sysinternals)
**Purpose**: Display CPU and memory topology information including cores, threads, cache hierarchy, and NUMA nodes
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `Coreinfo64 # Show CPU topology\nCoreinfo64 -c # Logical to physical core mapping\nCoreinfo64 -g # Gr...`

#### corepack (node)
**Purpose**: Package manager manager - enables use of Yarn and pnpm without installation
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `corepack enable # Enable corepack for yarn/pnpm...`

#### cosign (cosign)
**Purpose**: Container signing, verification and storage in OCI registry with keyless authentication and policy enforcement
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `cosign sign --yes myimage:latest\ncosign verify --key cosign.pub myimage:latest\ncosign verify-attes...`

#### crane (crane)
**Purpose**: OCI image registry manipulation tool for copying, inspecting, and modifying container images
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `crane copy alpine:latest myregistry.com/alpine:latest\ncrane ls gcr.io/distroless/base\ncrane config...`

#### csvtk (csvtk)
**Purpose**: High-performance CSV processor with filtering, joining, and plotting
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `csvtk stats data.csv # Statistical summary of numeric columns...`

#### ctags (ctags)
**Purpose**: Multi-language source indexer with advanced pattern recognition
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `ctags -R --exclude=node_modules . # Recursive indexing excluding node_modules...`

#### cygpath (path-utils)
**Purpose**: Convert between MSYS2/Cygwin and Windows path formats with comprehensive options
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `cygpath -w /home/user\ncygpath -u 'C:\\Users'\ncygpath -am /tmp...`

#### dasel (dasel)
**Purpose**: Universal data selector supporting JSON, YAML, TOML, XML, CSV with unified query syntax and format conversion - up to 3x faster than jq with zero runtime dependencies
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `dasel -f config.yaml '.database.host' # Query any format...`

#### delta (git-extras)
**Purpose**: A syntax-highlighting pager for git, diff, grep, and blame output with themes and customizable colors
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `git config --global core.pager delta # Set as git pager\ndelta --theme=gruvbox-dark file1.txt file2....`

#### die (detectiteasy)
**Purpose**: GUI packer detector with signature database and entropy analysis
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `die malware.exe # Interactive GUI analysis with detailed results...`

#### diec (detectiteasy)
**Purpose**: Console packer detector for automated malware analysis pipelines
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `diec --json sample.exe | jq '.detects[].name' # Extract detected packers...`

#### diel (detectiteasy)
**Purpose**: Lightweight packer detector optimized for speed over completeness
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `diel --fast *.exe # Quick batch scanning mode...`

#### difft (difftastic)
**Purpose**: Syntax-aware structural diff tool - compares files based on their syntax tree rather than line-by-line for more meaningful diffs
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `difft file1.js file2.js\ndifft --display side-by-side old.py new.py\ndifft --color always before.jso...`

#### difft (git-extras)
**Purpose**: Structural diff tool that understands programming language syntax for better comparisons
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `difft file1.py file2.py # Compare Python files with syntax awareness\ngit difftool --tool=difft # Us...`

#### direnv (direnv)
**Purpose**: Load and unload environment variables depending on current directory - hooks into shell to automatically source .envrc files
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `direnv allow\ndirenv deny\ndirenv reload\ndirenv edit...`

#### dirmngr (gpg)
**Purpose**: GnuPG keyserver and certificate manager daemon
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `dirmngr --server # Start keyserver daemon\ndirmngr --list-crls # List certificate revocation lists\n...`

#### dirname (path-utils)
**Purpose**: Extract directory component from file path by removing filename suffix
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `dirname /path/to/file.txt\ndirname $(pwd)/script.sh\ncd $(dirname $0)...`

#### dive (dive)
**Purpose**: Docker image layer analysis tool with file changes visualization and size optimization recommendations
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `dive <image-name> | dive nginx:latest | dive --source docker-archive image.tar...`

#### dog (dog)
**Purpose**: Modern DNS client written in Rust with colorful output, DoT/DoH support, and JSON export - easier to use than dig with intuitive syntax
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `dog example.com # Basic DNS lookup\ndog example.com MX @1.1.1.1 # MX records via Cloudflare DNS\ndog...`

#### dot (graphviz)
**Purpose**: Hierarchical or layered drawings of directed graphs
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `dot -Tpng input.dot -o output.png...`

#### dprint (dprint)
**Purpose**: High-performance code formatter with plugin architecture
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `dprint fmt src/ # Format specific directory\ndprint check --diff # Show formatting differences witho...`

#### dsq (dsq)
**Purpose**: DataStation Query - SQL queries against structured data files with automatic schema detection and format conversion
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `dsq data.csv 'SELECT * FROM {} LIMIT 10'\ndsq data.json 'SELECT COUNT(*) FROM {}'\ndsq file.xlsx 'SE...`

#### duf (duf)
**Purpose**: Modern disk usage analyzer with colorful output and smart color coding - highlights availability and usage columns based on remaining space thresholds
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `duf # Show all mounted filesystems\nduf /home /var # Show specific paths\nduf --all # Include pseudo...`

#### dumpcap (wireshark-cli)
**Purpose**: Network traffic dump tool for packet capture
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `dumpcap -i interface -w output.pcap\ndumpcap -i eth0 -w capture.pcap\ndumpcap -D\ndumpcap -i any -a ...`

#### dust (dust)
**Purpose**: Modern du replacement with colorized output and intelligent sorting
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `dust -d 2 /c/Projects # Show 2 levels deep in Projects directory\ndust -r -n 10 . # Reverse sort sho...`

#### es (everything)
**Purpose**: Everything Search CLI - instant file search with regex, filters, and export capabilities
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `es "search term" | es -r "regex.*pattern" | es -folder-only "dirname" | es -export results.txt "quer...`

#### etc1tool (android-utilities)
**Purpose**: ETC1 texture compression for OpenGL ES performance optimization
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `etc1tool texture.png --encode -o compressed.pkm # Compress to ETC1 with header\netc1tool texture.png...`

#### exiftool (exiftool)
**Purpose**: Comprehensive metadata reader/writer for images, videos, and documents
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `exiftool image.jpg # Read all metadata\nexiftool -GPS* photo.jpg # Show GPS data\nexiftool -overwrit...`

#### exiftool-k (exiftool)
**Purpose**: ExifTool with -k option to keep console window open on Windows
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `\"exiftool(-k).exe\" image.jpg # View metadata with persistent window\n\"exiftool(-k).exe\" -all= cl...`

#### eza (eza)
**Purpose**: Modern ls replacement with Git awareness, icons, and tree view
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `eza -la # Long listing with hidden files\neza --tree --level=2 # Tree view with depth\neza --git # S...`

#### far (far)
**Purpose**: Far Manager - powerful file manager with plugin architecture and scripting
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `Far.exe # Launch file manager\nF3 - View file, F4 - Edit, F5 - Copy, F6 - Move, F7 - Create director...`

#### fastboot (fastboot)
**Purpose**: Android fastboot protocol tool for bootloader flashing and device management
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `fastboot devices # List devices in fastboot mode\nfastboot flash boot boot.img # Flash boot partitio...`

#### figlet (figlet)
**Purpose**: Display large characters made up of ordinary screen characters - create ASCII art text with various fonts and styles
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `figlet Hello World\nfiglet -f big 'Big Text'\nfiglet -f block 'BLOCK TEXT'\necho 'Text' | figlet...`

#### fx (fx)
**Purpose**: Interactive JSON viewer and processor with JavaScript expressions and live editing capabilities - perfect for exploring large JSON files with syntax highlighting
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `fx data.json # Interactive JSON browser with syntax highlighting\ncat data.json | fx '.users[0].name...`

#### fzf (fzf)
**Purpose**: Command-line fuzzy finder with UNIX pipe integration and preview
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `ls | fzf # Fuzzy select from list\nfzf --preview 'cat {}' # Preview files\nhistory | fzf # Search co...`

#### gcrane (crane)
**Purpose**: Google Container Registry (GCR) specific version of crane with enhanced authentication
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `gcrane copy gcr.io/project/image:tag gcr.io/project/image:new\ngcrane ls gcr.io/project\ngcrane auth...`

#### gdu (gdu)
**Purpose**: Fast disk usage analyzer with interactive TUI, parallel processing, and comprehensive filesystem analysis capabilities
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `gdu # Analyze current directory\ngdu /path/to/analyze # Analyze specific path\ngdu --show-disks # Sh...`

#### gh (git-extras)
**Purpose**: GitHub CLI for repository management, issues, pull requests, and GitHub Actions
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `gh repo create myproject --public # Create repository\ngh pr create --title 'Fix bug' --body 'Descri...`

#### gh-dash (gh-dash)
**Purpose**: Terminal UI dashboard for GitHub CLI - view and manage pull requests, issues, and repositories in a beautiful interface
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `gh-dash\ngh-dash --config ~/.config/gh-dash/config.yml\ngh extension install dlvhdr/gh-dash...`

#### glow (glow)
**Purpose**: Terminal Markdown renderer with syntax highlighting and paging
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `glow README.md # Render Markdown file\nglow -p # Browse local files\necho '# Hello' | glow - # Rende...`

#### gpg (git-extras)
**Purpose**: GNU Privacy Guard for Git commit and tag signing with cryptographic verification
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `git config --global user.signingkey KEY_ID # Set GPG signing key\ngit config --global commit.gpgsign...`

#### gpg (gpg)
**Purpose**: GNU Privacy Guard for encryption, digital signatures, and key management
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `gpg --gen-key # Generate new key pair\ngpg --encrypt -r recipient@email.com file.txt # Encrypt file\...`

#### gpg-agent (gpg)
**Purpose**: GnuPG private key agent for secure key management and caching
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `gpg-agent --daemon # Start agent daemon\ngpg-agent --reload # Reload configuration\necho RELOADAGENT...`

#### gpg-connect-agent (gpg)
**Purpose**: GnuPG agent communication tool for daemon control and key operations
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `gpg-connect-agent # Interactive agent communication\necho 'KEYINFO --list' | gpg-connect-agent # Lis...`

#### gpgconf (gpg)
**Purpose**: GnuPG configuration management and component control utility
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `gpgconf --list-components # List GnuPG components\ngpgconf --reload gpg-agent # Reload specific comp...`

#### grex (grex)
**Purpose**: Smart regex generator that creates patterns from example strings - no more manual regex writing
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `grex 'hello' 'world'\ngrex -i 'Hello' 'HELLO' 'hello'\ngrex --words 'I love' 'You love'\ngrex --esca...`

#### gron (gron)
**Purpose**: Transform JSON into greppable discrete assignments for easier searching - flattens hierarchical JSON into simple key-value pairs with full path context
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `curl api.com/data | gron # Flatten API response for grepping\ngron data.json | grep 'user' # Search ...`

#### grype (grype)
**Purpose**: Vulnerability scanner for container images and filesystems with SARIF/JSON output and policy enforcement
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `grype alpine:latest\ngrype dir:. -o json\ngrype docker.io/nginx:latest --fail-on high\ngrype registr...`

#### gvproxy (podman)
**Purpose**: VPN proxy server for Podman machine networking and port forwarding
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `gvproxy -listen unix:///tmp/gvproxy.sock\ngvproxy -debug -listen tcp://127.0.0.1:8080...`

#### hadolint (hadolint)
**Purpose**: Dockerfile linter with best practices validation, security checks, and bash linting support
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `hadolint Dockerfile | hadolint --config .hadolint.yaml Dockerfile | hadolint --ignore DL3008 Dockerf...`

#### handle64 (sysinternals)
**Purpose**: Display open handles for processes, helping identify file and resource locks
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `handle64 # Show all handles\nhandle64 file.txt # Show handles to specific file\nhandle64 -p 1234 # S...`

#### hardlink (path-utils)
**Purpose**: Create hard links to files for space-efficient file duplication
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `hardlink source.txt target.txt\nhardlink -n source.txt\nhardlink -v source.txt backup.txt...`

#### hck (hck)
**Purpose**: Fast field extraction tool with regex support - more powerful than cut with better performance
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `hck -f 1,3 file.csv\nhck -d: -f 2 /etc/passwd\nhck -F '[,;]' -f 1-3 data.txt\nhck -D\n -f 1...`

#### hex2dec64 (sysinternals)
**Purpose**: Convert hexadecimal numbers to decimal and vice versa with support for various number bases
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `hex2dec64 0x1A # Convert hex to decimal\nhex2dec64 -d 26 # Convert decimal to hex\nhex2dec64 -b 8 77...`

#### hexyl (hexyl)
**Purpose**: Modern command-line hex viewer with colorized output for binary file analysis - written in Rust with high performance and intelligent byte categorization
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `hexyl firmware.bin # View binary file with colors\nhexyl --no-color data.bin # Plain output for scri...`

#### htmlq (htmlq)
**Purpose**: Command-line HTML processor that applies CSS selectors to extract data, manipulate DOM elements, and format output
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `htmlq 'title' < index.html...`

#### hwinfo64 (hwinfo)
**Purpose**: Hardware information and monitoring tool for detailed system analysis
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `hwinfo64.exe # Launch GUI interface...`

#### hx (helix)
**Purpose**: Helix editor with tree-sitter syntax highlighting and LSP support
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `hx file.rs # Edit Rust file with syntax highlighting\nhx --health # Check LSP server status\nhx --tu...`

#### hyperfine (hyperfine)
**Purpose**: Statistical benchmarking tool with warmup runs and JSON output support
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `hyperfine 'command1' 'command2' # Compare two commands\nhyperfine --warmup 3 'command' # Run 3 warmu...`

#### jaq (jaq)
**Purpose**: Ultra-fast Rust jq implementation with 30x faster startup and superior performance on most benchmarks - security audited with 500+ test suite
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `jaq '.users[] | select(.active)' users.json\njaq -r '.items[] | "\(.name): \(.price)"' catalog.json\...`

#### jar (java)
**Purpose**: Java archive tool for creating and managing JAR files
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `jar -cf app.jar *.class | jar -xf archive.jar | jar -tf library.jar...`

#### jarsigner (java)
**Purpose**: Java JAR signing and verification tool for code signing and security
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `jarsigner -keystore keystore.jks app.jar mykey | jarsigner -verify signed.jar...`

#### jo (jo)
**Purpose**: Simple command-line tool to create JSON objects and arrays from shell arguments
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `jo name=John age:=30 married:=true\njo -p foo=bar baz:=123\njo -a apple banana cherry\necho key=valu...`

#### jq (jq)
**Purpose**: The original and most comprehensive JSON processor with powerful functional programming constructs - industry standard for complex JSON transformations and queries
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `curl api.com/data | jq '.results[] | select(.score > 80)' # Filter API responses\ncat logs.json | jq...`

#### jql (jql)
**Purpose**: JSON Query Language with Lisp-like syntax and streaming support for Docker logs and real-time JSON processing - intuitive token-based queries for complex transformations
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `jql '.["users"].[0].["name"]' data.json\njql --stream '.["message"]' # Stream processing for Docker ...`

#### junction64 (sysinternals)
**Purpose**: Create, delete, and list NTFS junction points and symbolic links on Windows
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `junction64 link target # Create junction point\njunction64 -d link # Delete junction\njunction64 -s ...`

#### just (just)
**Purpose**: Command runner for project-specific tasks with make-inspired syntax - no .PHONY recipes needed, works from any subdirectory, never breaking backwards compatibility
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `just # Run default recipe\njust --list # Show available recipes\njust build # Run build recipe\njust...`

#### k6 (k6)
**Purpose**: JavaScript-based load testing with built-in metrics and cloud-native integrations
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `k6 run --vus 100 --duration 30s script.js # Ramp load testing\nk6 run --out influxdb=http://localhos...`

#### k9s (k9s)
**Purpose**: Terminal-based Kubernetes UI with real-time cluster monitoring
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `k9s # Launch Kubernetes TUI\n:pods # Navigate to pods view\n:services # Navigate to services\n:logs ...`

#### kaf (kaf)
**Purpose**: Modern Kafka CLI with context management for multi-environment cluster operations
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `kaf config add-cluster local -b localhost:9092 | kaf topics | kaf consume topic --from-beginning...`

#### kafkactl (kafkactl)
**Purpose**: Enterprise-grade command line tool for managing Apache Kafka clusters and operations
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `kafkactl create topic test --partitions 3 | kafkactl produce topic --value message | kafkactl consum...`

#### kalker (kalker)
**Purpose**: Scientific calculator with support for variables, functions, complex numbers, and calculus operations
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `kalker # Start interactive calculator...`

#### kaskade (kaskade)
**Purpose**: Visual Kafka TUI that replaces web UIs - create/delete topics, monitor consumers, filter messages with keyboard-only navigation
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `kaskade admin -b kafka:9092 | kaskade consumer -b kafka:9092 -t user.events --deserializer json | ka...`

#### kcctl (kcctl)
**Purpose**: Streamlined Kafka Connect management tool with kubectl-like experience and Quarkus native performance
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `kcctl get connectors | kcctl describe connector my-connector | kcctl apply -f connector.yaml...`

#### klp (klp)
**Purpose**: Structured log parser with JSON/logfmt/CSV support and advanced time analysis
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `klp file.jsonl # View JSON Lines log file\nklp --filter 'severity == "ERROR"' app.log # Filter by co...`

#### krane (crane)
**Purpose**: Kubernetes-focused crane variant for working with container images in K8s contexts
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `krane copy image:latest localhost:5000/image:latest\nkrane validate image:tag...`

#### kube-linter (kube-linter)
**Purpose**: Static analysis tool for Kubernetes YAML files and security best practices
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `kube-linter lint deployment.yaml # Lint single file\nkube-linter lint k8s/ # Lint directory\nkube-li...`

#### kube-score (kube-score)
**Purpose**: Kubernetes object analysis for security and reliability best practices
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `kube-score score deployment.yaml # Score single file\nkube-score score --output-format ci # CI-frien...`

#### kubeval (kubeval)
**Purpose**: Validate Kubernetes configuration files against official Kubernetes schemas - supports multiple file formats and strict validation
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `kubeval deployment.yaml\nkubeval *.yaml\nkubeval --strict pod.yaml\nkubeval --kubernetes-version 1.1...`

#### kustomize (k8)
**Purpose**: Kubernetes configuration management without templates using overlays
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `kustomize build overlays/production # Build production config\nkustomize build . | kubectl apply -f ...`

#### lemmeknow (lemmeknow)
**Purpose**: Advanced pattern identification tool for analyzing unknown text formats, encodings, hashes, and data structures with confidence scoring
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `lemmeknow "base64encodedtext"...`

#### link (path-utils)
**Purpose**: Create file links with extended options and validation
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `link -s source.txt symlink.txt\nlink -f source.txt hardlink.txt\nlink -v source.txt target.txt...`

#### liquibase (liquibase)
**Purpose**: Database migration and schema versioning tool
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `liquibase update\nliquibase --changeLogFile=changelog.xml update\nliquibase --changeLogFile=changelo...`

#### listdlls64 (sysinternals)
**Purpose**: Display loaded DLLs for running processes with version information and base addresses
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `listdlls64 # List DLLs for all processes\nlistdlls64 -p 1234 # List DLLs for specific PID\nlistdlls6...`

#### lizard (lizard)
**Purpose**: Multi-language code complexity analyzer with cyclomatic complexity metrics and detailed reports
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `lizard src/ | lizard --xml src/ | lizard --CCN 15 --length 1000 src/...`

#### ln (path-utils)
**Purpose**: UNIX-style link creator for symbolic and hard links with standard options
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `ln -s /path/to/file symlink\nln file1.txt file2.txt\nln -sf new_target existing_link...`

#### lnav (lnav)
**Purpose**: Advanced ncurses-based log file navigator with automatic format detection, SQL querying, timeline visualization, and intelligent multi-file correlation
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `lnav /var/log/*.log | lnav -c "SELECT * FROM log WHERE level = \"ERROR\"" | lnav -t access.log...`

#### lsd (lsd)
**Purpose**: Rust-based ls replacement with colors, icons, tree view and modern formatting options
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `lsd\nlsd -la\nlsd --tree\nlsd --color=never\nlsd --icon=never...`

#### lz4 (lz4)
**Purpose**: Ultra-fast compression tool optimized for speed over compression ratio
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `lz4 file.txt\nlz4 -d file.txt.lz4\nlz4 -9 file.txt\nlz4 -c file.txt | process\nlz4 -f existing.lz4...`

#### macchina (macchina)
**Purpose**: System information display tool with emphasis on performance - shows kernel, uptime, memory, CPU load
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `macchina\nmacchina --help\nmacchina --theme Hydrogen\nmacchina --ascii-artists...`

#### mage (mage)
**Purpose**: Go-based build tool - write build targets in Go instead of shell scripts with automatic dependency management
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `mage\nmage -l\nmage build\nmage test\nmage -v clean...`

#### mc (mc)
**Purpose**: Midnight Commander dual-pane file manager with Norton Commander interface and advanced file operations
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `mc\nmc -b # Black and white mode\nmc -c # Color mode\nmc -d # Debug mode\nmc -f # Display compiled-i...`

#### mcdiff (mc)
**Purpose**: Midnight Commander visual diff tool for comparing files side by side
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `mcdiff file1.txt file2.txt\nmcdiff -b file1 file2 # Ignore whitespace differences...`

#### mcedit (mc)
**Purpose**: Midnight Commander integrated text editor with syntax highlighting and macro support
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `mcedit filename.txt\nmcedit +25 file.c # Open file at line 25\nmcedit -b # Disable syntax highlighti...`

#### mcview (mc)
**Purpose**: Midnight Commander file viewer with hex mode and search capabilities
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `mcview filename.txt\nmcview -b # Disable syntax highlighting\nmcview -h # Hex mode...`

#### md5deep (hashdeep)
**Purpose**: Specialized MD5 hash calculator for forensic analysis and file verification
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `md5deep -r /evidence # Recursive MD5 hashing\nmd5deep -m known_md5.txt *.bin # Match against known M...`

#### micro (micro)
**Purpose**: Modern, intuitive terminal text editor with mouse support, syntax highlighting, and common key bindings
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `micro file.txt\nmicro -colorscheme monokai\nmicro -plugin install filemanager\nmicro +10 file.txt\nm...`

#### micromamba (python-micromamba)
**Purpose**: Fast, lightweight conda-compatible package manager with minimal dependencies
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `micromamba create -n myenv python=3.11\nmicromamba install -n myenv numpy pandas\nmicromamba activat...`

#### minikube (minikube)
**Purpose**: Run Kubernetes clusters locally for development with various virtualization drivers
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `minikube start\nminikube status\nminikube dashboard\nminikube docker-env\nminikube stop\nminikube de...`

#### miniserve (miniserve)
**Purpose**: Fast, self-contained HTTP file server written in Rust - perfect for quick file sharing
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `miniserve .\nminiserve --port 8080 /path/to/files\nminiserve --upload-files /tmp\nminiserve --auth u...`

#### mkcert (mkcert)
**Purpose**: Zero-config tool to make locally trusted development certificates with any names - automatically creates and installs local CA
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `mkcert -install\nmkcert localhost 127.0.0.1 ::1\nmkcert example.com '*.example.com'\nmkcert -uninsta...`

#### mlr (miller)
**Purpose**: Powerful data processing tool combining awk, sed, cut, join, sort functionality for CSV, TSV, JSON with 40+ built-in verbs
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `mlr --csv cut -f name,age data.csv\nmlr --icsv --ojson cat data.csv\nmlr --csv stats1 -a sum -f sale...`

#### musikcube (musikube)
**Purpose**: Terminal-based music player with ncurses interface for audio library management
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `musikcube # Launch terminal music player interface...`

#### musikcube-gui (musikube)
**Purpose**: Graphical user interface version of musikcube music player
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `musikcube-gui # Launch GUI music player...`

#### naabu (naabu)
**Purpose**: High-performance SYN/CONNECT/UDP port scanner optimized for speed and accuracy with support for multiple output formats
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `naabu -host example.com...`

#### navi (navi)
**Purpose**: Interactive cheatsheet tool with fuzzy search for discovering and executing command templates
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `navi\nnavi --print\nnavi --path /path/to/cheats\nnavi widget shell\nnavi search docker...`

#### neato (graphviz)
**Purpose**: Spring model layouts for undirected graphs
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `neato -Tpng input.dot -o output.png...`

#### nerdctl (nerdctl)
**Purpose**: ContaiNERD CTL - Docker-compatible CLI for containerd with compose, rootless, eStargz, OCIcrypt support
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `nerdctl run -it --rm alpine:latest sh\nnerdctl build -t myapp .\nnerdctl compose up -d\nnerdctl cont...`

#### nircmd (nircmd)
**Purpose**: Comprehensive command-line tool for Windows operations like window management, system control, and registry manipulation
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `nircmd win hide title "Calculator"\nnircmd setvolume 0.8\nnircmd cdrom open\nnircmd monitor off\nnir...`

#### nircmdc (nircmd)
**Purpose**: Console version of NirCmd with enhanced output and scripting capabilities
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `nircmdc win max process "notepad.exe"\nnircmdc setdefaultsounddevice "Speakers"\nnircmdc exec show "...`

#### npcap-helper (nmap)
**Purpose**: Helper utility for managing Npcap driver installation and configuration
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `NpcapHelper.exe --install-driver\nNpcapHelper.exe --uninstall-driver\nNpcapHelper.exe --check-status...`

#### npcap-installer (nmap)
**Purpose**: Packet capture library installer for Windows network packet analysis
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `npcap-1.83.exe /S\nnpcap-1.83.exe /LOOPBACK_SUPPORT=yes\nnpcap-1.83.exe /WINPCAP_MODE=yes...`

#### npx (node)
**Purpose**: Node Package eXecute - run packages without installing them globally
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `npx create-react-app my-app # Create React application...`

#### nu (nushell)
**Purpose**: Nushell - main shell executable with structured data pipeline
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW

#### nu_plugin_custom_values (nushell)
**Purpose**: Nushell plugin for custom value types
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW

#### nu_plugin_example (nushell)
**Purpose**: Nushell example plugin for development reference
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW

#### nu_plugin_formats (nushell)
**Purpose**: Nushell plugin for additional data format support
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW

#### nu_plugin_gstat (nushell)
**Purpose**: Nushell plugin for Git statistics
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW

#### nu_plugin_inc (nushell)
**Purpose**: Nushell plugin for incrementing values
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW

#### nu_plugin_polars (nushell)
**Purpose**: Nushell plugin for Polars dataframe operations
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW

#### nu_plugin_query (nushell)
**Purpose**: Nushell plugin for web scraping and data extraction
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW

#### nu_plugin_stress_internals (nushell)
**Purpose**: Nushell plugin for stress testing internals
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW

#### nuclei (nuclei)
**Purpose**: YAML-driven vulnerability scanner with 9000+ community templates for modern threat detection
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `nuclei -u https://target.com -t cves/ -silent\nnuclei -l targets.txt -t exposures/ -severity critica...`

#### oc (openshift)
**Purpose**: OpenShift CLI for managing applications, builds, deployments, and cluster resources
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `oc login https://api.cluster.com\noc new-app nodejs~https://github.com/user/app\noc get pods\noc log...`

#### oha (oha)
**Purpose**: Lousy HTTP load generator - fast and efficient load testing tool with colored output and real-time statistics display
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `oha -n 1000 -c 10 https://example.com\noha -z 10s -c 20 https://api.example.com\noha --no-tui -n 100...`

#### onefetch (onefetch)
**Purpose**: Beautiful git repository analyzer showing language stats, contributors, and project details
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `onefetch\nonefetch --help\nonefetch --no-art\nonefetch --languages\nonefetch --output json...`

#### osqueryd (osquery)
**Purpose**: Background daemon for continuous system monitoring and log collection using SQL queries
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `osqueryd --config_path=osquery.conf\nosqueryd --verbose\nosqueryd --database_path=osquery.db\nosquer...`

#### osqueryi (osquery)
**Purpose**: Interactive shell for ad-hoc system queries and investigation using SQL syntax
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `osqueryi\nosqueryi --json 'SELECT * FROM processes;'\nosqueryi --line 'SELECT name FROM processes;'\...`

#### ouch (ouch)
**Purpose**: Universal compression tool with automatic format detection - supports ZIP, TAR, 7Z, RAR, ZSTD, LZMA, BZIP2, LZ4, and more
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `ouch compress file1.txt file2.txt archive.zip\nouch decompress archive.zip\nouch list archive.tar.gz...`

#### oxipng (oxipng)
**Purpose**: High-performance PNG optimizer that reduces file size without quality loss using advanced algorithms
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `oxipng image.png\noxipng -o 6 image.png\noxipng --strip safe image.png\noxipng -r *.png\noxipng --al...`

#### par2 (par2)
**Purpose**: Create and use parity files for error detection and correction to recover damaged or missing files
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `par2 create archive.par2 file1.txt file2.txt\npar2 verify archive.par2\npar2 repair archive.par2\npa...`

#### pathchk (path-utils)
**Purpose**: Validate file path names for portability and system compatibility
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `pathchk /path/to/file\npathchk -p /portable/path\npathchk -P /strict/path...`

#### peco (peco)
**Purpose**: Interactive filtering tool for selecting items from lists with fuzzy matching and real-time search
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `history | peco\nls | peco\nps aux | peco\nfind . -name '*.txt' | peco\npeco --query 'initial search'...`

#### pendmoves64 (sysinternals)
**Purpose**: Display files and directories scheduled for move or delete on next reboot
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `PendMoves64 # Show pending moves and deletes\nPendMoves64 -c # Clear pending operations\nPendMoves64...`

#### pmd (pmd)
**Purpose**: Advanced source code analyzer that detects bugs, code quality issues, performance problems, and security vulnerabilities across multiple languages
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `pmd check -d src/ -R rulesets/java/quickstart.xml -f text...`

#### podman (podman)
**Purpose**: Daemonless container runtime with Docker-compatible CLI and advanced security features
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `podman run -it --rm alpine:latest sh\npodman build -t myapp .\npodman images --format json | jq '.[]...`

#### polaris (polaris)
**Purpose**: Fairwinds Polaris - runs a variety of checks to ensure Kubernetes pods and controllers are configured using best practices
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `polaris audit --audit-path .\npolaris dashboard\npolaris webhook --config config.yaml...`

#### presenterm (presenterm)
**Purpose**: Terminal slideshow tool with markdown support, themes, image protocols, PDF/HTML export, and speaker notes
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `presenterm presentation.md # Start slideshow\npresenterm --export-pdf presentation.md # Export to PD...`

#### procdump64 (sysinternals)
**Purpose**: Generate dumps of running processes for analysis and troubleshooting
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `procdump64 -ma process.exe # Full memory dump\nprocdump64 -e 1 -f C00000FD process.exe # Dump on exc...`

#### procs (procs)
**Purpose**: Modern process viewer with colorful output and advanced filtering - displays network ports, disk I/O, memory usage, and Docker container names with tree view and search capabilities
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `procs\nprocs --tree\nprocs -W\nprocs chrome\nprocs --and chrome --and --pid 1000-2000...`

#### promtool (monitoring)
**Purpose**: Command-line tooling for Prometheus monitoring system configuration and rule validation
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `promtool check config prometheus.yml\npromtool check rules rules.yml\npromtool query instant 'up'\np...`

#### pueue (pueue)
**Purpose**: Client for managing command queue - add, pause, remove, and monitor long-running tasks with process management
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `pueue add 'long-running-command'\npueue status\npueue log\npueue pause 1...`

#### pueued (pueue)
**Purpose**: Daemon process that manages the task queue - handles process execution, logging, and state management
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `pueued\npueued -d...`

#### pwsh (powershell-core)
**Purpose**: PowerShell 7+ - Modern cross-platform shell and scripting language with object pipeline
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `pwsh # Start interactive PowerShell session...`

#### qrencode (qrencode)
**Purpose**: Fast and compact QR Code encoding library and command-line utility - supports up to 7000 digits or 4000 characters with high robustness
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `qrencode -o qr.png 'Hello World'\nqrencode -t PNG -o myqr.png 'https://example.com'\necho 'data' | q...`

#### qsv (qsv)
**Purpose**: Ultra-fast CSV toolkit with 50+ commands for data processing
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `qsv stats data.csv\nqsv select 1,3,5 data.csv\nqsv filter 'age > 30' data.csv\nqsv join id file1.csv...`

#### qsv-nightly (qsv)
**Purpose**: Nightly development build of QSV with latest features and experimental commands
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `qsv_nightly experimental-command data.csv\nqsv_nightly beta-stats data.csv\nqsv_nightly --nightly-in...`

#### qsvdp (qsv)
**Purpose**: QSV DataPusher version with enhanced data uploading and API integration capabilities
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `qsvdp upload data.csv --api-endpoint https://api.example.com\nqsvdp validate schema.json data.csv\nq...`

#### qsvlite (qsv)
**Purpose**: Lightweight version of QSV with core functionality for basic CSV operations
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `qsvlite stats data.csv\nqsvlite select 1,3 data.csv\nqsvlite headers data.csv\nqsvlite count data.cs...`

#### qsvlite-nightly (qsv)
**Purpose**: Nightly development build of QSV Lite with latest experimental features
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `qsvlite_nightly stats --experimental data.csv\nqsvlite_nightly beta-command data.csv\nqsvlite_nightl...`

#### qsvp (qsv)
**Purpose**: QSV Pro version with advanced analytics and enterprise features
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `qsvp analyze --advanced data.csv\nqsvp ml-predict model.json data.csv\nqsvp enterprise-export data.c...`

#### qsvpdp (qsv)
**Purpose**: QSV Pro DataPusher combining enterprise features with API integration
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `qsvpdp enterprise-upload data.csv --secure-api https://enterprise.api.com\nqsvpdp audit-trail data.c...`

#### qsvplite (qsv)
**Purpose**: QSV Pro Lite version with balanced features and performance
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `qsvplite pro-stats data.csv\nqsvplite advanced-join file1.csv file2.csv\nqsvplite optimize data.csv...`

#### qsvpy310 (qsv)
**Purpose**: QSV with embedded Python 3.10 for advanced data processing and scripting
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `qsvpy310 py 'df.describe()' data.csv\nqsvpy310 script analysis.py data.csv\nqsvpy310 py 'import nump...`

#### qsvpy311 (qsv)
**Purpose**: QSV with embedded Python 3.11 offering improved performance for data science workflows
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `qsvpy311 py 'df.groupby("category").sum()' data.csv\nqsvpy311 ml-train model.py data.csv\nqsvpy311 p...`

#### qsvpy312 (qsv)
**Purpose**: QSV with embedded Python 3.12 featuring latest Python optimizations and syntax
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `qsvpy312 py 'match df.shape[0]: case n if n > 1000: print("Large dataset")' data.csv\nqsvpy312 py 'd...`

#### qsvpy313 (qsv)
**Purpose**: QSV with embedded Python 3.13 beta featuring cutting-edge Python developments
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `qsvpy313 py --experimental 'df.new_feature()' data.csv\nqsvpy313 py 'df.enhanced_typing()' data.csv\...`

#### r2agent (radare2)
**Purpose**: Remote agent for radare2 allowing network-based reverse engineering sessions
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `r2agent -p 9999\nr2agent -H 0.0.0.0 -p 8080\nr2agent -a x86\nr2agent -s...`

#### r2pm (radare2)
**Purpose**: Package manager for radare2 plugins and extensions
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `r2pm update\nr2pm search keyword\nr2pm install package_name\nr2pm list\nr2pm uninstall package_name...`

#### r2r (radare2)
**Purpose**: Test runner for radare2 regression testing and validation
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `r2r test_file.r2\nr2r -j tests/\nr2r -v tests/\nr2r -i...`

#### rabin2 (radare2)
**Purpose**: Binary analysis tool for extracting information from executables
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `rabin2 -I binary.exe\nrabin2 -i binary.exe\nrabin2 -E binary.exe\nrabin2 -S binary.exe\nrabin2 -z bi...`

#### radare2 (radare2)
**Purpose**: Advanced reverse engineering framework with disassembler and debugger
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `radare2 binary.exe\nr2 -A binary.exe\nr2 -d program.exe\nr2 -w binary.exe\nr2 -B 0x1000 mem.dump...`

#### radiff2 (radare2)
**Purpose**: Binary diffing tool for comparing executables and finding differences between versions
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `radiff2 file1.exe file2.exe\nradiff2 -g file1.exe file2.exe\nradiff2 -A file1.exe file2.exe\nradiff2...`

#### ragg2 (radare2)
**Purpose**: Shellcode compiler and payload generator for exploit development
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `ragg2 -a x86 -b 64 shellcode.r\nragg2 -F elf64 -o payload shellcode.r\nragg2 -P print_shellcode.r\nr...`

#### rapatch2 (radare2)
**Purpose**: Binary patching tool for applying modifications and fixes to executable files
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `rapatch2 -p patch.r2 binary.exe\nrapatch2 -w 0x1000 \"41414141\" binary.exe\nrapatch2 -r 0x1000:10 b...`

#### rasign2 (radare2)
**Purpose**: Function signature generator and matcher for binary analysis and library identification
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `rasign2 -g signature.sig binary.exe\nrasign2 -a signature.sig target.exe\nrasign2 -f function_name b...`

#### rasm2 (radare2)
**Purpose**: Multi-architecture assembler and disassembler supporting numerous CPU architectures
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `rasm2 -a x86 -b 64 'mov rax, rbx'\nrasm2 -a arm -d '0x12345678'\nrasm2 -L\nrasm2 -f input.asm...`

#### rax2 (radare2)
**Purpose**: Number base converter and mathematical calculator for various numeric formats
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `rax2 0x1000\nrax2 -b 4096\nrax2 -k 10+20*3\nrax2 -s hello\nrax2 -S 48656c6c6f...`

#### rclone (rclone)
**Purpose**: Sync files and directories to/from cloud storage providers like Google Drive, S3, Dropbox, and 70+ others
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `rclone copy /local/path remote:bucket\nrclone sync /local remote:folder --dry-run\nrclone mount remo...`

#### readlink (path-utils)
**Purpose**: Read and resolve symbolic links to display target paths
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `readlink symlink.txt\nreadlink -f symlink.txt\nreadlink -e symlink.txt...`

#### readtags (ctags)
**Purpose**: Tag file reader with filtering, sorting, and formatting capabilities
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `readtags -t tags main # Find 'main' function definitions...`

#### realpath (path-utils)
**Purpose**: Resolve absolute canonical path by following all symbolic links
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `realpath file.txt\nrealpath -s symlink\nrealpath --relative-to=/base /path...`

#### regctl (regctl)
**Purpose**: Registry client for image operations, copying, and registry management with OCI layout support
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `regctl image copy alpine:latest localhost:5000/alpine:latest\nregctl image export alpine:latest alpi...`

#### regdelnull64 (sysinternals)
**Purpose**: Delete registry keys containing null characters that cannot be deleted with standard tools
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `RegDelNull64 HKLM\\Software\\BadKey # Delete key with null chars\nRegDelNull64 -s HKLM\\Software # S...`

#### restic (restic)
**Purpose**: Modern backup program that is fast, efficient and secure - uses cryptography to guarantee confidentiality and integrity of your data with incremental snapshots
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `restic init\nrestic backup ~/Documents\nrestic snapshots\nrestic restore latest ~/restore...`

#### ruff (ruff)
**Purpose**: Lightning-fast Python linter with comprehensive rule coverage and auto-fixing
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `ruff check . # Lint current directory with default rules...`

#### scc (scc)
**Purpose**: Sloc, Cloc and Code complexity counter with support for 200+ programming languages
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `scc .\nscc --by-file src/\nscc --format json .\nscc --exclude-dir node_modules,vendor .\nscc --sort ...`

#### scoop (scoop)
**Purpose**: Windows package manager for command-line programs
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `scoop install <package>\nscoop install git\nscoop search python\nscoop list\nscoop update\nscoop uni...`

#### scrcpy (scrcpy)
**Purpose**: Display and control Android devices over USB/WiFi with low latency
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `scrcpy\nscrcpy -s DEVICE_ID\nscrcpy --max-size 1024\nscrcpy --record file.mp4\nscrcpy --turn-screen-...`

#### sd (sd)
**Purpose**: Fast and intuitive find & replace tool with regex support, safer than sed
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `sd 'old_text' 'new_text' file.txt\nsd '\d+' 'NUMBER' *.txt\nsd --preview 'foo' 'bar' file.txt\nsd -s...`

#### sha256deep (hashdeep)
**Purpose**: SHA-256 hash calculator for modern cryptographic file verification
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `sha256deep -r /secure/files # Recursive SHA-256 hashing\nsha256deep -m hashes.sha256 /download # Ver...`

#### shellcheck (shellcheck)
**Purpose**: Static analysis tool for shell scripts to find bugs and improve code
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `shellcheck script.sh\nshellcheck -f json script.sh\nshellcheck -e SC2086 script.sh\nshellcheck -S st...`

#### shellspec (shellspec)
**Purpose**: Full-featured BDD unit testing framework for POSIX shell scripts
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `shellspec\nshellspec spec/test_spec.sh\nshellspec --format tap\nshellspec --coverage\nshellspec init...`

#### shfmt (shfmt)
**Purpose**: Format and pretty-print shell scripts with consistent style and indentation
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `shfmt script.sh\nshfmt -w *.sh\nshfmt -i 4 script.sh\nshfmt -d script.sh\nshfmt -ln bash script.sh...`

#### skopeo (skopeo)
**Purpose**: Inspect, copy, and manage container images across registries without Docker daemon
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `skopeo inspect docker://alpine:latest\nskopeo copy docker://alpine:latest oci:./alpine\nskopeo list-...`

#### spotbugs (spotbugs)
**Purpose**: Advanced Java bytecode analyzer that detects potential bugs, security vulnerabilities, performance issues and code quality problems
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `spotbugs analyze -textui -output results.xml MyProject.jar...`

#### ssdeep (ssdeep)
**Purpose**: Generate and compare context triggered piecewise hashes (fuzzy hashes) to find similar files
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `ssdeep file.txt\nssdeep -r /path\nssdeep -m hashfile.txt -d /suspect\nssdeep -b -r /samples > baseli...`

#### streams64 (sysinternals)
**Purpose**: Display and delete alternate data streams (ADS) attached to NTFS files
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `streams64 file.txt # Show streams for file\nstreams64 -s /dir # Recurse directory\nstreams64 -d file...`

#### strings64 (sysinternals)
**Purpose**: Extract printable strings from binary files, executables, and memory dumps for analysis
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `strings64 file.exe # Extract strings from executable\nstrings64 -n 10 file.bin # Minimum string leng...`

#### superfile (superfile)
**Purpose**: Modern terminal file manager with advanced navigation, file operations, customizable hotkeys, and beautiful interface
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `superfile # Launch file manager\nsuperfile /path/to/directory # Open specific directory\nsuperfile -...`

#### syft (syft)
**Purpose**: Generate Software Bill of Materials (SBOM) from container images, filesystems, and archives with multi-format output
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `syft alpine:latest -o spdx-json\nsyft dir:. -o cyclone-json\nsyft docker.io/nginx:latest --scope all...`

#### sync64 (sysinternals)
**Purpose**: Flush file system buffers to ensure data is written to disk immediately
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `sync64 # Flush all file system buffers\nsync64 C: # Flush specific drive\nsync64 -e # Show elapsed t...`

#### task (task)
**Purpose**: Go-Task - simple task runner and build tool with YAML configuration, parallel execution, and dependency management
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `task --list\ntask build test deploy\ntask --parallel build test\ntask --dry-run deploy\ntask setup -...`

#### tcc (tinycc)
**Purpose**: Tiny C Compiler for fast C compilation and execution, supports runtime compilation
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `tcc hello.c\ntcc -o hello hello.c\ntcc -run hello.c args\ntcc -E hello.c\ntcc -c hello.c...`

#### telegraf (monitoring)
**Purpose**: Agent for collecting and reporting metrics from systems, applications, and sensors
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `telegraf --input-list\ntelegraf --config telegraf.conf\ntelegraf --test\ntelegraf --config-directory...`

#### terraform (terraform)
**Purpose**: Infrastructure as Code with state management, preventing configuration drift through declarative syntax
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `terraform plan -out=changes.tfplan\nterraform apply changes.tfplan\nterraform import aws_instance.we...`

#### terragrunt (terragrunt)
**Purpose**: Keep your Terraform code DRY - provides configuration management, remote state management, and dependency handling for multiple Terraform modules
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `terragrunt init\nterragrunt plan\nterragrunt apply\nterragrunt run-all apply...`

#### tflint (tflint)
**Purpose**: Pluggable Terraform linter that finds possible errors and enforces best practices for AWS, Azure, GCP providers
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `tflint\ntflint --init\ntflint --config=.tflint.hcl\ntflint --recursive...`

#### tfsec (tfsec)
**Purpose**: Static analysis security scanner for Terraform code - uses static analysis of Terraform templates to spot potential misconfigurations
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `tfsec .\ntfsec --format json\ntfsec --exclude AWS001\ntfsec --config-file tfsec.yml...`

#### tig (git-extras)
**Purpose**: Text-mode interface for Git with powerful browsing, searching, and commit visualization
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `tig # Browse repository history\ntig status # Interactive staging area\ntig blame file.txt # Blame v...`

#### tiny-impdef (tinycc)
**Purpose**: Generate import definition files (.def) from DLL files for TinyCC linking
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `tiny_impdef library.dll\ntiny_impdef -o custom.def library.dll\ntiny_impdef kernel32.dll...`

#### tldr (tealdeer)
**Purpose**: Lightning-fast tldr client in Rust - get quick examples for any command with beautiful syntax highlighting
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `tldr ls\ntldr --update\ntldr --list\ntldr -p linux tar\ntldr --random...`

#### tokei (tokei)
**Purpose**: Display statistics about code, including lines of code, comments, and blanks by language
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `tokei .\ntokei --files src/\ntokei --output json .\ntokei --exclude '*.test.js' .\ntokei --sort line...`

#### tre (tre)
**Purpose**: Tree command improved with editor aliases, portable paths and deterministic output
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `tre\ntre -e (editor aliases)\ntre -p (portable)\ntre -E pattern (exclude)\ntre -L 3 (depth limit)...`

#### treesitter-parse (treesitter)
**Purpose**: Self-contained tree-sitter parser with embedded Python + 26 languages (NO external dependencies)
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `treesitter-parse python script.py # Parse Python with structure analysis\ntreesitter-parse bash scri...`

#### treesitter-parse-fallback (treesitter)
**Purpose**: Fallback parser (requires system Python or micromamba)
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `treesitter-parse-fallback python script.py # Use if embedded version fails...`

#### trippy (trippy)
**Purpose**: Advanced network diagnostic tool with TUI, supporting ICMP/UDP/TCP tracing, GeoIP, AS information, and multiple output formats
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `trippy google.com # Interactive TUI trace\ntrippy --mode stream google.com # Stream output\ntrippy -...`

#### trivy (trivy)
**Purpose**: Security scanner with vulnerability detection, secrets scanning, and misconfiguration analysis for containers and K8s
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `trivy config Dockerfile | trivy image nginx:latest | trivy fs --security-checks vuln,secret ....`

#### trufflehog (trufflehog)
**Purpose**: Find and verify secrets across multiple data sources - scans git repositories, filesystems, and cloud storage for exposed credentials
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `trufflehog git https://github.com/user/repo.git\ntrufflehog filesystem .\ntrufflehog github --org tr...`

#### tshark (wireshark-cli)
**Purpose**: Network protocol analyzer - command line version of Wireshark
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `tshark -i interface -w output.pcap\ntshark -i eth0 -c 100 -w capture.pcap\ntshark -r capture.pcap -T...`

#### unlink (path-utils)
**Purpose**: Remove single file or symbolic link using UNIX-style unlink operation
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `unlink file.txt\nunlink symlink\nunlink /tmp/tempfile...`

#### upx (upx)
**Purpose**: Compress executables and shared libraries to reduce file size while maintaining functionality
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `upx program.exe\nupx --best program.exe\nupx -d packed.exe\nupx -t packed.exe\nupx --info packed.exe...`

#### vegeta (vegeta)
**Purpose**: Versatile HTTP load testing tool with attack/report modes - supports custom headers, bodies, and detailed metrics reporting
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `echo 'GET http://localhost:8080' | vegeta attack -rate=100 -duration=30s | vegeta report\nvegeta att...`

#### vhs (vhs)
**Purpose**: Write terminal GIFs as code using a simple scripting language - record, edit and share beautiful terminal demos
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `vhs demo.tape\nvhs new demo.tape\nvhs --output demo.gif demo.tape\nvhs --shell bash demo.tape...`

#### viu (viu)
**Purpose**: Simple terminal image viewer written in Rust - displays images directly in terminal with ANSI colors and Unicode block characters
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `viu image.png\nviu -t image.png\nviu --width 80 image.jpg\nviu --static image.gif...`

#### vol (volatility)
**Purpose**: Extract digital artifacts from volatile memory (RAM) dumps for forensic analysis
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `vol -f memory.dmp imageinfo\nvol -f memory.dmp --profile=Win10x64 pslist\nvol -f memory.dmp --profil...`

#### volumeid64 (sysinternals)
**Purpose**: Display or change the volume serial number of FAT and NTFS drives
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `VolumeId64 C: # Show volume ID for C:\nVolumeId64 C: 1234-ABCD # Set new volume ID\nVolumeId64 # Sho...`

#### watchexec (watchexec)
**Purpose**: File system watcher that executes commands when files change - supports filters and debouncing
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `watchexec 'echo changed'\nwatchexec -w src 'cargo build'\nwatchexec --restart 'python app.py'\nwatch...`

#### whois64 (sysinternals)
**Purpose**: Perform WHOIS lookups to retrieve domain registration and IP address information
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `whois64 example.com # Domain WHOIS lookup\nwhois64 192.168.1.1 # IP address lookup\nwhois64 -v examp...`

#### windmc (path-utils)
**Purpose**: Windows Message Compiler for creating message resource files from text definitions
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `windmc messages.mc\nwindmc -h include_dir messages.mc\nwindmc -r res_dir messages.mc...`

#### windres (path-utils)
**Purpose**: Windows Resource Compiler for converting resource files to object format
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `windres resource.rc resource.o\nwindres -i input.rc -o output.o\nwindres --define MACRO=VALUE resour...`

#### wlan-helper (nmap)
**Purpose**: Wireless network helper utility for WiFi adapter management and configuration
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `WlanHelper.exe --scan\nWlanHelper.exe --monitor-mode\nWlanHelper.exe --list-adapters\nWlanHelper.exe...`

#### wrk (wrk)
**Purpose**: High-performance HTTP load testing tool with goroutine-based concurrency and SSL/TLS support for web application benchmarking
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `wrk -c 100 -d 30 http://example.com...`

#### xh (xh)
**Purpose**: Friendly and fast tool for sending HTTP requests with HTTPie-compatible syntax and curl translation
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `xh GET httpbin.org/json\nxh POST httpbin.org/post name=John age:=25\nxh --print=HhBb GET httpbin.org...`

#### xsv (xsv)
**Purpose**: High-performance CSV toolkit for processing large CSV files with commands for stats, search, join, split, and format conversion
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `xsv stats data.csv...`

#### yajsv (yajsv)
**Purpose**: Yet Another JSON Schema Validator - fast and simple JSON Schema validation tool
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `yajsv -s schema.json data.json\nyajsv -s schema.json data1.json data2.json\necho '{"name":"test"}' |...`

#### yara32 (yara)
**Purpose**: Scan files and processes using YARA rules to identify malware and suspicious patterns
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `yara32 rules.yar suspicious_file.exe\nyara32 -r rules.yar /path/to/scan\nyara32 -p 1234 rules.yar\ny...`

#### yarac32 (yara)
**Purpose**: Compile YARA rules into binary format for faster scanning and distribution
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `yarac32 rules.yar rules.yarc\nyarac32 -d symbol=value rules.yar\nyarac32 -n namespace rules.yar\nyar...`

#### yazi (yazi)
**Purpose**: Async terminal file manager with image preview, fuzzy search, and customizable interface
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `yazi\nyazi --help\nyazi /path/to/directory\nyazi --debug...`

#### yozefu (yozefu)
**Purpose**: Interactive TUI application for exploring data of a Kafka cluster with SQL-like filtering
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `yozefu --broker localhost:9092 | yozefu --config config.toml | yozefu --headless --query 'SELECT * F...`

#### yq (yq)
**Purpose**: Portable YAML processor with jq-like syntax supporting multiple formats (YAML, JSON, XML, CSV, TSV, properties)
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `yq '.name' config.yaml\nyq -i '.version = "2.0"' config.yaml\nyq -o json config.yaml\nyq '.servers[]...`

#### zig (zig)
**Purpose**: Zig compiler and build system with C/C++ interop, cross-compilation, and compile-time execution
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `zig build # Build project using build.zig\nzig run main.zig # Compile and run directly\nzig test src...`

#### zoxide (zoxide)
**Purpose**: Smart directory navigation that remembers frequently used directories for instant jumping with fuzzy matching
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `zoxide add /path/to/dir...`

#### zstd (zstd)
**Purpose**: High-performance compression tool with excellent speed-to-compression ratio balance
**Parameters**: 🟡 Unknown parameter types
**Returns**: ⚪ Unknown output
**Conversion Priority**: 🟡 REVIEW
**Usage Example**: `zstd file.txt\nzstd -d file.txt.zst\nzstd -19 file.txt\nzstd -c file.txt > compressed.zst\nzstd -r d...`

