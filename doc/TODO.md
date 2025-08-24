# PORTX Development TODO
**By Damian Sirbu**

## 🚨 Critical Issues

### ClamAV Antivirus Fix
- **Status**: ❌ BROKEN
- **Issue**: `clamscan.exe` fails to run (dependency/library issues)
- **Impact**: No antivirus scanning capability
- **Priority**: HIGH
- **Action Required**: 
  - Debug missing DLL dependencies
  - Test with fresh ClamAV Windows build
  - Consider alternative: Windows Defender integration
  - Verify virus definition updates work

## 🛡️ Security Tools Expansion

### Missing Antivirus/Anti-malware Tools
Research and consider adding comprehensive security suite:
- **Windows Defender CLI** - Native Windows antivirus interface
- **ESET Online Scanner** - Portable antivirus scanner
- **Malwarebytes CLI** - Anti-malware command line
- **Sophos Scan CLI** - Enterprise antivirus scanner
- **Bitdefender Scanner** - Command line virus scanner
- **F-Secure CLI** - Security scanning tools
- **Trend Micro Scanner** - Portable malware detection
- **Kaspersky Rescue Tool** - Malware removal utility

### Missing Anti-spyware/Anti-hijack Tools
- **AdwCleaner CLI** - Adware/PUP removal
- **RootkitRevealer** - Rootkit detection (Microsoft Sysinternals)
- **Malwarebytes Anti-Rootkit** - Advanced rootkit removal
- **GMER** - Rootkit detector and remover
- **RKill** - Malware process terminator
- **ComboFix** - Malware removal tool
- **HijackThis** - Browser hijack analyzer
- **Spybot S&D CLI** - Spyware detection and removal

## 🔒 Security & Analysis Tools to Add

### Code Security Analysis
| Tool | Status | Category | Purpose |
|------|--------|----------|---------|
| **semgrep.exe** | ➕ NEEDED | Security | Static analysis security scanner |
| **grype.exe** | ➕ NEEDED | Security | Vulnerability scanner for containers |
| **syft.exe** | ➕ NEEDED | Security | SBOM generation tool |
| **snyk.exe** | ➕ NEEDED | Security | Developer security platform |
| **osv-scanner.exe** | ➕ NEEDED | Security | OSV vulnerability database scanner |
| **trufflehog.exe** | ➕ NEEDED | Security | Secret detection in Git repositories |
| **gitleaks.exe** | ➕ NEEDED | Security | Git secret scanner |
| ~~nuclei.exe~~ | ✅ HAVE | Security | Vulnerability scanner (v3.2.0) |

### Kubernetes Security
| Tool | Status | Category | Purpose |
|------|--------|----------|---------|
| **kubesec.exe** | ➕ NEEDED | Kubernetes | Security risk analysis for K8s resources |
| **kube-score.exe** | ➕ NEEDED | Kubernetes | K8s object analysis for security/reliability |
| **kubeval.exe** | ➕ NEEDED | Kubernetes | K8s manifest validation |
| **polaris.exe** | ➕ NEEDED | Kubernetes | K8s best practices validation |
| **conftest.exe** | ➕ NEEDED | Kubernetes | Policy testing with Open Policy Agent |
| **datree.exe** | ➕ NEEDED | Kubernetes | K8s policy enforcement |
| **kics.exe** | ➕ NEEDED | Kubernetes | Infrastructure security scanner |

### Infrastructure Security
| Tool | Status | Category | Purpose |
|------|--------|----------|---------|
| **terrascan.exe** | ➕ NEEDED | Infrastructure | Terraform security scanner |
| **tflint.exe** | ➕ NEEDED | Infrastructure | Terraform linter |
| **checkov.exe** | ➕ NEEDED | Infrastructure | IaC security scanner |

### Container Security
| Tool | Status | Category | Purpose |
|------|--------|----------|---------|
| **hadolint.exe** | ➕ NEEDED | Containers | Dockerfile linter |
| **dockle.exe** | ➕ NEEDED | Containers | Container image security scanner |
| **dive.exe** | ➕ NEEDED | Containers | Docker image layer explorer |

### Language-Specific Security
| Tool | Status | Category | Purpose |
|------|--------|----------|---------|
| **shellcheck.exe** | ➕ NEEDED | Languages | Shell script static analysis |
| **shfmt.exe** | ➕ NEEDED | Languages | Shell script formatter |
| **golangci-lint.exe** | ➕ NEEDED | Languages | Go linter aggregator |
| **staticcheck.exe** | ➕ NEEDED | Languages | Go static analysis |
| **revive.exe** | ➕ NEEDED | Languages | Go linter |

### Web Security
| Tool | Status | Category | Purpose |
|------|--------|----------|---------|
| ~~httpx.exe~~ | ✅ HAVE | Web | HTTP toolkit for security testing |
| ~~subfinder.exe~~ | ✅ HAVE | Web | Subdomain discovery |
| **gospider.exe** | ➕ NEEDED | Web | Web crawler for security testing |
| **katana.exe** | ➕ NEEDED | Web | Next-gen crawling framework |

