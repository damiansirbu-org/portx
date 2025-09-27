package main

import "fmt"

// Custom error types for better error handling and categorization

// ToolError represents errors from tool execution
type ToolError struct {
	Tool     string
	Message  string
	ExitCode int
	Cause    error
}

func (e *ToolError) Error() string {
	if e.Cause != nil {
		return fmt.Sprintf("tool '%s' failed: %s (caused by: %v)", e.Tool, e.Message, e.Cause)
	}
	return fmt.Sprintf("tool '%s' failed: %s", e.Tool, e.Message)
}

func (e *ToolError) Unwrap() error {
	return e.Cause
}

// NewToolError creates a new tool error
func NewToolError(tool, message string, exitCode int, cause error) *ToolError {
	return &ToolError{
		Tool:     tool,
		Message:  message,
		ExitCode: exitCode,
		Cause:    cause,
	}
}

// ConfigError represents configuration-related errors
type ConfigError struct {
	Message string
	Cause   error
}

func (e *ConfigError) Error() string {
	if e.Cause != nil {
		return fmt.Sprintf("configuration error: %s (caused by: %v)", e.Message, e.Cause)
	}
	return fmt.Sprintf("configuration error: %s", e.Message)
}

func (e *ConfigError) Unwrap() error {
	return e.Cause
}

// NewConfigError creates a new configuration error
func NewConfigError(message string, cause error) *ConfigError {
	return &ConfigError{
		Message: message,
		Cause:   cause,
	}
}

// PlatformError represents platform detection or path conversion errors
type PlatformError struct {
	Platform string
	Message  string
	Cause    error
}

func (e *PlatformError) Error() string {
	if e.Cause != nil {
		return fmt.Sprintf("platform error (%s): %s (caused by: %v)", e.Platform, e.Message, e.Cause)
	}
	return fmt.Sprintf("platform error (%s): %s", e.Platform, e.Message)
}

func (e *PlatformError) Unwrap() error {
	return e.Cause
}

// NewPlatformError creates a new platform error
func NewPlatformError(platform, message string, cause error) *PlatformError {
	return &PlatformError{
		Platform: platform,
		Message:  message,
		Cause:    cause,
	}
}

// PathConversionError represents path conversion specific errors
type PathConversionError struct {
	OriginalPath string
	TargetFormat string
	Message      string
	Cause        error
}

func (e *PathConversionError) Error() string {
	if e.Cause != nil {
		return fmt.Sprintf("path conversion error: cannot convert '%s' to %s format: %s (caused by: %v)",
			e.OriginalPath, e.TargetFormat, e.Message, e.Cause)
	}
	return fmt.Sprintf("path conversion error: cannot convert '%s' to %s format: %s",
		e.OriginalPath, e.TargetFormat, e.Message)
}

func (e *PathConversionError) Unwrap() error {
	return e.Cause
}

// NewPathConversionError creates a new path conversion error
func NewPathConversionError(originalPath, targetFormat, message string, cause error) *PathConversionError {
	return &PathConversionError{
		OriginalPath: originalPath,
		TargetFormat: targetFormat,
		Message:      message,
		Cause:        cause,
	}
}
