# NirCmd Package Manual

## Package Information
- **Package Name**: nircmd
- **Category**: System Utilities
- **Type**: Windows Command-Line Utilities
- **License**: Freeware

## Description
Powerful command-line utility for Windows system operations and automation.

Comprehensive command-line tool for Windows system administration, automation, and control.
Provides access to Windows functions typically available only through GUI interfaces.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| nircmd.exe | Windows command-line utility | Execute Windows system operations from command line |
| nircmdc.exe | Console version of NirCmd | Same functionality with console output |

## Common Usage Examples

### Window Management
```bash
# Minimize window
nircmd win min title "Notepad"

# Maximize window
nircmd win max title "Calculator"

# Close window
nircmd win close title "Untitled - Notepad"

# Hide window
nircmd win hide title "Command Prompt"

# Show window
nircmd win show title "Command Prompt"

# Set window position and size
nircmd win setsize title "Notepad" x 100 y 100 width 800 height 600
```

### Process Management
```bash
# Kill process by name
nircmd killprocess notepad.exe

# Kill process by PID
nircmd killprocess 1234

# Run program
nircmd exec show "notepad.exe"

# Run program hidden
nircmd exec hide "backup_script.bat"

# Run program minimized
nircmd exec min "calc.exe"
```

### System Control
```bash
# Shutdown system
nircmd exitwin shutdown

# Restart system
nircmd exitwin reboot

# Log off user
nircmd exitwin logoff

# Hibernate system
nircmd exitwin hibernate

# Standby/sleep mode
nircmd exitwin standby

# Force shutdown
nircmd exitwin poweroff force
```

### Audio and Volume Control
```bash
# Set system volume (0-65535)
nircmd setsysvolume 32768

# Mute system volume
nircmd mutesysvolume 1

# Unmute system volume
nircmd mutesysvolume 0

# Change volume by percentage
nircmd changesysvolume 2000    # Increase
nircmd changesysvolume -2000   # Decrease

# Set application volume
nircmd setappvolume firefox.exe 0.5

# Mute specific application
nircmd setappvolume chrome.exe 0
```

### Display and Monitor Control
```bash
# Turn off monitor
nircmd monitor off

# Set screen resolution
nircmd setdisplay 1920 1080 32

# Change display orientation
nircmd setdisplay rotate 90

# Set brightness (laptops)
nircmd setbrightness 50

# Take screenshot
nircmd savescreenshot "screenshot.png"

# Capture window screenshot
nircmd savescreenshot "window.png" title "Calculator"
```

### Network Operations
```bash
# Send network message
nircmd sendmsg "Hello World" "192.168.1.100"

# Enable network adapter
nircmd netuse enable "Local Area Connection"

# Disable network adapter
nircmd netuse disable "Wi-Fi"

# Show network adapters
nircmd netuse show

# Flush DNS cache
nircmd flushdns
```

### Registry Operations
```bash
# Write registry value
nircmd regwrite "HKCU\Software\MyApp\Settings" "MySetting" "MyValue"

# Read registry value
nircmd regread "HKLM\Software\Microsoft\Windows\CurrentVersion" "ProgramFilesDir"

# Delete registry value
nircmd regdelete "HKCU\Software\MyApp\Settings" "OldSetting"

# Delete registry key
nircmd regdelkey "HKCU\Software\OldApp"
```

### File Operations
```bash
# Copy file
nircmd copy "source.txt" "destination.txt"

# Move file
nircmd move "old_location.txt" "new_location.txt"

# Delete file
nircmd delete "unwanted_file.txt"

# Create shortcut
nircmd shortcut "C:\Program Files\MyApp\app.exe" "~$folder.desktop$" "MyApp"

# Set file attributes
nircmd fileattrib +h "hidden_file.txt"    # Hidden
nircmd fileattrib +r "readonly_file.txt"  # Read-only
```

### System Information
```bash
# Get system uptime
nircmd getinfo uptime

# Get free disk space
nircmd getinfo diskfree C:

# Get system info
nircmd getinfo computerName
nircmd getinfo userName
nircmd getinfo windowsVersion

# Show system information dialog
nircmd infobox "System Information" "text"
```

### Service Management
```bash
# Start Windows service
nircmd service start "Spooler"

# Stop Windows service
nircmd service stop "Themes"

# Restart service
nircmd service restart "EventLog"

# Check service status
nircmd service status "W32Time"
```

### Clipboard Operations
```bash
# Set clipboard text
nircmd clipboard set "Hello World"

# Clear clipboard
nircmd clipboard clear

# Save clipboard to file
nircmd clipboard savefile "clipboard.txt"

# Load file to clipboard
nircmd clipboard loadfile "data.txt"
```

## Advanced Automation