### Documentation & Analysis
| Tool | Status | Category | Purpose |
|------|--------|----------|---------|
| **vale.exe** | ➕ NEEDED | Docs | Prose linter for documentation |
| **binskim.exe** | ➕ NEEDED | Docs | Binary analysis tool |

## 📁 Proposed Directory Structure

Create organized security tool hierarchy:
```
bin-tools/
├── security/
│   ├── code-analysis/
│   │   ├── semgrep.exe
│   │   ├── snyk.exe
│   │   ├── osv-scanner.exe
│   │   ├── trufflehog.exe
│   │   └── gitleaks.exe
│   ├── container-security/
│   │   ├── grype.exe
│   │   ├── syft.exe
│   │   ├── hadolint.exe
│   │   ├── dockle.exe
│   │   └── dive.exe
│   ├── k8s-security/
│   │   ├── kubesec.exe
│   │   ├── kube-score.exe
│   │   ├── kubeval.exe
│   │   ├── polaris.exe
│   │   ├── conftest.exe
│   │   ├── datree.exe
│   │   └── kics.exe
│   ├── infrastructure/
│   │   ├── terrascan.exe
│   │   ├── tflint.exe
│   │   └── checkov.exe
│   ├── web-security/
│   │   ├── gospider.exe
│   │   └── katana.exe
│   └── antivirus/
│       └── [fixed-clamav-tools]
├── languages/
│   ├── shell/
│   │   ├── shellcheck.exe
│   │   └── shfmt.exe
│   └── go/
│       ├── golangci-lint.exe
│       ├── staticcheck.exe
│       └── revive.exe
└── docs/
    ├── vale.exe
    └── binskim.exe
```

## 🖥️ TUI Wiki System (Major Enhancement Needed)

### Current Status: ⚠️ Basic but Needs Major Improvement
- ✅ **Enhanced portx command** - Basic interactive system
- ✅ **Manual directory structure** - Organized categories  
- ✅ **Glow integration** - v2.1.1 with clean ASCII styling
- ❌ **Missing Main Menu** - No central navigation hub
- ❌ **No Category Browser** - Can't easily browse tool categories
- ❌ **Limited Search** - No integrated wiki search functionality
- ❌ **Poor Navigation** - No breadcrumbs or easy back/forward

### Critical Wiki Improvements Needed
1. **Main Menu Interface** - Create proper wiki home page with:
   - Category overview with tool counts
   - Quick access buttons/links
   - Search functionality
   - Recent/popular tools section

2. **Enhanced Navigation System**:
   - Breadcrumb navigation (Home > Category > Tool)
   - Back/Forward buttons or hotkeys
   - Category browser with descriptions
   - Cross-references between related tools

3. **Integrated Search Engine**:
   - Real-time search across all documentation
   - Search results with context snippets
   - Filter by category, tool type, or version
   - Search history and suggestions

4. **Better User Experience**:
   - Loading indicators for large operations
   - Help system with keyboard shortcuts
   - Bookmarking favorite tools/sections
   - Recent history navigation

2. **Complete manual categories** - Create remaining category files:
   - `manual/categories/security.md`
   - `manual/categories/development.md` 
   - `manual/categories/monitoring.md`
   - `manual/categories/database.md`
   - `manual/categories/mobile.md`
   - `manual/categories/files.md`
   - `manual/categories/testing.md`
   - `manual/categories/modern-unix.md`
   - `manual/categories/gnu-linux.md`

3. **Individual tool pages** - Create `manual/tools/*.md` for popular tools
4. **Guides section** - Create getting started, troubleshooting guides

## 🔄 Implementation Priority

### Phase 1 (Immediate - Critical Wiki & Security)
1. **Major Wiki Enhancement** - Implement proper navigation and search
2. **Fix ClamAV** - Restore antivirus functionality  
3. **Add semgrep** - Critical code security analysis
4. **Add gitleaks/trufflehog** - Prevent secret leaks
5. **Add shellcheck** - Shell script security

### Phase 2 (High Priority - Container/K8s Security)
1. **Container security**: grype, syft, hadolint, dockle
2. **K8s security**: kubesec, kube-score, polaris
3. **Infrastructure**: terrascan, tflint, checkov

### Phase 3 (Medium Priority - Extended Security)
1. **Web security**: gospider, katana
2. **Language tools**: Go linting suite
3. **Documentation**: vale, binskim

### Phase 4 (Future - Comprehensive Antivirus)
1. **Research additional antivirus solutions**
2. **Add anti-spyware/anti-hijack tools**
3. **Integration with Windows Defender**

## 📋 Action Items

- [ ] Debug and fix ClamAV dependencies
- [ ] Research Windows-compatible builds for each tool
- [ ] Create security tool installation script
- [ ] Update .bashrc_tools with new directories
- [ ] Test all new tools for Windows compatibility
- [ ] Update MANUAL.md with new security categories
- [ ] Update README.md tool counts
- [ ] Create security-focused documentation

## 🎯 Success Metrics

- **ClamAV restored**: Antivirus scanning functional
- **Tool count increase**: From 494 to 520+ tools
- **Security coverage**: Comprehensive DevSecOps toolkit
- **Compatibility**: >99% tool success rate maintained
- **Documentation**: Complete manual coverage for all new tools

---
*Last Updated: [Current Date] - PORTX Development Team*