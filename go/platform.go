package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"sync"

	"github.com/shirou/gopsutil/process"
)

// PlatformEnvironment represents the detected platform and path conventions
type PlatformEnvironment struct {
	Type           string // "windows", "wsl", "msys2", "cygwin", "unix"
	PathSeparator  string // "/" or "\\"
	UnixPathPrefix string // "/mnt/c/", "/c/", "/cygdrive/c/", etc.
	WindowsRoot    string // "C:\\"
	Executable     string // ".exe" or ""
}

// PathConverter provides optimized cross-platform path conversion
type PathConverter interface {
	UnixToNative(path string) string
	NativeToUnix(path string) string
	IsUnixPath(path string) bool
	IsNativePath(path string) bool
	GetPlatformType() string
}

// PathConverterRegistry manages path converter instances with caching
type PathConverterRegistry struct {
	converters map[string]PathConverter
	mutex      sync.RWMutex
}

// Global registry instance
var pathConverterRegistry = &PathConverterRegistry{
	converters: make(map[string]PathConverter),
}

// GetPathConverter returns a cached path converter for the platform type
func GetPathConverter(platformType string) PathConverter {
	pathConverterRegistry.mutex.RLock()
	converter, exists := pathConverterRegistry.converters[platformType]
	pathConverterRegistry.mutex.RUnlock()

	if exists {
		return converter
	}

	pathConverterRegistry.mutex.Lock()
	defer pathConverterRegistry.mutex.Unlock()

	// Double-check pattern
	if converter, exists := pathConverterRegistry.converters[platformType]; exists {
		return converter
	}

	// Create new converter
	converter = createPathConverter(platformType)
	pathConverterRegistry.converters[platformType] = converter
	return converter
}

// OptimizedWSLPathConverter - High-performance WSL path converter
type OptimizedWSLPathConverter struct {
	platformType string
}

func (w *OptimizedWSLPathConverter) GetPlatformType() string {
	return w.platformType
}

func (w *OptimizedWSLPathConverter) UnixToNative(path string) string {
	if len(path) < 7 || !strings.HasPrefix(path, "/mnt/") {
		return path
	}

	if path[5] >= 'a' && path[5] <= 'z' && len(path) > 6 && path[6] == '/' {
		// Fast path conversion: /mnt/c/path -> C:\path
		drive := path[5] - 'a' + 'A' // Convert to uppercase
		result := make([]byte, 0, len(path))
		result = append(result, drive, ':', '\\')

		// Convert remaining path, replacing / with \
		for i := 7; i < len(path); i++ {
			if path[i] == '/' {
				result = append(result, '\\')
			} else {
				result = append(result, path[i])
			}
		}
		return string(result)
	}

	return path
}

func (w *OptimizedWSLPathConverter) NativeToUnix(path string) string {
	if len(path) < 3 || path[1] != ':' {
		return path
	}

	if (path[0] >= 'A' && path[0] <= 'Z') || (path[0] >= 'a' && path[0] <= 'z') {
		// Fast path conversion: C:\path -> /mnt/c/path
		drive := path[0]
		if drive >= 'A' && drive <= 'Z' {
			drive = drive - 'A' + 'a' // Convert to lowercase
		}

		result := make([]byte, 0, len(path)+5)
		result = append(result, '/', 'm', 'n', 't', '/', drive, '/')

		// Convert remaining path, replacing \ with /
		for i := 3; i < len(path); i++ {
			if path[i] == '\\' {
				result = append(result, '/')
			} else {
				result = append(result, path[i])
			}
		}
		return string(result)
	}

	return path
}

func (w *OptimizedWSLPathConverter) IsUnixPath(path string) bool {
	if len(path) < 2 {
		return false
	}

	return strings.HasPrefix(path, "/mnt/") ||
		strings.HasPrefix(path, "/home/") ||
		strings.HasPrefix(path, "/usr/") ||
		strings.HasPrefix(path, "/var/") ||
		strings.HasPrefix(path, "/tmp/") ||
		strings.HasPrefix(path, "/opt/") ||
		strings.HasPrefix(path, "/etc/") ||
		strings.HasPrefix(path, "/bin/") ||
		strings.HasPrefix(path, "/lib/")
}

