# PORTX Tool Testing Report

**Generated:** 2025-08-03 16:09:07  
**PORTX Root:** C:/App/PORTX

## 📊 Summary Statistics

| Metric | Count | Percentage |
|--------|-------|------------|
| **Total Tools** | 172 | 100% |
| **Working Tools** | 141 | 81% |
| **Broken Tools** | 31 | 18% |
| **Missing Tools** | 0 | 0% |

**Success Rate:** 81%

⚠️ **Status: Moderate Issues** - Success rate below 85%. Several packages need attention.

## 📂 Results by Category

### Working Tools by Category

- **Package-7zip:** 1 tools
- **Package-ag:** 1 tools
- **Package-age:** 2 tools
- **Package-android-tools:** 6 tools
- **Package-aws:** 2 tools
- **Package-azure-cli:** 2 tools
- **Package-bat:** 1 tools
- **Package-bottom:** 1 tools
- **Package-btop:** 1 tools
- **Package-clamav:** 1 tools
- **Package-docker-compose:** 1 tools
- **Package-far:** 1 tools
- **Package-fd:** 1 tools
- **Package-fx:** 1 tools
- **Package-fzf:** 1 tools
- **Package-git-extras:** 5 tools
- **Package-gitui:** 1 tools
- **Package-glow:** 1 tools
- **Package-gpg:** 5 tools
- **Package-gping:** 1 tools
- **Package-hashdeep:** 12 tools
- **Package-helix:** 1 tools
- **Package-helm:** 1 tools
- **Package-helmfile:** 1 tools
- **Package-httpx:** 1 tools
- **Package-jq:** 1 tools
- **Package-k6:** 1 tools
- **Package-k8:** 2 tools
- **Package-k9s:** 1 tools
- **Package-lazydocker:** 1 tools
- **Package-lazygit:** 1 tools
- **Package-lazysql:** 1 tools
- **Package-micro:** 1 tools
- **Package-minikube:** 1 tools
- **Package-monitoring:** 2 tools
- **Package-navi:** 1 tools
- **Package-nircmd:** 2 tools
- **Package-nuclei:** 1 tools
- **Package-openshift:** 1 tools
- **Package-osquery:** 3 tools
- **Package-peco:** 1 tools
- **Package-rclone:** 1 tools
- **Package-ripgrep:** 1 tools
- **Package-rustscan:** 1 tools
- **Package-scrcpy:** 2 tools
- **Package-sd:** 1 tools
- **Package-skopeo:** 1 tools
- **Package-ssdeep:** 1 tools
- **Package-subfinder:** 1 tools
- **Package-sysinternals:** 16 tools
- **Package-terraform:** 1 tools
- **Package-usql:** 1 tools
- **Package-yara:** 2 tools
- **Package-yq:** 1 tools
- **PORTX-Core:** 38 tools

### 🚨 Broken Tools by Category

#### Package-android-tools (1 broken)

- **hprof-conv** - Timeout or execution error

#### Package-azure-cli (1 broken)

- **pip** - Timeout or execution error

#### Package-bandwhich (1 broken)

- **bandwhich** - Timeout or execution error

#### Package-clamav (9 broken)

- **clambc** - Timeout or execution error
- **clamconf** - Timeout or execution error
- **clamd** - Timeout or execution error
- **clamdscan** - Timeout or execution error
- **clamdtop** - Timeout or execution error
- **clamscan** - Timeout or execution error
- **clamsubmit** - Timeout or execution error
- **freshclam** - Timeout or execution error
- **sigtool** - Timeout or execution error

#### Package-postman (1 broken)

- **newman** - Timeout or execution error

#### Package-skopeo (1 broken)

- **gpgme-w32spawn** - Timeout or execution error

#### Package-sysinternals (13 broken)

- **accesschk64** - Timeout or execution error
- **Contig64** - Timeout or execution error
- **FindLinks64** - Timeout or execution error
- **handle64** - Timeout or execution error
- **hex2dec64** - Timeout or execution error
- **LogonSessions64** - Timeout or execution error
- **procdump64** - Timeout or execution error
- **PsExec64** - Timeout or execution error
- **pskill64** - Timeout or execution error
- **psping64** - Timeout or execution error
- **streams64** - Timeout or execution error
- **VolumeId64** - Timeout or execution error
- **whois64** - Timeout or execution error

#### Package-tinycc (3 broken)

- **tcc** - Timeout or execution error
- **tiny_impdef** - Timeout or execution error
- **tiny_libmaker** - Timeout or execution error

#### PORTX-Core (1 broken)

- **git-bash** - Timeout or execution error

## 🔍 Analysis & Recommendations

### Recommendations

1. **Review broken tools list** above for specific error messages
2. **Check package documentation** in `bin-tools/*/package-manual.md`
3. **Verify dependencies** - especially for MSYS2 tools (DLL files)
4. **Consider alternatives** from working categories
5. **For SysInternals tools** - some require `-accepteula` flag on first run
6. **For ClamAV tools** - may need configuration files

