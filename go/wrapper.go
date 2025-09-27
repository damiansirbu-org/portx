package main

import (
	"bufio"
	"context"
	"fmt"
	"io"
	"os"
	"os/exec"
	"regexp"
	"strings"
	"sync"
	"time"

	"github.com/spf13/pflag"
	"go.uber.org/zap"
)

// ParsedArgument represents a properly parsed command line argument
type ParsedArgument struct {
	Type     string // "flag", "positional", "flag_value"
	Original string // Original argument text
	Flag     string // Flag name (for flags and flag values)
	Value    string // Value (for flag values and positionals)
	Position int    // Position in argument list
}

// ParsedCommandLine represents the structured result of command line parsing
type ParsedCommandLine struct {
	Arguments []ParsedArgument
	Tool      string
}

// ExecutionResult represents the result of a tool execution
type ExecutionResult struct {
	ExitCode int
	Duration time.Duration
	Tool     string
	Args     []string
}

// UniversalWrapper provides high-performance cross-platform tool execution
type UniversalWrapper struct {
	config        *Config
	logger        *zap.Logger
	pathConverter PathConverter
	regexCache    map[string]*regexp.Regexp
	mutex         sync.RWMutex
}

// NewUniversalWrapper creates a new universal wrapper instance
func NewUniversalWrapper(config *Config, logger *zap.Logger) (*UniversalWrapper, error) {
	wrapper := &UniversalWrapper{
		config:        config,
		logger:        logger,
		pathConverter: GetPathConverter(config.PlatformEnv.Type),
		regexCache:    make(map[string]*regexp.Regexp),
	}

	// Pre-compile commonly used regex patterns for performance
	wrapper.precompileRegexPatterns()

	logger.Debug("Universal wrapper initialized",
		zap.String("platform", config.PlatformEnv.Type),
		zap.String("path_converter", wrapper.pathConverter.GetPlatformType()),
	)

	return wrapper, nil
}

// precompileRegexPatterns compiles frequently used regex patterns for performance
func (uw *UniversalWrapper) precompileRegexPatterns() {
	patterns := map[string]string{
		"embedded_path":      `(--[a-zA-Z-]+[=])(/[^\\s]+)`,
		"windows_path":       `[A-Za-z]:[\\\\][^\\s]*`,
		"regex_pattern":      `[\^${}()]|\{[0-9,]*\}|\(\?\:`,
		"unix_absolute_path": `^/[^\\s]*`,
		"parameter_flag":     `^--?[a-zA-Z]`,
	}

	for name, pattern := range patterns {
		if compiled, err := regexp.Compile(pattern); err == nil {
			uw.regexCache[name] = compiled
		} else {
			uw.logger.Warn("Failed to compile regex pattern",
				zap.String("name", name),
				zap.String("pattern", pattern),
				zap.Error(err),
			)
		}
	}
}

// ExecuteTool executes a tool with comprehensive error handling and performance tracking
func (uw *UniversalWrapper) ExecuteTool(ctx context.Context, toolName string, args []string, debugMode bool) (*ExecutionResult, error) {
	startTime := time.Now()

	if debugMode {
		uw.logger.Info("ExecuteTool called",
			zap.String("tool", toolName),
			zap.Strings("args", args),
		)
	}

	// Note: Wrapper flags like --portxDebug are now filtered in main.go
	// This function receives only clean tool arguments

	// Get tool configuration
	toolConfig, exists := uw.config.Tools[toolName]
	if !exists {
		return nil, NewToolError(toolName, "tool not found in configuration", 127, nil)
	}

	// Build executable path
	execPath := uw.buildExecutablePath(toolConfig)

	// Process parameters with intelligent path conversion
	processedArgs, err := uw.processParameters(toolConfig, args, debugMode)
	if err != nil {
		return nil, NewToolError(toolName, "parameter processing failed", 1, err)
	}

	if debugMode {
		uw.logger.Info("Tool execution details",
			zap.String("tool", toolName),
			zap.String("executable", execPath),
			zap.Strings("original_args", args),
			zap.Strings("processed_args", processedArgs),
			zap.String("platform", uw.pathConverter.GetPlatformType()),
		)
	}

	// Execute tool with streaming I/O
	exitCode, err := uw.executeWithStreaming(ctx, execPath, processedArgs, toolConfig, debugMode)
	if err != nil {
		return nil, NewToolError(toolName, "execution failed", exitCode, err)
	}

	duration := time.Since(startTime)

	result := &ExecutionResult{
		ExitCode: exitCode,
		Duration: duration,
		Tool:     toolName,
		Args:     args,
	}

	if debugMode {
		uw.logger.Info("Tool execution completed",
			zap.String("tool", toolName),
			zap.Duration("duration", duration),
			zap.Int("exit_code", exitCode),
		)
	}

	return result, nil
}