func (w *OptimizedWSLPathConverter) IsNativePath(path string) bool {
	return len(path) >= 3 && path[1] == ':' &&
		((path[0] >= 'A' && path[0] <= 'Z') || (path[0] >= 'a' && path[0] <= 'z'))
}

// OptimizedMSYS2PathConverter - High-performance MSYS2 path converter
type OptimizedMSYS2PathConverter struct {
	platformType string
}

func (m *OptimizedMSYS2PathConverter) GetPlatformType() string {
	return m.platformType
}

func (m *OptimizedMSYS2PathConverter) UnixToNative(path string) string {
	if len(path) < 3 || path[0] != '/' {
		return path
	}

	if len(path) > 2 && path[2] == '/' &&
		((path[1] >= 'a' && path[1] <= 'z') || (path[1] >= 'A' && path[1] <= 'Z')) {
		// Fast path conversion: /c/path -> C:\path
		drive := path[1]
		if drive >= 'a' && drive <= 'z' {
			drive = drive - 'a' + 'A' // Convert to uppercase
		}

		result := make([]byte, 0, len(path))
		result = append(result, drive, ':', '\\')

		// Convert remaining path
		for i := 3; i < len(path); i++ {
			if path[i] == '/' {
				result = append(result, '\\')
			} else {
				result = append(result, path[i])
			}
		}
		return string(result)
	}

	return path
}

func (m *OptimizedMSYS2PathConverter) NativeToUnix(path string) string {
	if len(path) < 3 || path[1] != ':' {
		return path
	}

	if (path[0] >= 'A' && path[0] <= 'Z') || (path[0] >= 'a' && path[0] <= 'z') {
		// Fast path conversion: C:\path -> /c/path
		drive := path[0]
		if drive >= 'A' && drive <= 'Z' {
			drive = drive - 'A' + 'a' // Convert to lowercase
		}

		result := make([]byte, 0, len(path))
		result = append(result, '/', drive, '/')

		// Convert remaining path
		for i := 3; i < len(path); i++ {
			if path[i] == '\\' {
				result = append(result, '/')
			} else {
				result = append(result, path[i])
			}
		}
		return string(result)
	}

	return path
}

func (m *OptimizedMSYS2PathConverter) IsUnixPath(path string) bool {
	return len(path) > 2 && path[0] == '/' && path[2] == '/' &&
		((path[1] >= 'a' && path[1] <= 'z') || (path[1] >= 'A' && path[1] <= 'Z'))
}

func (m *OptimizedMSYS2PathConverter) IsNativePath(path string) bool {
	return len(path) >= 3 && path[1] == ':' &&
		((path[0] >= 'A' && path[0] <= 'Z') || (path[0] >= 'a' && path[0] <= 'z'))
}

// OptimizedCygwinPathConverter - High-performance Cygwin path converter
type OptimizedCygwinPathConverter struct {
	platformType string
}

func (c *OptimizedCygwinPathConverter) GetPlatformType() string {
	return c.platformType
}

func (c *OptimizedCygwinPathConverter) UnixToNative(path string) string {
	if len(path) < 12 || !strings.HasPrefix(path, "/cygdrive/") {
		return path
	}

	if path[10] >= 'a' && path[10] <= 'z' && len(path) > 11 && path[11] == '/' {
		// Fast path conversion: /cygdrive/c/path -> C:\path
		drive := path[10] - 'a' + 'A' // Convert to uppercase
		result := make([]byte, 0, len(path))
		result = append(result, drive, ':', '\\')

		// Convert remaining path
		for i := 12; i < len(path); i++ {
			if path[i] == '/' {
				result = append(result, '\\')
			} else {
				result = append(result, path[i])
			}
		}
		return string(result)
	}

	return path
}

