package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
	"regexp"
	"strings"
)

// OutputConverter handles output stream processing and path conversion
type OutputConverter struct {
	platform       Platform
	windowsPathRegex *regexp.Regexp
	debug          bool
	configManager  *ConfigManager
	toolPath       string
	skipConversion bool
}

// NewOutputConverter creates an output converter for the specified platform
func NewOutputConverter(platform Platform, debug bool) *OutputConverter {
	configManager := NewConfigManager()
	if err := configManager.LoadConfig(); err != nil && debug {
		fmt.Fprintf(os.Stderr, "PathX: Failed to load config: %v\n", err)
	}

	return &OutputConverter{
		platform:       platform,
		windowsPathRegex: regexp.MustCompile(`[A-Za-z]:[\\\/][^\s]*`),
		debug:          debug,
		configManager:  configManager,
	}
}

// SetTool configures the converter for a specific tool
func (oc *OutputConverter) SetTool(toolPath string) {
	oc.toolPath = toolPath
	oc.skipConversion = oc.configManager.ShouldSkipConversion(toolPath)

	if oc.debug {
		fmt.Fprintf(os.Stderr, "PathX: Tool %s skip conversion: %v\n", toolPath, oc.skipConversion)
	}
}

// ShouldUseDirectIO returns true if the tool should use direct I/O (no conversion)
func (oc *OutputConverter) ShouldUseDirectIO() bool {
	return oc.skipConversion
}

// ExecuteDirect runs a command with direct I/O (no path conversion)
func (oc *OutputConverter) ExecuteDirect(cmd *exec.Cmd) error {
	if oc.debug {
		fmt.Fprintf(os.Stderr, "PathX: using direct I/O for TTY preservation\n")
	}

	// Direct I/O inheritance for TTY preservation
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}

// ExecuteWithOutput runs a command with pipe-based output processing and path conversion
func (oc *OutputConverter) ExecuteWithOutput(cmd *exec.Cmd) error {
	if oc.debug {
		fmt.Fprintf(os.Stderr, "PathX: using pipe-based output conversion\n")
	}

	// Set up pipes for stdout and stderr
	stdoutPipe, err := cmd.StdoutPipe()
	if err != nil {
		return fmt.Errorf("failed to create stdout pipe: %w", err)
	}

	stderrPipe, err := cmd.StderrPipe()
	if err != nil {
		return fmt.Errorf("failed to create stderr pipe: %w", err)
	}

	// Connect stdin directly
	cmd.Stdin = os.Stdin

	// Start the command
	if err := cmd.Start(); err != nil {
		return fmt.Errorf("failed to start command: %w", err)
	}

	// Process stdout and stderr concurrently
	done := make(chan error, 2)

	// Process stdout with path conversion
	go func() {
		done <- oc.processOutputStream(stdoutPipe, os.Stdout)
	}()

	// Process stderr with path conversion
	go func() {
		done <- oc.processOutputStream(stderrPipe, os.Stderr)
	}()

	// Wait for both streams to complete
	for i := 0; i < 2; i++ {
		if err := <-done; err != nil {
			if oc.debug {
				fmt.Fprintf(os.Stderr, "PathX: stream processing error: %v\n", err)
			}
		}
	}

	// Wait for command to complete
	return cmd.Wait()
}

// processOutputStream reads from input stream and converts Windows paths to Unix paths
func (oc *OutputConverter) processOutputStream(input io.Reader, output io.Writer) error {
	scanner := bufio.NewScanner(input)
	scanner.Buffer(make([]byte, 0, 64*1024), 1024*1024) // Large buffer for performance

	for scanner.Scan() {
		line := scanner.Text()
		converted := oc.convertOutputLine(line)
		fmt.Fprintln(output, converted)
	}

	if err := scanner.Err(); err != nil {
		if oc.debug {
			fmt.Fprintf(os.Stderr, "PathX: output scanning error: %v\n", err)
		}
		return err
	}

	return nil
}

// convertOutputLine converts Windows paths in output line to Unix paths
func (oc *OutputConverter) convertOutputLine(line string) string {
	if oc.skipConversion {
		return line
	}

	// Default behavior: convert all Windows paths found
	return oc.convertAllPaths(line)
}

// convertAllPaths converts all Windows paths found in the line
func (oc *OutputConverter) convertAllPaths(line string) string {
	if !oc.containsWindowsPaths(line) {
		return line
	}

	if oc.debug {
		fmt.Fprintf(os.Stderr, "PathX: converting all paths in: %s\n", line)
	}

	converted := oc.windowsPathRegex.ReplaceAllStringFunc(line, oc.windowsToUnix)

	if oc.debug && converted != line {
		fmt.Fprintf(os.Stderr, "PathX: converted to: %s\n", converted)
	}

	return converted
}

// containsWindowsPaths checks if line contains Windows-style paths
func (oc *OutputConverter) containsWindowsPaths(line string) bool {
	return oc.windowsPathRegex.MatchString(line)
}

// windowsToUnix converts a Windows path to Unix path based on platform
func (oc *OutputConverter) windowsToUnix(path string) string {
	if len(path) < 3 || path[1] != ':' {
		return path
	}

	drive := path[0]
	if !((drive >= 'A' && drive <= 'Z') || (drive >= 'a' && drive <= 'z')) {
		return path
	}

	// Normalize path separators to backslash for consistent processing
	normalizedPath := strings.ReplaceAll(path, "/", "\\")

	switch oc.platform {
	case PlatformWSL:
		return oc.windowsToWSL(normalizedPath)
	case PlatformMSYS2:
		return oc.windowsToMSYS2(normalizedPath)
	case PlatformCygwin:
		return oc.windowsToCygwin(normalizedPath)
	}

	return path
}

// windowsToWSL converts C:\path to /mnt/c/path
func (oc *OutputConverter) windowsToWSL(path string) string {
	if len(path) < 3 || path[1] != ':' {
		return path
	}

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

// windowsToMSYS2 converts C:\path to /c/path
func (oc *OutputConverter) windowsToMSYS2(path string) string {
	if len(path) < 3 || path[1] != ':' {
		return path
	}

	drive := path[0]
	if drive >= 'A' && drive <= 'Z' {
		drive = drive - 'A' + 'a' // Convert to lowercase
	}

	result := make([]byte, 0, len(path))
	result = append(result, '/', drive, '/')

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

// windowsToCygwin converts C:\path to /cygdrive/c/path
func (oc *OutputConverter) windowsToCygwin(path string) string {
	if len(path) < 3 || path[1] != ':' {
		return path
	}

	drive := path[0]
	if drive >= 'A' && drive <= 'Z' {
		drive = drive - 'A' + 'a' // Convert to lowercase
	}

	result := make([]byte, 0, len(path)+10)
	result = append(result, '/', 'c', 'y', 'g', 'd', 'r', 'i', 'v', 'e', '/', drive, '/')

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