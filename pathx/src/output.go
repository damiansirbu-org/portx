package main

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
	"regexp"
	"strings"

	"github.com/creack/pty"
)

// OutputConverter handles output stream processing and path conversion
type OutputConverter struct {
	platform       Platform
	windowsPathRegex *regexp.Regexp
	debug          bool
}

// NewOutputConverter creates an output converter for the specified platform
func NewOutputConverter(platform Platform, debug bool) *OutputConverter {
	return &OutputConverter{
		platform:       platform,
		windowsPathRegex: regexp.MustCompile(`[A-Za-z]:[\\\/][^\s]*`),
		debug:          debug,
	}
}

// executeWithOutput runs a command with PTY and converts output paths
func (oc *OutputConverter) executeWithOutput(cmd *exec.Cmd) error {
	// Start command with PTY to preserve TTY detection
	ptmx, err := pty.Start(cmd)
	if err != nil {
		return fmt.Errorf("failed to start command with PTY: %w", err)
	}
	defer ptmx.Close()

	// Handle stdin forwarding in background
	go func() {
		io.Copy(ptmx, os.Stdin)
	}()

	// Process output with path conversion
	return oc.processOutput(ptmx)
}

// processOutput reads from PTY and converts Windows paths to Unix paths
func (oc *OutputConverter) processOutput(ptmx *os.File) error {
	scanner := bufio.NewScanner(ptmx)
	scanner.Buffer(make([]byte, 0, 64*1024), 1024*1024) // Large buffer for performance

	for scanner.Scan() {
		line := scanner.Text()
		converted := oc.convertOutputLine(line)
		fmt.Fprintln(os.Stdout, converted)
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
	if !oc.containsWindowsPaths(line) {
		return line
	}

	if oc.debug {
		fmt.Fprintf(os.Stderr, "PathX: converting output: %s\n", line)
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

// executeDirect runs a command with direct I/O (no path conversion)
func (oc *OutputConverter) executeDirect(cmd *exec.Cmd) error {
	// Direct I/O inheritance for TTY preservation
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	return cmd.Run()
}

// shouldConvertOutput determines if output conversion is needed
// This is a simple heuristic - we could make it smarter in the future
func (oc *OutputConverter) shouldConvertOutput(toolPath string) bool {
	toolName := strings.ToLower(toolPath)

	// Tools that typically output file paths
	pathOutputTools := []string{"rg", "ripgrep", "fd", "find", "grep", "ag", "es"}

	for _, tool := range pathOutputTools {
		if strings.Contains(toolName, tool) {
			return true
		}
	}

	// Default to no conversion for maximum TTY compatibility
	return false
}