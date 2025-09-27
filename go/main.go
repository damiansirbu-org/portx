package main

import (
	"context"
	"fmt"
	"os"
	"runtime"
	"time"

	"github.com/spf13/cobra"
	"go.uber.org/zap"
	"go.uber.org/zap/zapcore"
)

// Version information
const (
	Version   = "3.0.0"
	BuildTime = "2025-09-27"
	GitCommit = "enhanced"
)

// Application represents the main PORTX universal wrapper
type Application struct {
	wrapper     *UniversalWrapper
	logger      *zap.Logger
	config      *Config
	atomicLevel zap.AtomicLevel
}

// Initialize sets up the application with all dependencies
func (app *Application) Initialize() error {
	var err error

	// Initialize structured logging with default level
	if err = app.initializeLogger(); err != nil {
		return fmt.Errorf("failed to initialize logger: %w", err)
	}

	// Load configuration
	if app.config, err = LoadConfig(app.logger); err != nil {
		app.logger.Error("Failed to load configuration", zap.Error(err))
		return fmt.Errorf("failed to load config: %w", err)
	}

	// Initialize wrapper with dependency injection
	if app.wrapper, err = NewUniversalWrapper(app.config, app.logger); err != nil {
		app.logger.Error("Failed to initialize wrapper", zap.Error(err))
		return fmt.Errorf("failed to initialize wrapper: %w", err)
	}

	app.logger.Info("PORTX Universal Wrapper initialized",
		zap.String("version", Version),
		zap.String("build_time", BuildTime),
		zap.String("platform", runtime.GOOS),
		zap.String("arch", runtime.GOARCH),
		zap.String("detected_env", app.config.PlatformEnv.Type),
		zap.Int("supported_tools", len(app.config.Tools)),
	)

	return nil
}

// initializeLogger creates a structured logger with appropriate levels
func (app *Application) initializeLogger() error {
	config := zap.NewProductionConfig()

	// Configure log level based on environment (start with ErrorLevel)
	if os.Getenv("PORTX_DEBUG") != "" {
		config.Level = zap.NewAtomicLevelAt(zap.InfoLevel)
	} else {
		config.Level = zap.NewAtomicLevelAt(zap.ErrorLevel)
	}

	// Store the atomic level for runtime changes
	app.atomicLevel = config.Level

	// Configure encoder for readability
	config.EncoderConfig.TimeKey = "timestamp"
	config.EncoderConfig.EncodeTime = zapcore.ISO8601TimeEncoder
	config.EncoderConfig.CallerKey = "caller"
	config.EncoderConfig.EncodeCaller = zapcore.ShortCallerEncoder

	var err error
	app.logger, err = config.Build()
	return err
}

// Execute runs the tool wrapper with comprehensive error handling
func (app *Application) Execute(args []string) error {
	if len(args) == 0 {
		return fmt.Errorf("no tool specified - usage: portx-wrap <tool> [args...]")
	}

	// Separate wrapper flags from tool arguments
	wrapperFlags, toolName, toolArgs := app.parseWrapperFlags(args)

	if toolName == "" {
		return fmt.Errorf("no tool specified after wrapper flags - usage: portx-wrap [--portxDebug] <tool> [args...]")
	}

	// Apply wrapper flags
	debugMode := contains(wrapperFlags, "--portxDebug")
	if debugMode {
		// Enable debug level logging
		app.atomicLevel.SetLevel(zap.InfoLevel)
		app.logger.Info("Debug mode enabled via wrapper flag",
			zap.String("tool", toolName),
			zap.Strings("args", toolArgs),
		)
	}

	// Create execution context with timeout
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Minute)
	defer cancel()

	// Execute tool with full context (wrapper flags already removed)
	if debugMode {
		app.logger.Info("About to call ExecuteTool",
			zap.String("tool", toolName),
			zap.Strings("args", toolArgs),
			zap.Bool("wrapper_nil", app.wrapper == nil),
		)
	}
	result, err := app.wrapper.ExecuteTool(ctx, toolName, toolArgs, debugMode)
	if err != nil {
		if debugMode {
			app.logger.Info("ExecuteTool returned error",
				zap.Error(err),
			)
		}
		app.logger.Error("Tool execution failed",
			zap.String("tool", toolName),
			zap.Strings("args", toolArgs),
			zap.Error(err),
		)
		return err
	}

	if debugMode {
		app.logger.Info("ExecuteTool completed successfully",
			zap.Int("exit_code", result.ExitCode),
		)
	}

	// Log successful execution
	app.logger.Debug("Tool execution completed",
		zap.String("tool", toolName),
		zap.Duration("duration", result.Duration),
		zap.Int("exit_code", result.ExitCode),
	)

	// Exit with original tool's exit code
	if result.ExitCode != 0 {
		os.Exit(result.ExitCode)
	}

	return nil
}

