# PORTX Development Standards
## Technical Decision Records

**Version:** 2.0  
**Last Updated:** August 25, 2025

---

## DS-001: Use PORTX Tools Exclusively

**Decision:** All PORTX development must use only PORTX-provided tools for analysis, formatting, and validation.

**Tools:** shellcheck, shfmt, ast-grep, scc, ripgrep, ctags, bat for all development work.

**Rationale:** Validates our own toolchain and ensures consistent quality.

---

## DS-002: No Hardcoded Values

**Decision:** No hardcoded counts, paths, versions, or configuration values in any code.

**Examples Prohibited:**
- Tool counts (`104 packages`)
- Absolute paths (`/c/App/Git`)  
- Version numbers in scripts
- UI text with specific numbers

**Required:** Dynamic detection, environment variables, configuration files, runtime calculation.

---

## DS-003: Mandatory Theme System Usage

**Decision:** All user-facing output must use the unified theme system.

**Required Functions:** `color_success()`, `color_error()`, `color_warning()`, `color_primary()`, `color_reset()`

**Prohibited:** 
- Direct ANSI escape codes (`\033[91m`)
- Hardcoded colors or formatting
- Icons, symbols, emojis (✓ ❌ 🎉 ⚠️)
- Unicode box drawing characters (╔ ║ ╚)
- Decorative elements or "stupid shit"

**Required:** Clean, professional text output using theme.sh functions only

**Examples:**
```bash
# ✅ CORRECT
printf "%sCRITICAL ERROR: Missing executable file%s\n" "$(color_error)" "$(color_reset)"
printf "%sAll %d executables verified%s\n" "$(color_success)" "$count" "$(color_reset)"

# ❌ WRONG  
printf "\033[91mCRITICAL ERROR\033[0m\n"  # Hardcoded
printf "✓ All %d executables verified\n" "$count"  # Icons
printf "╔══════════════════════╗\n"  # Box drawing
```

---

## DS-004: Never Modify Signed Executables

**Decision:** No modification of Git for Windows signed binaries.

**Method:** Profile-based configuration via `/etc/profile` modifications only.

**Prohibited:** Copying, renaming, or modifying `sh.exe`, `bash.exe`, or any signed executables.

---

## DS-005: Industry-Standard Package Format

**Decision:** All packages use `portx.json` format with complete metadata.

**Required Fields:**
- `name`, `version`, `description`
- `importType` (auto/wrap/path/exclude)
- `tools` array with executable, description, usage, dependencies
- `packageDependencies` classification

**Standard:** npm-compatible format.

---

## DS-006: Smart Import Type Logic

**Decision:** Import type determined by systematic analysis, not arbitrary choice.

**Rules:**
- Single executable, no dependencies → `wrap`
- Multiple executables, no dependencies → `wrap`
- DLL dependencies present → `path`
- 50+ executables → `path`
- GUI-only tools → `exclude`

---

## DS-007: Git Extensions Architecture

**Decision:** Modular packages bridge MinGit to full Git functionality.

**Requirements:**
- Source only from Git for Windows (not MSYS2)
- Flat directory structure (all executables in package root)
- Zero conflicts with MinGit or existing PORTX packages
- `importType: "path"` for all Git Extensions

**Packages:** `git-mingw64-bin-ext` (32 tools), `git-usr-bin-ext` (171 tools)

---

## DS-008: PATH Optimization

**Decision:** Minimize PATH directories while maintaining functionality.

**Structure:**
1. High priority: Wrapper directories
2. Medium priority: Dependency packages  
3. Low priority: Original system PATH

**Target:** Reduce from 100+ to ~10 optimized directories.

**Conflict Detection:** Required before wrapper creation.

---

## DS-009: Complete Documentation

**Decision:** All functions and architectural decisions must be documented.

**Function Documentation:**
- Purpose, parameters, return values
- PORTX tools used
- Integration requirements
- Usage examples

**Architecture:** Document as decision records with context and rationale.

---

## DS-010: Modular Configuration

**Decision:** All functionality implemented through modular, reversible configuration.

**Structure:**
```
/etc/profile.d/
├── portx-core.sh      # Essential variables
├── portx-tools.sh     # Tool discovery
├── portx-theme.sh     # UI system
└── portx-ssh.sh       # SSH integration
```

**Requirement:** Each module independently removable.

---

## DS-011: Systematic Testing

**Decision:** All changes require functionality, integration, and compatibility testing.

**Testing Types:**
- Functionality: Individual features work
- Integration: Components work together  
- Compatibility: Works across Windows/Git Bash configurations

**Validation:** Tool usage compliance, hardcoding detection, theme integration.

---

## DS-012: Quality Through Tool Usage

**Decision:** Demonstrate achievable quality through systematic tool usage.

**Requirements:**
- Pass shellcheck analysis
- Apply shfmt formatting
- Maintain reasonable scc complexity
- Detect issues with ripgrep patterns

**Purpose:** Validate toolchain credibility and maintain internal quality.

---

## Enforcement

**Status:** Binding for all PORTX development
**Compliance:** Required for code contributions
**Validation:** Through PORTX tools during development