# PORTX Development TODO

## Phase 1: Taxonomy & Standards (Foundation) ✅
- [x] **Document 4-dimensional taxonomy standards** - Created `standards-tags.md` with comprehensive taxonomy system (Purpose, Domain, Runtime, Target)
- [ ] **Apply taxonomy to ALL 400+ tools** - Systematically tag all tools across 106 packages using the research-based classification system

## Phase 2: Core System Improvements  
- [ ] **Enhanced package listing** - Improve `portx packages list` with proper formatting, tags display, and rich descriptions
- [ ] **Fix verify issues** - Resolve all problems found by `portx packages verify` from previous debugging
- [ ] **Update documentation** - Document the portx logic, taxonomy system, and usage patterns

## Phase 3: AI Integration
- [ ] **Ollama AI wrapper** - Create intelligent tool discovery system that sends tool list, context, and user questions to Ollama for smart recommendations

## Phase 4: Critical Development Tools
- [ ] **Add essential runtimes** - Java, C/C++ compiler, **Node.js (CRITICAL for Claude Code)**
- [ ] **Add build systems** - Maven, Gradle, and other essential build tools  
- [ ] **Add powerful linters** - ESLint, Pylint, Checkstyle, SpotBugs for Java/JavaScript/Python

## Phase 5: Git Environment Optimization  
- [ ] **Replace portable git with MinGit** - Swap out current portable git executables for MinGit versions
- [ ] **CRITICAL: Redesign package architecture with proper DLL dependency management** - Current design flaw: executables copied without matching runtime DLLs cause compatibility issues (TTY detection failures, etc.)

## Detailed Tasks

### Taxonomy Application
- [ ] Apply 4-dimensional tags to security tools (yara, nuclei, nmap, etc.)
- [ ] Apply tags to development tools (git, docker, kubectl, terraform)
- [ ] Apply tags to code analysis tools (ast-grep, rg, shellcheck, scc)
- [ ] Apply tags to system tools (sysinternals, bottom, btop, bandwhich)
- [ ] Apply tags to media tools (ffmpeg suite)
- [ ] Apply tags to cloud tools (aws, azure-cli, kubectl, helm)
- [ ] Apply tags to network tools (nmap, rustscan, gping, httpx)
- [ ] Apply tags to Unix utilities (gitsdk-usr-bin 200+ tools)

### Package System Enhancements
- [ ] Update `portx packages list` to show tags in formatted output
- [ ] Add tag filtering: `portx packages list --tags purpose:analyze`
- [ ] Add description formatting and better tool discovery
- [ ] Fix all wrapper testing issues from verify command

### AI Integration Development
- [ ] Design Ollama API integration for tool discovery
- [ ] Create context-aware tool recommendation system
- [ ] Implement natural language tool queries
- [ ] Add examples and usage suggestions from AI

### Critical Package Additions
- [ ] **Node.js** - Essential for Claude Code and modern development
- [ ] **Java JDK** - Core Java development environment
- [ ] **GCC/MinGW-w64** - C/C++ compilation capabilities
- [ ] **Maven** - Java project management and build
- [ ] **Gradle** - Modern build automation
- [ ] **ESLint** - JavaScript/TypeScript linting (critical)
- [ ] **Pylint/Black** - Python code quality tools
- [ ] **Checkstyle/SpotBugs** - Java static analysis

### Git Environment Cleanup
- [ ] Identify all portable git executables currently included
- [ ] Source MinGit equivalents 
- [ ] Replace portable git binaries with MinGit versions
- [ ] Update package dependencies and paths
- [ ] Test git functionality with MinGit replacements

### CRITICAL: Layered Package Architecture Redesign
- [x] **Test MinGW executables first** - ✅ VERIFIED: /mingw64/bin executables are perfectly clean (no MSYS2 dependencies, only Windows system DLLs + bundled MinGW libraries)
- [x] **Remove gitsdk-mingw64-bin package** - ✅ COMPLETED: Removed redundant package (53 tools 100% duplicate with existing PortableGit installation)
- [ ] **Analyze gitsdk-usr-bin package** - Investigate 279 tools for MSYS2 dependencies and redundancies with existing PORTX packages
- [ ] **Create gitportable-usr-bin package** - Compare MinGit vs PortableGit, package differences with PortableGit executables + their matching DLL dependencies
- [ ] **Create gitsdk-usr-bin package** - Compare (MinGit + PortableGit) vs GitSDK, package differences with GitSDK executables + their matching DLL dependencies  
- [ ] **Self-contained packages** - Each package must include executables AND their specific runtime DLLs to prevent compatibility issues
- [ ] **Remove current broken gitsdk-usr-bin** - Replace with properly designed layered packages
- [ ] **Test compatibility** - Ensure each layer works without DLL conflicts or TTY detection issues

## Priority Order
1. **CRITICAL**: Redesign package architecture with proper DLL dependency management
2. **IMMEDIATE**: Complete taxonomy application to existing tools  
3. **HIGH**: Add Node.js package (critical for Claude Code)
4. **HIGH**: Fix portx packages verify issues
5. **MEDIUM**: Enhance package listing and add AI wrapper
6. **MEDIUM**: Add remaining development tools and linters
7. **LOW**: Replace portable git with MinGit

## Success Metrics
- All 400+ tools properly tagged with 4-dimensional taxonomy
- `portx packages list` shows rich, filterable tool information
- AI assistant can effectively recommend tools based on user queries
- All critical development environments (Node.js, Java, C++) available
- Zero failures in `portx packages verify`
- MinGit integration maintains full git functionality

---
*This TODO reflects the comprehensive PORTX enhancement plan for creating an AI-enhanced portable development environment.*