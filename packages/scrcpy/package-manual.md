# SCRcpy Package Manual

## Package Information
- **Package Name**: scrcpy
- **Category**: Mobile Development
- **Type**: Android Screen Control and Mirroring
- **License**: Apache 2.0

## Description
High-performance Android device screen mirroring and control application.

SCRcpy provides real-time display and control of Android devices connected via USB or wirelessly over TCP/IP.
Features low latency, high frame rate mirroring with full keyboard and mouse control for development, testing, and demonstration purposes.

## Tools Included

| Tool | Description | Usage |
|------|-------------|-------|
| scrcpy.exe | Main screen mirroring application | Mirror and control Android device screen |
| adb.exe | Android Debug Bridge | Device connection and debugging |
| scrcpy-console.bat | Console launcher script | Run scrcpy with visible console output |
| scrcpy-noconsole.vbs | Silent launcher script | Run scrcpy without console window |
| open_a_terminal_here.bat | Terminal utility | Open command prompt in scrcpy directory |

## Connection Methods

### USB Connection (Default)
```bash
# Basic USB mirroring (requires USB debugging enabled)
scrcpy

# List connected devices
adb devices

# Mirror specific device by serial
scrcpy -s DEVICE_SERIAL

# Mirror with specific resolution
scrcpy --max-size 1920

# High quality mirroring
scrcpy --bit-rate 8M --max-fps 60
```

### Wireless Connection (TCP/IP)
```bash
# Enable wireless debugging (Android 11+)
adb tcpip 5555
adb connect DEVICE_IP:5555

# Wireless mirroring
scrcpy --tcpip=DEVICE_IP:5555

# Alternative wireless setup
adb pair DEVICE_IP:PAIRING_PORT
adb connect DEVICE_IP:5555
scrcpy
```

### USB Over Network (ADB over Network)
```bash
# Port forwarding for remote debugging
adb forward tcp:27183 localabstract:scrcpy

# Connect through forwarded port
scrcpy --tunnel-host=localhost --tunnel-port=27183
```

## Display and Performance Configuration

### Resolution and Quality Settings
```bash
# Limit resolution to 1080p
scrcpy --max-size 1080

# Specific bit rate (higher = better quality)
scrcpy --bit-rate 2M

# Frame rate control
scrcpy --max-fps 30

# Low latency configuration
scrcpy --display-buffer=1 --bit-rate 8M --max-fps 60

# Ultra-low latency (for gaming)
scrcpy --bit-rate 4M --max-fps 60 --no-audio --lock-video-orientation=0
```

### Window and Display Options
```bash
# Fullscreen mode
scrcpy --fullscreen

# Custom window size
scrcpy --window-width=800 --window-height=600

# Always on top
scrcpy --always-on-top

# Borderless window
scrcpy --window-borderless

# Start in portrait mode
scrcpy --lock-video-orientation=0

# Disable screensaver
scrcpy --disable-screensaver
```

### Performance Optimization
```bash
# Disable audio for better performance
scrcpy --no-audio

# Hardware encoding (when available)
scrcpy --encoder=h264_nvenc

# Software encoding
scrcpy --encoder=h264_mediacodec

# Custom codec settings
scrcpy --video-codec=h264 --audio-codec=aac

# Buffer optimization
scrcpy --display-buffer=1 --audio-buffer=20
```

## Advanced Features and Control

### Recording and Screenshots
```bash
# Record screen to file
scrcpy --record=recording.mp4

# Record with specific settings
scrcpy --record=demo.mp4 --bit-rate 8M --max-fps 30

# Record audio only
scrcpy --no-video --record=audio.m4a

# Screenshot (using ADB)
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png
```

### Input Control Options
```bash
# Disable device control (view only)
scrcpy --no-control

# Disable keyboard input
scrcpy --no-key-repeat

# Disable mouse input
scrcpy --no-mouse-control

# Turn off device screen during mirroring
scrcpy --turn-screen-off

# Keep device awake
scrcpy --stay-awake

# Show physical touches on device
scrcpy --show-touches
```

### Keyboard and Mouse Mapping
```bash
# Custom key mapping for gaming
scrcpy --prefer-text

# Disable clipboard synchronization
scrcpy --no-clipboard-autosync

# Forward all key events
scrcpy --raw-key-events

# Inject text method
scrcpy --prefer-text
```

## Development and Testing Workflows