// buildExecutablePath constructs the correct executable path for the current platform
func (uw *UniversalWrapper) buildExecutablePath(config *ToolConfig) string {
	// Always use Windows path since we're calling Windows executables
	return config.WindowsPath
}

// parseCommandLine properly parses command line arguments using pflag
func (uw *UniversalWrapper) parseCommandLine(args []string) *ParsedCommandLine {
	parsed := &ParsedCommandLine{
		Arguments: make([]ParsedArgument, 0, len(args)),
	}

	// Create a new FlagSet for parsing without defining specific flags
	flagSet := pflag.NewFlagSet("tool", pflag.ContinueOnError)
	flagSet.SetOutput(io.Discard) // Suppress error output

	// Parse to separate flags from positional arguments
	// We don't pre-define flags, just let pflag do the parsing
	flagSet.ParseErrorsWhitelist.UnknownFlags = true

	// Use a custom approach to parse the arguments
	flagValues := make(map[string]string)
	positionalArgs := make([]string, 0)
	positionalCount := 0

	i := 0
	for i < len(args) {
		arg := args[i]

		if strings.HasPrefix(arg, "--") {
			// Long flag
			if strings.Contains(arg, "=") {
				// --flag=value format
				parts := strings.SplitN(arg, "=", 2)
				flagName := parts[0]
				value := parts[1]

				flagValues[flagName] = value
				parsed.Arguments = append(parsed.Arguments, ParsedArgument{
					Type:     "flag_with_value",
					Original: arg,
					Flag:     flagName,
					Value:    value,
					Position: i,
				})
			} else {
				// --flag format, check if next arg is value
				parsed.Arguments = append(parsed.Arguments, ParsedArgument{
					Type:     "flag",
					Original: arg,
					Flag:     arg,
					Value:    "",
					Position: i,
				})

				// Check if next argument is the flag's value (not starting with -)
				if i+1 < len(args) && !strings.HasPrefix(args[i+1], "-") {
					i++
					flagValues[arg] = args[i]
					parsed.Arguments = append(parsed.Arguments, ParsedArgument{
						Type:     "flag_value",
						Original: args[i],
						Flag:     arg,
						Value:    args[i],
						Position: i,
					})
				}
			}
		} else if strings.HasPrefix(arg, "-") && len(arg) > 1 && arg != "--" {
			// Short flag(s)
			if len(arg) == 2 {
				// Single short flag -f
				parsed.Arguments = append(parsed.Arguments, ParsedArgument{
					Type:     "flag",
					Original: arg,
					Flag:     arg,
					Value:    "",
					Position: i,
				})

				// Check if next argument is the flag's value
				if i+1 < len(args) && !strings.HasPrefix(args[i+1], "-") {
					i++
					flagValues[arg] = args[i]
					parsed.Arguments = append(parsed.Arguments, ParsedArgument{
						Type:     "flag_value",
						Original: args[i],
						Flag:     arg,
						Value:    args[i],
						Position: i,
					})
				}
			} else {
				// Multiple short flags like -abc (treat as single flag for now)
				parsed.Arguments = append(parsed.Arguments, ParsedArgument{
					Type:     "flag",
					Original: arg,
					Flag:     arg,
					Value:    "",
					Position: i,
				})
			}
		} else {
			// Positional argument (or after --)
			positionalArgs = append(positionalArgs, arg)
			parsed.Arguments = append(parsed.Arguments, ParsedArgument{
				Type:     "positional",
				Original: arg,
				Flag:     "",
				Value:    arg,
				Position: positionalCount,
			})
			positionalCount++
		}

		i++
	}

	return parsed
}

// processParameters handles intelligent parameter processing with path conversion
func (uw *UniversalWrapper) processParameters(config *ToolConfig, args []string, debugMode bool) ([]string, error) {
	if len(args) == 0 {
		return args, nil
	}

	// Always log the original command line input
	if debugMode {
		uw.logger.Info("Original command line input",
			zap.Strings("raw_args", args),
			zap.String("joined_command", strings.Join(args, " ")),
			zap.Int("arg_count", len(args)),
		)
	}

	// Parse command line properly
	parsed := uw.parseCommandLine(args)

	// Log how arguments were tokenized
	if debugMode {
		tokenInfo := make([]string, 0, len(parsed.Arguments))
		for _, arg := range parsed.Arguments {
			tokenInfo = append(tokenInfo, fmt.Sprintf("%s[%s]=%s", arg.Type, arg.Flag, arg.Value))
		}
		uw.logger.Info("Argument tokenization results",
			zap.Strings("tokenized", tokenInfo),
			zap.Int("total_tokens", len(parsed.Arguments)),
		)
	}

	// Process each parsed argument
	processed := make([]string, 0, len(args))

	for _, parsedArg := range parsed.Arguments {
		convertedArg := uw.convertParsedArgument(config, parsedArg, debugMode)

		// Handle different argument types for reconstruction
		switch parsedArg.Type {
		case "flag_with_value":
			// Reconstruct --flag=value format
			if convertedArg != parsedArg.Value {
				processed = append(processed, parsedArg.Flag+"="+convertedArg)
			} else {
				processed = append(processed, parsedArg.Original)
			}
		case "flag":
			processed = append(processed, parsedArg.Original)
		case "flag_value", "positional":
			processed = append(processed, convertedArg)
		}
	}

	// Log final processed command line
	if debugMode {
		uw.logger.Info("Final processed command line",
			zap.Strings("processed_args", processed),
			zap.String("final_command", strings.Join(processed, " ")),
			zap.Int("changes_made", len(args)-len(processed)),
		)
	}

	return processed, nil
}