### Scheduled Tasks
```bash
# Wait and execute
nircmd wait 5000 exec show notepad.exe

# Loop with delay
nircmd loop 10 1000 speak text "Time check"

# Conditional execution
nircmd if processexist "notepad.exe" win close title "Notepad"
```

### Batch Operations
```batch
@echo off
REM System maintenance script

echo Clearing temporary files...
nircmd delete "%TEMP%\*.*"

echo Setting volume to 50%...
nircmd setsysvolume 32768

echo Taking system screenshot...
nircmd savescreenshot "maintenance_%date%_%time%.png"

echo Maintenance complete
nircmd speak text "System maintenance completed"
```

### Remote Operations
```bash
# Execute on remote computer (with proper permissions)
nircmd remote \\RemotePC exec show notepad.exe

# Remote shutdown
nircmd remote \\RemotePC exitwin shutdown

# Remote message
nircmd remote \\RemotePC sendmsg "Maintenance in 5 minutes"
```

### System Monitoring
```bash
# Monitor process and alert
nircmd if not processexist "critical_app.exe" infobox "Alert" "Critical application stopped"

# CPU usage monitoring
nircmd if cpuusage > 90 speak text "High CPU usage detected"

# Memory monitoring  
nircmd if memoryusage > 80 exec show "task_manager.exe"
```

## Scripting Integration

### PowerShell Integration
```powershell
# PowerShell script using NirCmd
function Set-SystemVolume {
    param([int]$Volume)
    & nircmd setsysvolume ($Volume * 655.35)
}

function Take-Screenshot {
    param([string]$Path = "screenshot.png")
    & nircmd savescreenshot $Path
}

# Usage
Set-SystemVolume -Volume 75
Take-Screenshot -Path "C:\Screenshots\$(Get-Date -Format 'yyyyMMdd_HHmmss').png"
```

### Batch File Automation
```batch
@echo off
REM Daily maintenance script

echo Starting daily maintenance...

REM Clear temporary files
nircmd delete "%TEMP%\*.*"
nircmd delete "%WINDIR%\Temp\*.*"

REM Take backup screenshot
nircmd savescreenshot "C:\Backups\daily_%date%.png"

REM System restart notification
nircmd speak text "System will restart in 1 minute"
nircmd wait 60000 exitwin reboot
```

### Task Scheduler Integration
```bash
# Create scheduled task to run NirCmd operations
schtasks /create /tn "SystemMaintenance" /tr "nircmd.exe exec hide maintenance_script.bat" /sc daily /st 02:00

# Schedule volume control
schtasks /create /tn "MuteAtNight" /tr "nircmd.exe mutesysvolume 1" /sc daily /st 22:00

# Schedule wake-up actions
schtasks /create /tn "MorningRoutine" /tr "nircmd.exe speak text 'Good morning'" /sc daily /st 07:00
```

## GUI Automation

### Dialog Box Management
```bash
# Show message box
nircmd infobox "Information" "Operation completed successfully"

# Show input box
nircmd inputbox "Please enter your name:" "DefaultName"

# Confirm dialog
nircmd qbox "Are you sure you want to continue?"

# Custom dialog
nircmd dlg "" "Title" "Message" 0x40
```

### Menu and Tray Operations
```bash
# Add tray icon
nircmd trayicon "myapp.exe" "icon.ico" "My Application"

# Remove tray icon
nircmd trayicon remove "myapp.exe"

# Show balloon tip
nircmd trayballoon "Title" "Message" "icon.ico" 10000
```

## Use Cases

### System Administration
- Automated system maintenance
- Remote system management
- Service monitoring and control
- Performance optimization scripts

### Development and Testing
- Application testing automation
- Environment setup scripts
- Build process integration
- Deployment automation

### Desktop Automation
- Workflow automation
- Repetitive task scripting
- System customization
- Productivity enhancement

### Monitoring and Alerting
- System health monitoring
- Performance alerting
- Resource usage tracking
- Automated responses

## Error Handling

### Return Codes
```bash
# Check command success
nircmd setsysvolume 32768
if %ERRORLEVEL% == 0 (
    echo Volume set successfully
) else (
    echo Failed to set volume
)
```

### Logging Operations
```bash
# Log operations
echo %date% %time% - Starting maintenance >> maintenance.log
nircmd delete "%TEMP%\*.*" >> maintenance.log 2>&1
echo %date% %time% - Maintenance completed >> maintenance.log
```

## Installation
Comprehensive Windows command-line utility for system operations and automation.
Essential tool for Windows system administration and desktop automation.

## Dependencies
- Windows operating system
- Appropriate user permissions for system operations
- Command prompt or PowerShell environment

## Security Considerations
- Run with appropriate privileges
- Validate input parameters
- Use caution with system-level operations
- Test scripts in safe environments
- Follow principle of least privilege

---
*Part of PORTX Portable Development Environment*