// parseWrapperFlags separates wrapper flags from tool arguments
// Returns: wrapperFlags, toolName, toolArgs
func (app *Application) parseWrapperFlags(args []string) ([]string, string, []string) {
	var wrapperFlags []string
	var remainingArgs []string

	// Known wrapper flags
	knownWrapperFlags := map[string]bool{
		"--portxDebug": true,
	}

	// Separate wrapper flags from other arguments
	for _, arg := range args {
		if knownWrapperFlags[arg] {
			wrapperFlags = append(wrapperFlags, arg)
		} else {
			remainingArgs = append(remainingArgs, arg)
		}
	}

	// First remaining argument is tool name, rest are tool arguments
	if len(remainingArgs) == 0 {
		return wrapperFlags, "", []string{}
	}

	toolName := remainingArgs[0]
	toolArgs := remainingArgs[1:]

	return wrapperFlags, toolName, toolArgs
}

// contains checks if a slice contains a specific string
func contains(slice []string, item string) bool {
	for _, s := range slice {
		if s == item {
			return true
		}
	}
	return false
}

// Shutdown performs graceful cleanup
func (app *Application) Shutdown() error {
	if app.logger != nil {
		app.logger.Info("Shutting down PORTX Universal Wrapper")
		_ = app.logger.Sync()
	}
	return nil
}

// main entry point with comprehensive error handling and performance tracking
func main() {
	app := &Application{}

	// Initialize application
	if err := app.Initialize(); err != nil {
		fmt.Fprintf(os.Stderr, "Initialization failed: %v\n", err)
		os.Exit(1)
	}

	// Setup graceful shutdown
	defer func() {
		if err := app.Shutdown(); err != nil {
			fmt.Fprintf(os.Stderr, "Shutdown error: %v\n", err)
		}
	}()

	// Create CLI with Cobra for advanced features
	rootCmd := &cobra.Command{
		Use:     "portx-wrap [tool] [args...]",
		Short:   "Universal PORTX tool wrapper with intelligent path conversion",
		Long:    "High-performance, cross-platform wrapper for PORTX tools with automatic path conversion, streaming I/O, and comprehensive debugging.",
		Version: Version,
		Example: `  portx-wrap git --version
  portx-wrap rg "pattern" /mnt/c/path
  portx-wrap --portxDebug fd "*.go" /mnt/c/project`,
		DisableFlagParsing: true,
		SilenceUsage:       true,
		SilenceErrors:      true,
		Args:               cobra.MinimumNArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			return app.Execute(args)
		},
	}

	// Special handling for version command
	rootCmd.SetVersionTemplate(`PORTX Universal Wrapper {{.Version}}
Build Time: ` + BuildTime + `
Git Commit: ` + GitCommit + `
Platform: ` + runtime.GOOS + `/` + runtime.GOARCH + `
Go Version: ` + runtime.Version() + `
`)

	// Execute with proper error handling
	if err := rootCmd.Execute(); err != nil {
		// Handle specific error types
		switch e := err.(type) {
		case *ToolError:
			os.Exit(e.ExitCode)
		case *ConfigError:
			fmt.Fprintf(os.Stderr, "Configuration error: %v\n", e.Message)
			os.Exit(2)
		case *PlatformError:
			fmt.Fprintf(os.Stderr, "Platform error: %v\n", e.Message)
			os.Exit(3)
		default:
			fmt.Fprintf(os.Stderr, "Error: %v\n", err)
			os.Exit(1)
		}
	}
}