// convertParsedArgument handles conversion of a properly parsed argument
func (uw *UniversalWrapper) convertParsedArgument(config *ToolConfig, parsedArg ParsedArgument, debugMode bool) string {
	if debugMode {
		uw.logger.Info("Processing parsed argument",
			zap.String("type", parsedArg.Type),
			zap.String("flag", parsedArg.Flag),
			zap.String("value", parsedArg.Value),
			zap.Int("position", parsedArg.Position),
		)
	}

	// Skip empty values
	if parsedArg.Value == "" {
		return parsedArg.Value
	}

	// Check if this argument should never be converted based on new rules
	if uw.shouldSkipConversion(config, parsedArg, debugMode) {
		if debugMode {
			uw.logger.Info("Skipping conversion based on rules",
				zap.String("value", parsedArg.Value),
				zap.String("reason", "rule match"),
			)
		}
		return parsedArg.Value
	}

	// Check if it's a regex pattern (skip conversion)
	if uw.isRegexPattern(parsedArg.Value) {
		if debugMode {
			uw.logger.Debug("Skipping conversion (regex pattern)", zap.String("value", parsedArg.Value))
		}
		return parsedArg.Value
	}

	// Only convert if it's an absolute Unix path
	if uw.pathConverter.IsUnixPath(parsedArg.Value) {
		converted := uw.pathConverter.UnixToNative(parsedArg.Value)
		if debugMode {
			uw.logger.Info("Path conversion result",
				zap.String("original", parsedArg.Value),
				zap.String("converted", converted),
				zap.Bool("was_converted", converted != parsedArg.Value),
			)
		}
		return converted
	}

	if debugMode {
		uw.logger.Info("Path not recognized as Unix path",
			zap.String("value", parsedArg.Value),
			zap.String("platform", uw.pathConverter.GetPlatformType()),
		)
	}

	return parsedArg.Value
}

// shouldSkipConversion checks if argument should be skipped based on rule system
func (uw *UniversalWrapper) shouldSkipConversion(config *ToolConfig, parsedArg ParsedArgument, debugMode bool) bool {
	switch parsedArg.Type {
	case "flag_value":
		// Check global after_flags rules
		if uw.config.GlobalRules != nil {
			for _, afterFlag := range uw.config.GlobalRules.AfterFlags {
				if parsedArg.Flag == afterFlag {
					return true
				}
			}
		}
		// Check tool-specific after_flags
		for _, afterFlag := range config.ParameterRules.AfterFlags {
			if parsedArg.Flag == afterFlag {
				return true
			}
		}
	case "positional":
		// Check global at_positions rules
		if uw.config.GlobalRules != nil {
			for _, skipPos := range uw.config.GlobalRules.AtPositions {
				if parsedArg.Position == skipPos {
					return true
				}
			}
		}
		// Check tool-specific at_positions
		for _, skipPos := range config.ParameterRules.AtPositions {
			if parsedArg.Position == skipPos {
				return true
			}
		}
	}

	return false
}

// convertParameter handles intelligent parameter conversion with caching
func (uw *UniversalWrapper) convertParameter(config *ToolConfig, arg string, position int, debugMode bool) string {
	if debugMode {
		uw.logger.Info("Processing parameter",
			zap.String("arg", arg),
			zap.Int("position", position),
		)
	}

	// Skip empty arguments
	if arg == "" {
		return arg
	}

	// Skip conversion - exclusion logic will be implemented later

	// Check if it's a regex pattern (skip conversion)
	if uw.isRegexPattern(arg) {
		if debugMode {
			uw.logger.Debug("Skipping conversion (regex pattern)", zap.String("arg", arg))
		}
		return arg
	}

	// Handle embedded paths (--param=/path)
	if converted := uw.convertEmbeddedPath(arg, debugMode); converted != arg {
		return converted
	}

	// Handle standalone paths
	if uw.pathConverter.IsUnixPath(arg) {
		converted := uw.pathConverter.UnixToNative(arg)
		if debugMode {
			uw.logger.Info("Path conversion result",
				zap.String("original", arg),
				zap.String("converted", converted),
				zap.Bool("was_converted", converted != arg),
			)
		}
		return converted
	}

	if debugMode {
		uw.logger.Info("Path not recognized as Unix path",
			zap.String("arg", arg),
			zap.String("platform", uw.pathConverter.GetPlatformType()),
		)
	}

	return arg
}

