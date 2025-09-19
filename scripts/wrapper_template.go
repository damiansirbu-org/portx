package main

import (
	"fmt"
	"os"
	"os/exec"
	"runtime"
	"strings"
)

const (
	PackageName    = "{{PACKAGE_NAME}}"
	ExecutableName = "{{EXECUTABLE_NAME}}"
	ExecutionType  = "{{EXECUTION_TYPE}}"
	DefaultArgs    = "{{DEFAULT_ARGS}}"
)

func main() {
	// Build the target path based on environment
	var targetPath string
	if runtime.GOOS == "windows" {
		targetPath = fmt.Sprintf("C:\\App\\Git\\home\\portx\\packages\\%s\\%s", PackageName, ExecutableName)
	} else {
		targetPath = fmt.Sprintf("/c/App/Git/home/portx/packages/%s/%s", PackageName, ExecutableName)
	}

	// Prepare command and arguments
	var cmd *exec.Cmd
	var args []string

	// Add default args if they exist
	if DefaultArgs != "" && DefaultArgs != "{{DEFAULT_ARGS}}" {
		args = append(args, strings.Fields(DefaultArgs)...)
	}

	// Add user-provided args
	args = append(args, os.Args[1:]...)

	// Create command based on execution type
	switch ExecutionType {
	case "shell_script", "shell_script_with_args":
		// Execute shell script via bash
		shellArgs := []string{targetPath}
		shellArgs = append(shellArgs, args...)
		cmd = exec.Command("C:\\App\\Git\\bin\\bash.exe", shellArgs...)
	case "direct_exe", "direct_exe_with_args":
		// Execute .exe directly
		cmd = exec.Command(targetPath, args...)
	default:
		// Default to direct execution
		cmd = exec.Command(targetPath, args...)
	}

	// Inherit environment and run
	cmd.Env = os.Environ()
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	// Execute and exit with same code
	if err := cmd.Run(); err != nil {
		if exitError, ok := err.(*exec.ExitError); ok {
			os.Exit(exitError.ExitCode())
		}
		os.Exit(1)
	}
}