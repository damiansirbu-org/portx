# NirCmd - Windows Command Line Utility

NirCmd is a powerful, lightweight command-line utility for Windows that allows you to perform a wide variety of system tasks without displaying any user interface. Developed by NirSoft, it's an essential tool for Windows automation and system control.

## Available Executables

- **nircmd.exe** - Main NirCmd executable (119KB)
- **nircmdc.exe** - Console version for better integration with command-line environments (118KB)

Total size: 236KB

## Key Capabilities

### System Control
- **Power Management**: Shutdown, restart, hibernate, standby, lock workstation
- **Display Control**: Turn monitor on/off, change resolution, adjust brightness
- **Volume Control**: Set system volume, mute/unmute, control application volumes
- **Service Management**: Start, stop, restart Windows services

### Window Management
- **Window Operations**: Minimize, maximize, close, hide, show windows
- **Window Properties**: Change window title, position, size, transparency
- **Desktop Control**: Show/hide desktop icons, taskbar manipulation

### System Information & Automation
- **Clipboard Operations**: Set, get, clear clipboard content
- **Registry Operations**: Read, write, delete registry keys and values
- **File Operations**: Copy, move, delete files, create shortcuts
- **Process Control**: Start, terminate processes

### Multimedia & Communication
- **Text-to-Speech**: Convert text to speech using Windows TTS
- **Audio Operations**: Play system sounds, beep, control audio devices
- **CD-ROM Control**: Open/close CD-ROM drive, eject media

### Network & Communication
- **Network Operations**: Connect/disconnect VPN, dial internet connections
- **System Notifications**: Display balloon tips, system tray messages

## Common Usage Examples

### System Control
```bash
# Power management
nircmd exitwin poweroff          # Shutdown computer
nircmd exitwin reboot           # Restart computer
nircmd exitwin hibernate        # Hibernate system
nircmd exitwin standby          # Put system in standby

# Display control
nircmd monitor off              # Turn off monitor
nircmd monitor on               # Turn on monitor
nircmd setdisplay 1920 1080 32  # Set display resolution
```

### Volume Control
```bash
# Volume operations
nircmd setsysvolume 32768       # Set system volume to 50%
nircmd setsysvolume 65535       # Set system volume to 100%
nircmd mutesysvolume 1          # Mute system volume
nircmd mutesysvolume 0          # Unmute system volume
nircmd changesysvolume 2000     # Increase volume
nircmd changesysvolume -2000    # Decrease volume
```

### Window Management
```bash
# Window operations
nircmd win hide title "Notepad"         # Hide Notepad window
nircmd win show title "Notepad"         # Show Notepad window
nircmd win close title "Notepad"        # Close Notepad window
nircmd win min title "Notepad"          # Minimize Notepad window
nircmd win max title "Notepad"          # Maximize Notepad window

# Work with window classes
nircmd win hide class "Shell_TrayWnd"   # Hide taskbar
nircmd win show class "Shell_TrayWnd"   # Show taskbar
```

### Clipboard Operations
```bash
# Clipboard management
nircmd clipboard set "Hello World"      # Set clipboard text
nircmd clipboard clear                   # Clear clipboard
nircmd clipboard addfile "C:\file.txt"  # Add file to clipboard
```

### Text-to-Speech
```bash
# Speech synthesis
nircmd speak text "Hello, this is a test"
nircmd speak text "System ready" 0 100  # With rate and volume control
```

### File and Process Operations
```bash
# File operations
nircmd copyfile "source.txt" "dest.txt"
nircmd movefile "old.txt" "new.txt"
nircmd delfile "unwanted.txt"

# Process control
nircmd exec show "notepad.exe"          # Start Notepad
nircmd killprocess "notepad.exe"        # Terminate Notepad
```

### Service Management
```bash
# Windows services
nircmd service start "Spooler"          # Start print spooler
nircmd service stop "Spooler"           # Stop print spooler  
nircmd service restart "Spooler"        # Restart print spooler
```

## Advanced Features

### Special Variables
NirCmd supports special variables that represent system folders and values:
- `~$folder.desktop$` - Desktop folder path
- `~$folder.programs$` - Programs folder path
- `~$folder.startup$` - Startup folder path
- `~$windir$` - Windows directory
- `~$sysdir$` - System directory

### Batch Processing
Execute multiple NirCmd commands from a text file:
```bash
nircmd multi exec "commands.txt"
```

### Remote Execution
Execute NirCmd commands on remote computers:
```bash
nircmd rexec \\computer command parameters
```

## Integration with PORTX

NirCmd integrates seamlessly with other PORTX tools:

```bash
# Combine with text processing
echo "System maintenance complete" | nircmd speak text stdin

# Use with system monitoring
pslist64 -accepteula | rg "chrome" && nircmd speak text "Chrome is running"

# Clipboard integration with other tools
rg "error" logs/*.txt | head -1 | nircmd clipboard set stdin
```

## Usage Notes

### Important Considerations
1. **No Parameters Popup**: Running `nircmd.exe` without parameters shows an information dialog. Always use specific commands.
2. **Console Version**: Use `nircmdc.exe` for better console integration and output capture.
3. **Permissions**: Some operations may require administrative privileges.
4. **Safety**: Be careful with system control commands as they can affect system stability.

### Best Practices
- Use `nircmdc.exe` in scripts for better error handling
- Test commands in a safe environment before automating
- Use quotes around parameters containing spaces
- Combine with conditional logic for robust automation

## System Compatibility

- **Operating Systems**: Windows 9x/ME, NT, 2000, XP, Vista, 7, 8, 10, 11
- **Architecture**: Both 32-bit and 64-bit systems supported
- **Dependencies**: None - fully self-contained executable

## Official Resources

- **Official Website**: https://www.nirsoft.net/utils/nircmd.html
- **Command Reference**: https://nircmd.nirsoft.net/
- **Developer**: NirSoft (Nir Sofer)
- **License**: Freeware for personal and commercial use

## Security Note

NirCmd is a powerful system utility that can perform privileged operations. Always verify the source and use it responsibly. The version included in PORTX is the official release from NirSoft.