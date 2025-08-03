# Android Tools Package Manual

## Package Information
- **Package Name**: android-tools
- **Category**: Mobile Development
- **Type**: Android SDK Tools
- **License**: Apache 2.0

## Description
Android SDK platform tools for Android app development, debugging, and device management.

Essential tools for Android development including device communication, debugging, file system operations, and development utilities.
Used for app installation, debugging, system analysis, and device management workflows.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| adb.exe | Android Debug Bridge | Debug and communicate with Android devices |
| fastboot.exe | Bootloader communication tool | Flash firmware and manage device bootloader |
| make_f2fs.exe | F2FS filesystem creator | Create F2FS filesystems for Android |
| make_f2fs_casefold.exe | F2FS casefold filesystem creator | Create case-insensitive F2FS filesystems |
| mke2fs.exe | EXT filesystem creator | Create EXT2/3/4 filesystems |
| etc1tool.exe | ETC1 texture compression | Compress textures for Android graphics |
| hprof-conv.exe | HPROF file converter | Convert heap dumps for analysis |

## Common Usage Examples

### Device Management (ADB)
```bash
# List connected devices
adb devices

# Connect to device over network
adb connect 192.168.1.100:5555

# Install APK
adb install app.apk

# Uninstall app
adb uninstall com.example.app

# Start shell on device
adb shell
```

### File Operations
```bash
# Push file to device
adb push local_file.txt /sdcard/

# Pull file from device
adb pull /sdcard/file.txt local_file.txt

# Copy directory
adb push folder/ /sdcard/folder/

# Backup device data
adb backup -all -f backup.ab
```

### App Development & Debugging
```bash
# View device logs
adb logcat

# Filter logs by tag
adb logcat -s "MyApp"

# Clear logs
adb logcat -c

# Install and launch app
adb install -r app.apk
adb shell am start -n com.example.app/.MainActivity
```

### System Information
```bash
# Get device properties
adb shell getprop

# View running processes
adb shell ps

# Check storage space
adb shell df

# View system information
adb shell dumpsys
```

### Fastboot Operations
```bash
# List devices in fastboot mode
fastboot devices

# Flash recovery image
fastboot flash recovery recovery.img

# Flash system partition
fastboot flash system system.img

# Reboot device
fastboot reboot

# Unlock bootloader
fastboot oem unlock
```


### Performance Analysis
```bash
# Monitor CPU usage
adb shell top

# Memory information
adb shell cat /proc/meminfo

# Battery statistics
adb shell dumpsys battery

# Network usage
adb shell cat /proc/net/dev
```

### Development Utilities
```bash
# Take screenshot
adb shell screencap /sdcard/screenshot.png
adb pull /sdcard/screenshot.png

# Record screen
adb shell screenrecord /sdcard/video.mp4

# Port forwarding
adb forward tcp:8080 tcp:8080

# Reverse port forwarding
adb reverse tcp:8080 tcp:8080
```

### Filesystem Operations
```bash
# Create F2FS filesystem
make_f2fs /dev/block/mmcblk0p1

# Create EXT4 filesystem
mke2fs -t ext4 /dev/block/mmcblk0p1

# Mount filesystem
adb shell mount -t f2fs /dev/block/mmcblk0p1 /data
```

### Texture Processing
```bash
# Compress texture to ETC1
etc1tool input.png --encodeNoHeader -o output.pkm

# Decode ETC1 texture
etc1tool --decode input.pkm -o output.png
```

## Installation
Complete Android development toolkit for device management and app development.
Essential for Android development workflows and device administration.

## Dependencies
- Android device with USB debugging enabled
- USB drivers for device communication
- Device bootloader unlock (for fastboot operations)

## Configuration
- Enable Developer Options on Android device
- Enable USB Debugging in Developer Options
- Install appropriate USB drivers for device recognition
- Grant computer access when prompted on device

## Use Cases
- Android app development and testing
- Device firmware modification
- System debugging and analysis
- File transfer and backup operations
- Performance monitoring and optimization

---
*Part of PORTX Portable Development Environment*