func (c *OptimizedCygwinPathConverter) NativeToUnix(path string) string {
	if len(path) < 3 || path[1] != ':' {
		return path
	}

	if (path[0] >= 'A' && path[0] <= 'Z') || (path[0] >= 'a' && path[0] <= 'z') {
		// Fast path conversion: C:\path -> /cygdrive/c/path
		drive := path[0]
		if drive >= 'A' && drive <= 'Z' {
			drive = drive - 'A' + 'a' // Convert to lowercase
		}

		result := make([]byte, 0, len(path)+10)
		result = append(result, '/', 'c', 'y', 'g', 'd', 'r', 'i', 'v', 'e', '/', drive, '/')

		// Convert remaining path
		for i := 3; i < len(path); i++ {
			if path[i] == '\\' {
				result = append(result, '/')
			} else {
				result = append(result, path[i])
			}
		}
		return string(result)
	}

	return path
}

func (c *OptimizedCygwinPathConverter) IsUnixPath(path string) bool {
	return strings.HasPrefix(path, "/cygdrive/") ||
		strings.HasPrefix(path, "/home/") ||
		strings.HasPrefix(path, "/usr/") ||
		strings.HasPrefix(path, "/tmp/")
}

func (c *OptimizedCygwinPathConverter) IsNativePath(path string) bool {
	return len(path) >= 3 && path[1] == ':' &&
		((path[0] >= 'A' && path[0] <= 'Z') || (path[0] >= 'a' && path[0] <= 'z'))
}

// WindowsPathConverter - No-op converter for pure Windows
type WindowsPathConverter struct {
	platformType string
}

func (w *WindowsPathConverter) GetPlatformType() string {
	return w.platformType
}

func (w *WindowsPathConverter) UnixToNative(path string) string { return path }
func (w *WindowsPathConverter) NativeToUnix(path string) string { return path }
func (w *WindowsPathConverter) IsUnixPath(path string) bool     { return false }
func (w *WindowsPathConverter) IsNativePath(path string) bool {
	return len(path) >= 3 && path[1] == ':' &&
		((path[0] >= 'A' && path[0] <= 'Z') || (path[0] >= 'a' && path[0] <= 'z'))
}

// dirExists checks if a directory exists
func dirExists(path string) bool {
	info, err := os.Stat(path)
	return err == nil && info.IsDir()
}

// canRunUnixCommands tests if basic Unix commands work
func canRunUnixCommands() bool {
	// Test ls command
	cmd := exec.Command("ls", "/")
	err := cmd.Run()
	if err != nil {
		fmt.Printf("DEBUG: ls command failed: %v\n", err)
		return false
	}

	// Test pwd command
	cmd = exec.Command("pwd")
	output, err := cmd.Output()
	if err != nil {
		fmt.Printf("DEBUG: pwd command failed: %v\n", err)
		return false
	}

	pwd := strings.TrimSpace(string(output))
	fmt.Printf("DEBUG: pwd output: %s\n", pwd)

	// If pwd works and returns Unix-style path, we're in Unix environment
	return strings.HasPrefix(pwd, "/")
}

// DetectEnvironment detects environment using only parent process inspection
func DetectEnvironment() PlatformEnvironment {
	fmt.Printf("DEBUG: DetectEnvironment called - using parent process detection only\n")

	// Only reliable method: Parent process inspection
	detectedType := detectViaParentProcess()
	fmt.Printf("DEBUG: Detected environment: %s\n", detectedType)

	env := PlatformEnvironment{
		Executable: ".exe",
	}

	switch detectedType {
	case "wsl":
		env.Type = "wsl"
		env.PathSeparator = "/"
		env.UnixPathPrefix = "/mnt/c/"
		env.WindowsRoot = "C:\\"
	case "msys2":
		env.Type = "msys2"
		env.PathSeparator = "/"
		env.UnixPathPrefix = "/c/"
		env.WindowsRoot = "C:\\"
	case "cygwin":
		env.Type = "cygwin"
		env.PathSeparator = "/"
		env.UnixPathPrefix = "/cygdrive/c/"
		env.WindowsRoot = "C:\\"
	case "windows":
		env.Type = "windows"
		env.PathSeparator = "\\"
		env.UnixPathPrefix = ""
		env.WindowsRoot = "C:\\"
	default:
		panic(fmt.Sprintf("FAILED: Unknown environment type: %s", detectedType))
	}

	fmt.Printf("DEBUG: %s environment configured\n", env.Type)
	return env
}

