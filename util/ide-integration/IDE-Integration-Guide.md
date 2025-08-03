# PORTX IDE & Tools Integration Guide

Complete guide for integrating PORTX with popular development environments and tools.

## 🖱️ Windows Explorer Context Menu

### Quick Setup
```cmd
Right-click → register-context-menu.bat → "Run as administrator"
```

**Features**:
- Right-click any folder → "Open PORTX here"
- Works on folder background, folder icons, and drive letters
- Automatic PORTX path detection
- Clean uninstall option

## 🔧 IDE Integration Configurations

### Visual Studio Code

**Method 1: Integrated Terminal (Recommended)**
```json
// settings.json
{
    "terminal.integrated.defaultProfile.windows": "PORTX",
    "terminal.integrated.profiles.windows": {
        "PORTX": {
            "path": "C:\\App\\PORTX\\portx.cmd",
            "args": [],
            "icon": "terminal-bash"
        }
    }
}
```

**Method 2: External Terminal**
```json
// settings.json
{
    "terminal.external.windowsExec": "C:\\App\\PORTX\\portx.cmd"
}
```

**Method 3: Task Configuration**
```json
// .vscode/tasks.json
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Open PORTX Terminal",
            "type": "shell",
            "command": "C:\\App\\PORTX\\portx.cmd",
            "group": "build",
            "presentation": {
                "echo": false,
                "reveal": "always",
                "focus": true,
                "panel": "new"
            }
        }
    ]
}
```

### JetBrains IDEs (IntelliJ, WebStorm, PyCharm, etc.)

**Terminal Integration**:
1. Go to **File** → **Settings** → **Tools** → **Terminal**
2. Set **Shell path** to: `C:\App\PORTX\portx.cmd`
3. Set **Tab name** to: `PORTX`

**External Tools Setup**:
1. Go to **File** → **Settings** → **Tools** → **External Tools**
2. Click **+** to add new tool
3. Configure:
   - **Name**: `Open PORTX Here`
   - **Program**: `C:\App\PORTX\portx.cmd`
   - **Arguments**: `--cd=$ProjectFileDir$`
   - **Working directory**: `$ProjectFileDir$`

### Eclipse IDE

**Terminal Integration**:
1. Go to **Window** → **Preferences** → **Terminal** → **Local**
2. Set **Initial working directory** to: `${project_loc}`
3. Add new terminal type:
   - **Name**: `PORTX`
   - **Path**: `C:\App\PORTX\portx.cmd`

### Sublime Text

**Build System**:
```json
// Tools → Build System → New Build System
{
    "cmd": ["C:\\App\\PORTX\\portx.cmd", "/c", "$file_base_name"],
    "file_regex": "^(..[^:]*):([0-9]+):?([0-9]+)?:? (.*)$",
    "working_dir": "$file_path",
    "selector": "source.shell",
    "shell": true
}
```

### Notepad++

**Run Commands**:
1. Go to **Run** → **Run...** 
2. Add command: `C:\App\PORTX\portx.cmd --cd="$(CURRENT_DIRECTORY)"`
3. Save as shortcut (e.g., Ctrl+F5)

## 🛠️ Development Tools Integration

### Git Clients

**GitKraken**:
1. **File** → **Preferences** → **General** → **Default Terminal**
2. Set to: `C:\App\PORTX\portx.cmd`

**SourceTree**:
1. **Tools** → **Options** → **General**
2. Set **Terminal** to: `C:\App\PORTX\portx.cmd`

**GitHub Desktop**:
1. **File** → **Options** → **Advanced**
2. Set **Shell** to: `C:\App\PORTX\portx.cmd`

### Docker Desktop

**Settings Integration**:
1. Open Docker Desktop → **Settings** → **General**
2. Enable **Use the WSL 2 based engine** (if using WSL2)
3. Or configure terminal to use PORTX for container access

## 📋 Terminal Applications

### Windows Terminal

**Profile Configuration** (Based on Production Setup):
```json
// Add to profiles.list in settings.json
{
    "name": "PORTX",
    "commandline": "C:\\App\\PORTX\\portx-wrapper.exe",
    "startingDirectory": null,
    "icon": "📦",
    "tabTitle": "PORTX",
    "runAsAdministrator": false,
    "hideProfileFromDropdown": false
}
```

