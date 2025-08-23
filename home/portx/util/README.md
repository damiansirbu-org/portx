# PORTX Integrations

System integration tools and utilities for optimizing PORTX performance and compatibility.

## Antivirus Performance Optimization

### 🛡️ Automated Antivirus Exclusion Setup

**Purpose**: Eliminates antivirus scanning interference with PORTX tools, improving performance by 2-5x.

**Files**:
- `Add-PortxAntivirusExclusions.ps1` - PowerShell script for automatic exclusion configuration
- `setup-antivirus-exclusions.bat` - User-friendly launcher with admin privilege handling

### Quick Setup

**Option 1: Automatic (Recommended)**
```cmd
Right-click → setup-antivirus-exclusions.bat → "Run as administrator"
```

**Option 2: PowerShell Direct**
```powershell
# Run PowerShell as Administrator
.\Add-PortxAntivirusExclusions.ps1
```

**Option 3: Silent/Automated**
```powershell
.\Add-PortxAntivirusExclusions.ps1 -Force
```

### Supported Antivirus Products

| Product | Support Level | Method |
|---------|---------------|--------|
| **Windows Defender** | ✅ Full Automation | PowerShell API |
| **Bitdefender** | ⚠️ Partial Automation | Command Line + Manual |
| **Symantec** | 📋 Manual Instructions | Manual Configuration |
| **McAfee** | 📋 Manual Instructions | Manual Configuration |
| **Norton** | 📋 Manual Instructions | Manual Configuration |

### What Gets Excluded

**Directories**:
- `C:\App\PORTX\` (main installation)
- `C:\App\PORTX\bin\` (core utilities)
- `C:\App\PORTX\bin-ext\` (enhanced tools)
- `C:\App\PORTX\bin-tools\` (professional suite)
- `C:\App\PORTX\mingw64\` (MinGW toolchain)
- `C:\App\PORTX\usr\` (Unix utilities)

**Processes**:
- `bash.exe` (shell environment)
- `git.exe` (version control)
- `sh.exe` (shell scripts)
- `portsh.exe` (PORTX shell)
- `mingw32-make.exe` (build tools)
- `gcc.exe`, `g++.exe` (compilers)

**Extensions**:
- `.sh` (shell scripts)
- `.exe` (executables)
- `.dll` (libraries)
- `.so` (shared objects)

### Performance Impact

**Before Exclusions**:
- Git operations: 5-15 seconds
- Shell startup: 3-10 seconds
- Tool execution: 1-5 second delays

**After Exclusions**:
- Git operations: 1-3 seconds
- Shell startup: <1 second
- Tool execution: Near-instant

### Security Considerations

**Safe Exclusions**: PORTX tools are:
- Digitally signed where applicable
- From trusted sources (Git for Windows, official repositories)
- Portable (no system modifications)
- Enterprise-approved components

**Risk Mitigation**:
- Exclusions are path-specific, not global
- No exclusion of user data directories
- Process exclusions limited to known tools
- Regular security updates maintained

### Enterprise Deployment

**Group Policy**: Use provided PowerShell script in startup scripts
**SCCM/Intune**: Deploy as configuration item
**Manual Rollout**: Distribute batch file to users

### Troubleshooting

**Common Issues**:
1. **Admin Rights**: Script requires administrator privileges
2. **Execution Policy**: May need PowerShell execution policy adjustment
3. **Third-party AV**: Some products require manual configuration

**Validation**:
```powershell
# Check Windows Defender exclusions
Get-MpPreference | Select-Object ExclusionPath, ExclusionProcess
```

### Manual Configuration Fallback

If automatic setup fails, manually add these paths to your antivirus exclusions:

1. Open your antivirus console
2. Navigate to Exclusions/Exceptions settings
3. Add folder exclusions for all PORTX directories
4. Add process exclusions for core executables
5. Save configuration and restart PORTX

### Additional Performance Tips

After configuring exclusions, run:
```bash
git config --global core.fscache true
git config --global core.preloadindex true
```

For maximum Git performance optimization.

## 🖱️ Windows Explorer Context Menu

### Quick Setup
```cmd
Right-click → register-context-menu.bat → "Run as administrator"
```

**Features**:
- Right-click any folder → "Open PORTX here"
- Works on folder background, folder icons, and drive letters
- **Smart Icon Detection**: Uses `portx.ico` if available, falls back to `git-bash.exe`
- **Dynamic Path Detection**: Auto-detects PORTX installation location
- **Wrapper Support**: Prefers `portx-wrapper.exe` over `portx.cmd`
- Clean uninstall option

**Registry Integration**:
- Adds context menu to all folder types and drive letters
- Uses optimal PORTX icon for visual consistency
- Automatically detects best launcher executable
- Professional "Open PORTX here" menu entry

## 🔧 IDE & Tools Integration

For complete IDE integration instructions, see: **[IDE-Integration-Guide.md](IDE-Integration-Guide.md)**

**Supported IDEs**: VS Code, JetBrains (IntelliJ, WebStorm, PyCharm), Eclipse, Sublime Text, Notepad++

**Terminal Apps**: Windows Terminal, ConEmu, Cmder with full PORTX profile integration