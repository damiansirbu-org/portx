package main

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/spf13/cobra"
)

const (
	Version = "1.0.0"
)

var (
	platformFlag string
	debugFlag    bool
)

func main() {
	rootCmd := &cobra.Command{
		Use:   "pathx --platform=PLATFORM EXECUTABLE [ARGS...]",
		Short: "PathX - Bidirectional path converter for cross-platform tools",
		Long: `PathX converts Unix paths to Windows paths for input and Windows paths
to Unix paths for output, enabling seamless cross-platform tool execution.

Supported platforms:
  wsl      - Windows Subsystem for Linux (/mnt/c/...)
  msys2    - MSYS2 environment (/c/...)
  cygwin   - Cygwin environment (/cygdrive/c/...)

Examples:
  pathx --platform=wsl git status /mnt/c/repo
  pathx --platform=wsl rg "pattern" /mnt/c/src
  pathx --platform=cygwin --debug fd "*.go" /cygdrive/c/project`,
		Version: Version,
		Args:    cobra.MinimumNArgs(1),
		RunE:    runPathX,
		DisableFlagParsing: true, // We handle flags manually to avoid conflicts
	}

	if err := rootCmd.Execute(); err != nil {
		fmt.Fprintf(os.Stderr, "PathX error: %v\n", err)
		os.Exit(1)
	}
}

func runPathX(cmd *cobra.Command, args []string) error {
	// Handle special cases first
	if len(args) == 0 {
		return cmd.Help()
	}

	for _, arg := range args {
		if arg == "--help" || arg == "-h" {
			return cmd.Help()
		}
		if arg == "--version" || arg == "-v" {
			fmt.Printf("PathX %s\n", Version)
			return nil
		}
	}

	// Parse our flags manually
	pathxArgs, executablePath, execArgs, err := parsePathXArgs(args)
	if err != nil {
		return err
	}

	// Apply PathX flags
	for _, arg := range pathxArgs {
		switch {
		case strings.HasPrefix(arg, "--platform="):
			platformFlag = strings.TrimPrefix(arg, "--platform=")
		case arg == "--debug":
			debugFlag = true
		default:
			return fmt.Errorf("unknown PathX flag: %s", arg)
		}
	}

	// Validate required flags
	if platformFlag == "" {
		return fmt.Errorf("--platform flag is required")
	}

	platform, err := validatePlatform(platformFlag)
	if err != nil {
		return err
	}

	if debugFlag {
		fmt.Fprintf(os.Stderr, "PathX: platform=%s, executable=%s, args=%v\n",
			platform, executablePath, execArgs)
	}

	// Convert input arguments
	pathConverter := NewPathConverter(platform)
	convertedArgs, err := pathConverter.convertInput(execArgs)
	if err != nil {
		return fmt.Errorf("input conversion failed: %w", err)
	}

	if debugFlag && len(convertedArgs) != len(execArgs) {
		fmt.Fprintf(os.Stderr, "PathX: converted %d args\n", len(convertedArgs))
	}

	// Create command
	execCmd := exec.Command(executablePath, convertedArgs...)

	// Set up output conversion
	outputConverter := NewOutputConverter(platform, debugFlag)

	// Determine if we need output conversion
	if outputConverter.shouldConvertOutput(executablePath) {
		if debugFlag {
			fmt.Fprintf(os.Stderr, "PathX: using PTY for output conversion\n")
		}
		return outputConverter.executeWithOutput(execCmd)
	} else {
		if debugFlag {
			fmt.Fprintf(os.Stderr, "PathX: using direct I/O for TTY preservation\n")
		}
		return outputConverter.executeDirect(execCmd)
	}
}

// parsePathXArgs separates PathX flags from executable and its arguments
func parsePathXArgs(args []string) (pathxArgs []string, executable string, execArgs []string, err error) {
	var pathxFlags []string
	foundExecutable := false

	for i, arg := range args {
		if !foundExecutable {
			if strings.HasPrefix(arg, "--platform=") ||
			   arg == "--debug" ||
			   arg == "--help" ||
			   arg == "--version" {
				pathxFlags = append(pathxFlags, arg)
			} else {
				// First non-PathX argument is the executable
				executable = arg
				execArgs = args[i+1:]
				foundExecutable = true
				break
			}
		}
	}

	if !foundExecutable {
		return nil, "", nil, fmt.Errorf("no executable specified")
	}

	return pathxFlags, executable, execArgs, nil
}

// validatePlatform validates and normalizes platform string
func validatePlatform(platform string) (Platform, error) {
	switch strings.ToLower(platform) {
	case "wsl":
		return PlatformWSL, nil
	case "msys2", "msys":
		return PlatformMSYS2, nil
	case "cygwin":
		return PlatformCygwin, nil
	default:
		return "", fmt.Errorf("unsupported platform: %s (supported: wsl, msys2, cygwin)", platform)
	}
}

// checkExecutable verifies that the executable exists and is accessible
func checkExecutable(execPath string) error {
	if !filepath.IsAbs(execPath) {
		// Check if it's in PATH
		_, err := exec.LookPath(execPath)
		if err != nil {
			return fmt.Errorf("executable not found in PATH: %s", execPath)
		}
		return nil
	}

	// Check absolute path
	info, err := os.Stat(execPath)
	if err != nil {
		return fmt.Errorf("executable not found: %s", execPath)
	}

	if info.IsDir() {
		return fmt.Errorf("path is a directory, not executable: %s", execPath)
	}

	return nil
}