// detectViaParentProcess inspects parent process to determine calling environment
func detectViaParentProcess() string {
	// Get current process
	currentPID := int32(os.Getpid())
	currentProc, err := process.NewProcess(currentPID)
	if err != nil {
		panic(fmt.Sprintf("FAILED: Cannot get current process: %v", err))
	}

	// Get parent process ID
	parentPID, err := currentProc.Ppid()
	if err != nil {
		panic(fmt.Sprintf("FAILED: Cannot get parent PID: %v", err))
	}

	// Get parent process
	parentProc, err := process.NewProcess(parentPID)
	if err != nil {
		panic(fmt.Sprintf("FAILED: Cannot get parent process: %v", err))
	}

	// Get parent process name
	parentName, err := parentProc.Name()
	if err != nil {
		panic(fmt.Sprintf("FAILED: Cannot get parent process name: %v", err))
	}

	// Get parent process executable path if possible
	parentExe, err := parentProc.Exe()
	if err != nil {
		fmt.Printf("DEBUG: Cannot get parent exe path: %v\n", err)
		parentExe = ""
	}

	fmt.Printf("DEBUG: Parent process - PID: %d, Name: %s, Exe: %s\n", parentPID, parentName, parentExe)

	// If parent is a shell, run uname from that shell to get real environment
	if strings.Contains(strings.ToLower(parentName), "bash") || strings.Contains(strings.ToLower(parentName), "sh") {
		return detectEnvironmentViaParentShell(parentExe)
	}

	// Handle non-shell parents
	parentExeLower := strings.ToLower(parentExe)
	switch {
	case strings.Contains(parentExeLower, "wsl"):
		return "wsl"
	case strings.Contains(parentExeLower, "cmd") || strings.Contains(parentExeLower, "powershell"):
		return "windows"
	default:
		panic(fmt.Sprintf("FAILED: Cannot determine environment from non-shell parent - Name: %s, Exe: %s", parentName, parentExe))
	}
}

// detectEnvironmentViaParentShell runs uname from the parent shell to get real environment
func detectEnvironmentViaParentShell(shellPath string) string {
	fmt.Printf("DEBUG: Running uname from parent shell: %s\n", shellPath)

	// Run uname -s from the parent shell
	cmd := exec.Command(shellPath, "-c", "uname -s")
	output, err := cmd.Output()
	if err != nil {
		panic(fmt.Sprintf("FAILED: Cannot run uname from parent shell %s: %v", shellPath, err))
	}

	unameS := strings.TrimSpace(string(output))
	fmt.Printf("DEBUG: uname -s from parent shell: %s\n", unameS)

	switch {
	case strings.HasPrefix(unameS, "CYGWIN"):
		return "cygwin"
	case strings.HasPrefix(unameS, "MSYS") || strings.HasPrefix(unameS, "MINGW"):
		return "msys2"
	case unameS == "Linux":
		// Run uname -r to check for WSL
		cmd := exec.Command(shellPath, "-c", "uname -r")
		output, err := cmd.Output()
		if err != nil {
			panic(fmt.Sprintf("FAILED: Cannot run uname -r from parent shell: %v", err))
		}
		unameR := strings.TrimSpace(string(output))
		fmt.Printf("DEBUG: uname -r from parent shell: %s\n", unameR)

		if strings.Contains(strings.ToLower(unameR), "microsoft") || strings.Contains(strings.ToLower(unameR), "wsl") {
			return "wsl"
		}
		panic(fmt.Sprintf("FAILED: Linux detected but not WSL - unknown environment. uname -r: %s", unameR))
	default:
		panic(fmt.Sprintf("FAILED: Unknown uname result from parent shell: %s", unameS))
	}
}