**Alternative Configuration** (Direct Command):
```json
{
    "name": "PORTX", 
    "commandline": "C:\\App\\PORTX\\portx.cmd",
    "icon": "C:\\App\\PORTX\\portx.ico",
    "startingDirectory": "%USERPROFILE%"
}
```

**Icon Fallback**: If `portx.ico` doesn't exist, use `C:\\App\\PORTX\\git-bash.exe`

**Access Methods**:
1. **Dropdown Menu**: Click ▼ next to + → Select "PORTX"
2. **Keyboard Shortcut**: Ctrl+Shift+[number] (based on profile position)
3. **Default Profile**: Set as default in Windows Terminal settings

### ConEmu/Cmder

**Task Setup**:
```
Name: PORTX
Commands: C:\App\PORTX\portx.cmd -new_console:t:"PORTX"
```

## 🎯 Project-Specific Integration

### Node.js Projects

**package.json scripts**:
```json
{
    "scripts": {
        "portx": "C:\\App\\PORTX\\portx.cmd",
        "dev": "C:\\App\\PORTX\\portx.cmd -c \"npm run serve\"",
        "build": "C:\\App\\PORTX\\portx.cmd -c \"npm run build\""
    }
}
```

### Python Projects

**Virtual Environment Integration**:
```bash
# .portx/activate (project-specific)
#!/bin/bash
source venv/bin/activate
export PYTHONPATH="$PWD:$PYTHONPATH"
```

### Java Projects

**Maven Integration**:
```xml
<!-- pom.xml -->
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>exec-maven-plugin</artifactId>
    <configuration>
        <executable>C:\App\PORTX\portx.cmd</executable>
    </configuration>
</plugin>
```

## 🔧 Advanced Configuration

### Custom Launch Scripts

**Project-Specific Launcher** (`launch-portx.bat`):
```batch
@echo off
cd /d "%~dp0"
set PROJECT_ROOT=%CD%
"C:\App\PORTX\portx.cmd" --cd="%PROJECT_ROOT%" --title="MyProject - PORTX"
```

**Development Environment Setup** (`.portxrc`):
```bash
#!/bin/bash
# Project-specific PORTX configuration
export PROJECT_NAME="MyProject"
export BUILD_TYPE="development"

# Load project-specific tools
export PATH="$PWD/tools:$PATH"

# Set up aliases
alias build='make clean && make'
alias test='npm test'
alias deploy='./deploy.sh'

echo "🚀 $PROJECT_NAME development environment loaded"
```

### Registry Integration (Advanced)

**File Association** (`.portx` files):
```batch
reg add "HKCR\.portx" /ve /d "PORTX.Script" /f
reg add "HKCR\PORTX.Script" /ve /d "PORTX Script" /f
reg add "HKCR\PORTX.Script\shell\open\command" /ve /d "\"C:\App\PORTX\portx.cmd\" \"%%1\"" /f
```

## 🔍 Troubleshooting

### Common Issues

**Path Problems**:
- Ensure PORTX path has no spaces or use quotes
- Use forward slashes for Unix-style paths in scripts
- Check environment variable expansion

**Permission Issues**:
- Run IDE as administrator if needed
- Check file associations in Windows
- Verify registry permissions

**Performance Issues**:
- Configure antivirus exclusions first
- Disable unnecessary startup scripts
- Use cached PATH loading

### Validation Commands

**Test Integration**:
```bash
# Verify PORTX tools availability
which git bash make gcc node python

# Check environment
echo $PATH | tr ':' '\n'
env | grep PORTX
```

## 📚 Usage Examples

### Development Workflow

1. **Open Project**: Right-click folder → "Open PORTX here"
2. **Setup Environment**: Run project-specific `.portxrc`
3. **Development**: Use all 818 tools seamlessly
4. **Build/Test**: Leverage integrated toolchain
5. **Deploy**: Use cloud CLI tools (aws, az, gcloud)

### Team Collaboration

**Shared Configuration** (`.vscode/settings.json`):
```json
{
    "terminal.integrated.defaultProfile.windows": "PORTX",
    "files.eol": "\n",
    "git.path": "C:\\App\\PORTX\\mingw64\\bin\\git.exe"
}
```

This ensures consistent development environment across team members using PORTX.