### Mobile App Development
```bash
#!/bin/bash
# Mobile development workflow script

DEVICE_SERIAL=$1
APP_PACKAGE=$2

echo "Starting mobile development session..."

# Connect to device
echo "Connecting to device: $DEVICE_SERIAL"
adb -s $DEVICE_SERIAL wait-for-device

# Start high-quality mirroring for development
echo "Starting screen mirror..."
scrcpy -s $DEVICE_SERIAL \
  --max-size 1920 \
  --bit-rate 8M \
  --max-fps 60 \
  --stay-awake \
  --show-touches \
  --window-title="Development - $APP_PACKAGE" &

SCRCPY_PID=$!

# Monitor app logs
echo "Monitoring app logs..."
adb -s $DEVICE_SERIAL logcat | grep $APP_PACKAGE &
LOGCAT_PID=$!

# Setup cleanup on exit
trap "kill $SCRCPY_PID $LOGCAT_PID 2>/dev/null" EXIT

echo "Development environment ready. Press Ctrl+C to stop."
wait
```

### Automated UI Testing
```bash
#!/bin/bash
# Automated UI testing with scrcpy recording

TEST_NAME=$1
DEVICE_SERIAL=$2
RECORDING_PATH="/tmp/ui_tests"

mkdir -p $RECORDING_PATH

echo "Starting UI test recording: $TEST_NAME"

# Start recording
scrcpy -s $DEVICE_SERIAL \
  --record="$RECORDING_PATH/${TEST_NAME}_$(date +%Y%m%d_%H%M%S).mp4" \
  --no-audio \
  --max-size 1080 \
  --bit-rate 4M \
  --max-fps 30 \
  --turn-screen-off &

SCRCPY_PID=$!

# Wait for recording to start
sleep 3

# Execute UI test commands
echo "Executing UI test steps..."

# Example UI interactions via ADB
adb -s $DEVICE_SERIAL shell input tap 500 1000  # Tap button
sleep 1
adb -s $DEVICE_SERIAL shell input swipe 300 800 300 400  # Swipe up
sleep 1
adb -s $DEVICE_SERIAL shell input text "Test Input"  # Enter text
sleep 2

# Take screenshot for verification
adb -s $DEVICE_SERIAL shell screencap -p > "$RECORDING_PATH/${TEST_NAME}_final.png"

# Stop recording
kill $SCRCPY_PID

echo "UI test recording complete: $RECORDING_PATH/${TEST_NAME}_*.mp4"
```

### Quality Assurance Testing
```bash
#!/bin/bash
# QA testing workflow with multiple devices

QA_SESSION_ID=$(date +%Y%m%d_%H%M%S)
RECORDINGS_DIR="/qa_recordings/$QA_SESSION_ID"
mkdir -p $RECORDINGS_DIR

# Get list of connected devices
DEVICES=($(adb devices | grep -v "List of devices" | grep "device" | cut -f1))

echo "Starting QA session with ${#DEVICES[@]} devices"

for i in "${!DEVICES[@]}"; do
    DEVICE=${DEVICES[$i]}
    echo "Setting up device $((i+1)): $DEVICE"
    
    # Start mirroring for each device
    scrcpy -s $DEVICE \
      --window-title="QA Device $((i+1)) - $DEVICE" \
      --window-x=$((i * 400)) \
      --window-y=$((i * 300)) \
      --window-width=300 \
      --window-height=533 \
      --record="$RECORDINGS_DIR/device_${i}_${DEVICE}.mp4" \
      --max-size 720 \
      --bit-rate 2M &
    
    # Store PID for cleanup
    eval "SCRCPY_PID_$i=$!"
done

echo "QA session active. All devices are being recorded."
echo "Press Enter to stop session..."
read

# Cleanup all scrcpy instances
for i in "${!DEVICES[@]}"; do
    eval "kill \$SCRCPY_PID_$i 2>/dev/null"
done

echo "QA session complete. Recordings saved in: $RECORDINGS_DIR"
```

## Scripting and Automation