// allMethodsAgree checks if all detection methods return the same result
func allMethodsAgree(results []string) bool {
	if len(results) == 0 {
		return false
	}
	first := results[0]
	for _, result := range results[1:] {
		if result != first {
			return false
		}
	}
	return true
}

// detectWSL performs optimized WSL detection
func detectWSL() bool {
	// Check WSL_DISTRO_NAME environment variable (fastest)
	if os.Getenv("WSL_DISTRO_NAME") != "" {
		return true
	}

	// Check /proc/version for Microsoft signature
	if data, err := os.ReadFile("/proc/version"); err == nil {
		content := strings.ToLower(string(data))
		return strings.Contains(content, "microsoft") || strings.Contains(content, "wsl")
	}

	// Check WSLENV environment variable
	if os.Getenv("WSLENV") != "" {
		return true
	}

	return false
}

// detectMSYS2 performs optimized MSYS2 detection
func detectMSYS2() bool {
	// Check MSYSTEM environment variable
	if msystem := os.Getenv("MSYSTEM"); msystem != "" {
		return strings.HasPrefix(msystem, "MINGW") ||
			strings.HasPrefix(msystem, "MSYS") ||
			strings.HasPrefix(msystem, "CLANG")
	}

	// Check MSYSTEM_PREFIX
	if os.Getenv("MSYSTEM_PREFIX") != "" {
		return true
	}

	// Check for MSYS2-specific environment variables
	if os.Getenv("MSYS2_PATH_TYPE") != "" || os.Getenv("MSYS") != "" {
		return true
	}

	// Check PATH for MSYS2 signatures
	if path := os.Getenv("PATH"); path != "" {
		if strings.Contains(path, "msys64") || strings.Contains(path, "mingw64") ||
			strings.Contains(path, "/usr/bin") || strings.Contains(path, "/bin") {
			return true
		}
	}

	// Check if current working directory suggests MSYS2 (starts with /c/, /d/, etc.)
	if cwd, err := os.Getwd(); err == nil {
		if len(cwd) >= 3 && cwd[0] == '/' && cwd[2] == '/' &&
			((cwd[1] >= 'a' && cwd[1] <= 'z') || (cwd[1] >= 'A' && cwd[1] <= 'Z')) {
			return true
		}
	}

	return false
}

// detectCygwin performs optimized Cygwin detection
func detectCygwin() bool {
	// Check CYGWIN environment variable
	if os.Getenv("CYGWIN") != "" {
		return true
	}

	// Check PATH for Cygwin signatures
	if path := os.Getenv("PATH"); path != "" {
		return strings.Contains(path, "cygwin") || strings.Contains(path, "/usr/bin")
	}

	// Check for Cygwin-specific directories
	cygwinDirs := []string{"/proc", "/dev", "/cygdrive"}
	for _, dir := range cygwinDirs {
		if _, err := os.Stat(dir); err == nil {
			return true
		}
	}

	return false
}

// createPathConverter creates the appropriate path converter for a platform type
func createPathConverter(platformType string) PathConverter {
	switch platformType {
	case "wsl":
		return &OptimizedWSLPathConverter{platformType: platformType}
	case "msys2":
		return &OptimizedMSYS2PathConverter{platformType: platformType}
	case "cygwin":
		return &OptimizedCygwinPathConverter{platformType: platformType}
	case "windows":
		return &WindowsPathConverter{platformType: platformType}
	default:
		return &WindowsPathConverter{platformType: "unix"}
	}
}