// shouldNeverConvert - removed, replaced with new rule-based exclusion system

// isRegexPattern checks if an argument is likely a regex pattern
func (uw *UniversalWrapper) isRegexPattern(arg string) bool {
	if regex, exists := uw.regexCache["regex_pattern"]; exists {
		return regex.MatchString(arg)
	}
	return false
}

// convertEmbeddedPath handles embedded path conversion (--param=/path)
func (uw *UniversalWrapper) convertEmbeddedPath(arg string, debugMode bool) string {
	if !strings.Contains(arg, "=") {
		return arg
	}

	equalsIndex := strings.Index(arg, "=")
	if equalsIndex <= 0 || equalsIndex >= len(arg)-1 {
		return arg
	}

	paramPart := arg[:equalsIndex+1]
	pathPart := arg[equalsIndex+1:]

	if uw.pathConverter.IsUnixPath(pathPart) {
		converted := paramPart + uw.pathConverter.UnixToNative(pathPart)
		if debugMode {
			uw.logger.Debug("Converted embedded path",
				zap.String("original", arg),
				zap.String("converted", converted),
			)
		}
		return converted
	}

	return arg
}

// executeWithStreaming executes a tool with real-time streaming I/O
func (uw *UniversalWrapper) executeWithStreaming(ctx context.Context, execPath string, args []string, config *ToolConfig, debugMode bool) (int, error) {
	// Create command with context for timeout support
	cmd := exec.CommandContext(ctx, execPath, args...)

	// Set working directory if specified
	if config.CrossPlatform.WorkingDirectory != "" {
		cmd.Dir = uw.pathConverter.UnixToNative(config.CrossPlatform.WorkingDirectory)
	}

	// Set environment variables
	cmd.Env = append(os.Environ(), config.CrossPlatform.EnvironmentVars...)

	// Direct I/O inheritance - critical for TTY detection in tools like Claude Code
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	// Run the command and wait for completion
	cmdErr := cmd.Run()

	// Extract exit code
	exitCode := 0
	if cmdErr != nil {
		if exitError, ok := cmdErr.(*exec.ExitError); ok {
			exitCode = exitError.ExitCode()
		} else {
			exitCode = 1
		}
	}

	return exitCode, nil
}

// processOutputStream handles real-time output stream processing with path conversion
func (uw *UniversalWrapper) processOutputStream(input io.Reader, output io.Writer, config *ToolConfig, debugMode bool) {
	if !config.OutputConversion.Enabled {
		// No conversion needed - direct high-performance copy
		io.Copy(output, input)
		return
	}

	// Line-by-line processing for path conversion
	scanner := bufio.NewScanner(input)
	scanner.Buffer(make([]byte, 0, 64*1024), 1024*1024) // Larger buffer for performance

	for scanner.Scan() {
		line := scanner.Text()
		converted := uw.convertOutputLine(line, config, debugMode)
		fmt.Fprintln(output, converted)
	}

	if err := scanner.Err(); err != nil && debugMode {
		uw.logger.Warn("Output scanning error", zap.Error(err))
	}
}

// convertOutputLine converts paths in output lines based on tool configuration
func (uw *UniversalWrapper) convertOutputLine(line string, config *ToolConfig, debugMode bool) string {
	switch config.OutputConversion.Type {
	case "path_in_results":
		// Convert embedded Windows paths to Unix (e.g., ripgrep output)
		if regex, exists := uw.regexCache["windows_path"]; exists {
			converted := regex.ReplaceAllStringFunc(line, uw.pathConverter.NativeToUnix)
			if debugMode && converted != line {
				uw.logger.Debug("Converted output line",
					zap.String("original", line),
					zap.String("converted", converted),
				)
			}
			return converted
		}

	case "pure_file_paths":
		// Convert entire line if it's a file path (e.g., fd output)
		if uw.pathConverter.IsNativePath(line) {
			converted := uw.pathConverter.NativeToUnix(line)
			if debugMode && converted != line {
				uw.logger.Debug("Converted file path",
					zap.String("original", line),
					zap.String("converted", converted),
				)
			}
			return converted
		}
	}

	return line
}