### Batch Operations Script
```powershell
# PowerShell script for batch device operations
param(
    [string]$Operation = "mirror",
    [string]$Quality = "high",
    [int]$Duration = 0
)

# Get connected devices
$devices = adb devices | Select-String "device$" | ForEach-Object { ($_ -split "\s+")[0] }

if ($devices.Count -eq 0) {
    Write-Host "No devices connected" -ForegroundColor Red
    exit 1
}

Write-Host "Found $($devices.Count) connected device(s)" -ForegroundColor Green

# Quality presets
$qualitySettings = @{
    "low" = "--max-size 720 --bit-rate 1M --max-fps 15"
    "medium" = "--max-size 1080 --bit-rate 4M --max-fps 30"
    "high" = "--max-size 1920 --bit-rate 8M --max-fps 60"
    "ultra" = "--max-size 2560 --bit-rate 16M --max-fps 60"
}

$settings = $qualitySettings[$Quality]

foreach ($device in $devices) {
    Write-Host "Starting operation '$Operation' on device: $device" -ForegroundColor Yellow
    
    switch ($Operation) {
        "mirror" {
            Start-Process -FilePath "scrcpy.exe" -ArgumentList "-s $device $settings --window-title=`"Device: $device`""
        }
        "record" {
            $recordFile = "recording_${device}_$(Get-Date -Format 'yyyyMMdd_HHmmss').mp4"
            $args = "-s $device $settings --record=`"$recordFile`""
            if ($Duration -gt 0) {
                $args += " --time-limit=$Duration"
            }
            Start-Process -FilePath "scrcpy.exe" -ArgumentList $args
        }
        "screenshot" {
            $screenshotFile = "screenshot_${device}_$(Get-Date -Format 'yyyyMMdd_HHmmss').png"
            & adb -s $device shell screencap -p | Out-File -FilePath $screenshotFile -Encoding byte
            Write-Host "Screenshot saved: $screenshotFile" -ForegroundColor Green
        }
    }
    
    Start-Sleep -Seconds 1
}

if ($Operation -eq "mirror" -or $Operation -eq "record") {
    Write-Host "All scrcpy instances started. Close windows manually when done." -ForegroundColor Green
}
```

### Device Management Utilities
```bash
#!/bin/bash
# Device management and monitoring utilities

function list_devices() {
    echo "Connected Android devices:"
    adb devices -l | grep -v "List of devices"
}

function device_info() {
    local device=$1
    echo "Device Information for: $device"
    echo "Model: $(adb -s $device shell getprop ro.product.model)"
    echo "Android Version: $(adb -s $device shell getprop ro.build.version.release)"
    echo "API Level: $(adb -s $device shell getprop ro.build.version.sdk)"
    echo "Architecture: $(adb -s $device shell getprop ro.product.cpu.abi)"
    echo "Resolution: $(adb -s $device shell wm size)"
    echo "Density: $(adb -s $device shell wm density)"
    echo "Battery: $(adb -s $device shell dumpsys battery | grep level)"
}

function mirror_device() {
    local device=$1
    local quality=${2:-medium}
    
    case $quality in
        "low")
            scrcpy -s $device --max-size 720 --bit-rate 1M --max-fps 15
            ;;
        "medium")
            scrcpy -s $device --max-size 1080 --bit-rate 4M --max-fps 30
            ;;
        "high")
            scrcpy -s $device --max-size 1920 --bit-rate 8M --max-fps 60
            ;;
        "presentation")
            scrcpy -s $device --max-size 1080 --bit-rate 4M --max-fps 30 --always-on-top --window-borderless
            ;;
    esac
}

function record_demo() {
    local device=$1
    local output_file=${2:-"demo_$(date +%Y%m%d_%H%M%S).mp4"}
    local duration=${3:-60}
    
    echo "Recording device $device for $duration seconds..."
    scrcpy -s $device \
        --record="$output_file" \
        --max-size 1080 \
        --bit-rate 8M \
        --max-fps 30 \
        --time-limit=$duration \
        --show-touches
    
    echo "Recording saved: $output_file"
}

function install_and_test() {
    local device=$1
    local apk_file=$2
    local package_name=$3
    
    echo "Installing APK on device: $device"
    adb -s $device install "$apk_file"
    
    echo "Starting app and mirroring..."
    adb -s $device shell monkey -p $package_name -c android.intent.category.LAUNCHER 1
    
    sleep 2
    scrcpy -s $device --max-size 1080 --bit-rate 4M --show-touches
}

# Command dispatcher
case $1 in
    "list")
        list_devices
        ;;
    "info")
        device_info $2
        ;;
    "mirror")
        mirror_device $2 $3
        ;;
    "record")
        record_demo $2 $3 $4
        ;;
    "install")
        install_and_test $2 $3 $4
        ;;
    *)
        echo "Usage: $0 {list|info|mirror|record|install} [device] [options...]"
        echo "  list                 - List connected devices"
        echo "  info <device>        - Show device information"
        echo "  mirror <device> [quality] - Mirror device screen"
        echo "  record <device> [output] [duration] - Record device screen"
        echo "  install <device> <apk> <package> - Install and test APK"
        ;;
esac
```

## Performance Tuning and Troubleshooting

### Network Optimization
```bash
# Optimize for wireless connection
scrcpy --tcpip=192.168.1.100 \
  --bit-rate 2M \
  --max-fps 24 \
  --display-buffer=1 \
  --no-audio

# Low bandwidth configuration
scrcpy --max-size 720 \
  --bit-rate 500K \
  --max-fps 15 \
  --no-audio \
  --no-control

# Gaming optimization (minimal latency)
scrcpy --bit-rate 8M \
  --max-fps 60 \
  --display-buffer=1 \
  --audio-buffer=10 \
  --lock-video-orientation=1
```

### Troubleshooting Commands
```bash
# Check ADB connection
adb devices
adb shell echo "Connection test"

# Reset ADB daemon
adb kill-server
adb start-server

# Check scrcpy server status
adb shell pgrep scrcpy-server

# Clear scrcpy cache
adb shell rm -rf /data/local/tmp/scrcpy-server*

# Debug connection issues
adb logcat | grep scrcpy

# Check device permissions
adb shell dumpsys package com.android.shell | grep -A1 "android.permission.WRITE_SECURE_SETTINGS"
```

### Performance Monitoring
```bash
#!/bin/bash
# Monitor scrcpy performance

DEVICE=$1
LOG_FILE="scrcpy_performance_$(date +%Y%m%d_%H%M%S).log"

echo "Starting performance monitoring for device: $DEVICE" | tee $LOG_FILE

# Start scrcpy with verbose output
scrcpy -s $DEVICE \
  --max-size 1080 \
  --bit-rate 4M \
  --max-fps 30 \
  --verbosity=debug 2>&1 | tee -a $LOG_FILE &

SCRCPY_PID=$!

# Monitor system resources
while kill -0 $SCRCPY_PID 2>/dev/null; do
    echo "$(date): CPU: $(top -bn1 | grep "scrcpy" | awk '{print $9}')%, Memory: $(ps -o pid,vsz,rss,comm | grep scrcpy)" >> $LOG_FILE
    sleep 5
done

echo "Performance monitoring complete. Log saved: $LOG_FILE"
```

## Integration Examples

### CI/CD Integration
```yaml
# GitHub Actions workflow for mobile app testing
name: Mobile App UI Tests

on:
  push:
    branches: [ main, develop ]
  pull_request:
    branches: [ main ]

jobs:
  ui-tests:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Android SDK
      uses: android-actions/setup-android@v2
    
    - name: Start Android Emulator
      uses: reactivecircus/android-emulator-runner@v2
      with:
        api-level: 31
        script: |
          # Install scrcpy
          wget https://github.com/Genymobile/scrcpy/releases/download/v1.24/scrcpy-linux-v1.24.tar.gz
          tar -xzf scrcpy-linux-v1.24.tar.gz
          
          # Start recording UI tests
          ./scrcpy-linux-v1.24/scrcpy --record=ui_test_recording.mp4 --max-size 720 --time-limit=300 &
          
          # Run UI tests
          ./gradlew connectedAndroidTest
          
          # Upload recording as artifact
    - name: Upload Test Recording
      uses: actions/upload-artifact@v3
      with:
        name: ui-test-recording
        path: ui_test_recording.mp4
```

### Docker Integration
```dockerfile
# Dockerfile for Android testing environment with scrcpy
FROM ubuntu:22.04

# Install dependencies
RUN apt-get update && apt-get install -y \
    android-tools-adb \
    android-tools-fastboot \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install scrcpy
RUN wget https://github.com/Genymobile/scrcpy/releases/download/v1.24/scrcpy-linux-v1.24.tar.gz \
    && tar -xzf scrcpy-linux-v1.24.tar.gz \
    && mv scrcpy-linux-v1.24 /opt/scrcpy \
    && ln -s /opt/scrcpy/scrcpy /usr/local/bin/scrcpy

# Create workspace
WORKDIR /workspace

# Copy test scripts
COPY scripts/ ./scripts/
RUN chmod +x scripts/*.sh

# Default command
CMD ["./scripts/run_ui_tests.sh"]
```

## Use Cases

### Mobile App Development
- Real-time app testing and debugging during development
- User interface design validation and testing
- Cross-device compatibility testing and validation
- Performance monitoring and optimization

### Quality Assurance and Testing
- Automated UI testing and regression testing
- Manual testing with screen recording for documentation
- Multi-device testing scenarios and comparisons
- Bug reproduction and demonstration recordings

### Presentations and Demonstrations
- Live product demonstrations and presentations
- Training and educational content creation
- Marketing material and promotional video creation
- Conference presentations and technical talks

### Technical Support and Documentation
- Remote troubleshooting and technical support
- User guide creation with screen recordings
- Issue reproduction and documentation
- Training material development and delivery

## Installation
High-performance Android screen mirroring and control application.
Essential tool for mobile development, testing, and device management workflows.

## Dependencies
- Android device with USB debugging enabled
- USB cable or wireless network connection
- ADB (Android Debug Bridge) for device communication
- FFmpeg libraries for video encoding/decoding (included)
- SDL2 for display and input handling (included)

## System Requirements
- Windows 10/11 or later
- USB 2.0 or higher for wired connections
- WiFi network for wireless mirroring
- Minimum 4GB RAM for smooth operation
- Graphics card supporting hardware video decoding (recommended)

---
*Part of PORTX Portable Development Environment*