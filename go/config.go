package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"

	"go.uber.org/zap"
)

// GlobalConfig represents global configuration with exclusions
type GlobalConfig struct {
	Exclusions Exclusions `json:"exclusions"`
}

// Config represents the complete application configuration
type Config struct {
	Tools         map[string]*ToolConfig `json:"tools"`
	GlobalRules   *ParameterRules        `json:"-"`                // DEPRECATED - not serialized
	GlobalConfig  *GlobalConfig          `json:"_global_"`
	PlatformEnv   PlatformEnvironment    `json:"platform"`
	PortxRoot     string                 `json:"portx_root"`
	Logger        *zap.Logger            `json:"-"`
}

// ToolConfig represents configuration for a specific tool
type ToolConfig struct {
	Name             string                 `json:"name"`
	Package          string                 `json:"package"`
	WindowsPath      string                 `json:"windows_path"`
	ParameterRules   ParameterRules         `json:"parameter_rules"`   // DEPRECATED
	Exclusions       Exclusions             `json:"exclusions"`
	OutputConversion OutputConversionConfig `json:"output_conversion"`
	CrossPlatform    CrossPlatformConfig    `json:"cross_platform"`   // DEPRECATED - use Env
	Env              CrossPlatformConfig    `json:"env"`
}

// ParameterRules defines how to handle different parameter types (DEPRECATED - use Exclusions)
type ParameterRules struct {
	AfterFlags  []string `json:"after_flags"`
	BeforeFlags []string `json:"before_flags"`
	AtPositions []int    `json:"at_positions"`
}

// Exclusions defines rules for excluding arguments from path conversion
type Exclusions struct {
	BeforeFlag []string `json:"beforeFlag"`
	AfterFlag  []string `json:"afterFlag"`
	AtPosition []int    `json:"atPosition"`
	Pattern    []string `json:"pattern"`
}

// OutputConversionConfig controls output path conversion
type OutputConversionConfig struct {
	Enabled  bool     `json:"enabled"`
	Type     string   `json:"type"`
	Patterns []string `json:"patterns"`
}

// CrossPlatformConfig defines platform-specific behavior
type CrossPlatformConfig struct {
	SupportsStreaming bool     `json:"supports_streaming"`
	RequiresShell     bool     `json:"requires_shell"`
	EnvironmentVars   []string `json:"environment_vars"`
	WorkingDirectory  string   `json:"working_directory"`
	DefaultArgs       []string `json:"default_args"`
}

// PackageConfig represents a package configuration from portx.json
type PackageConfig struct {
	Name        string              `json:"name"`
	Version     string              `json:"version"`
	Description string              `json:"description"`
	ImportType  string              `json:"importType"`
	Bin         map[string]BinEntry `json:"bin"`
}

// BinEntry represents a binary/executable within a package
type BinEntry struct {
	Path        string   `json:"path"`
	DefaultArgs []string `json:"defaultArgs"`
	Description string   `json:"description"`
}

// LoadConfig discovers and loads configuration for all tools
func LoadConfig(logger *zap.Logger) (*Config, error) {
	config := &Config{
		Tools:  make(map[string]*ToolConfig),
		Logger: logger,
	}

	// Detect platform environment
	config.PlatformEnv = DetectEnvironment()
	config.PortxRoot = detectPortxRoot()

	logger.Info("Loading PORTX configuration",
		zap.String("portx_root", config.PortxRoot),
		zap.String("platform", config.PlatformEnv.Type),
	)

	// Load tool configurations from tool-configs.json only
	if err := config.loadToolConfigs(); err != nil {
		logger.Warn("Failed to load tool configurations, using defaults", zap.Error(err))
	}

	logger.Info("Configuration loaded successfully",
		zap.Int("total_tools", len(config.Tools)),
	)

	return config, nil
}

// detectPortxRoot finds the PORTX installation directory
func detectPortxRoot() string {
	// Try environment variable first
	if root := os.Getenv("PORTX_ROOT"); root != "" {
		return root
	}

	// Try relative to current executable
	if execPath, err := os.Executable(); err == nil {
		// Assume structure: PORTX/go/portx-wrap.exe
		if possibleRoot := filepath.Join(filepath.Dir(execPath), ".."); possibleRoot != "" {
			if _, err := os.Stat(filepath.Join(possibleRoot, "packages")); err == nil {
				return possibleRoot
			}
		}
	}

	// Default locations based on platform
	defaultPaths := []string{
		"C:\\App\\PORTX",
		"/mnt/c/App/PORTX",
		"/c/App/PORTX",
		"/cygdrive/c/App/PORTX",
	}

	for _, path := range defaultPaths {
		if _, err := os.Stat(filepath.Join(path, "packages")); err == nil {
			return path
		}
	}

	// Fallback
	return "C:\\App\\PORTX"
}

// No package discovery - removed

// loadToolConfigs loads tool configurations from tool-configs.json
func (c *Config) loadToolConfigs() error {
	configPath := filepath.Join(c.PortxRoot, "go", "config", "tool-configs.json")

	data, err := os.ReadFile(configPath)
	if err != nil {
		return fmt.Errorf("failed to read tool configs: %w", err)
	}

	var configs map[string]*ToolConfig
	if err := json.Unmarshal(data, &configs); err != nil {
		return fmt.Errorf("failed to parse tool configs: %w", err)
	}

	// Load all tool configs
	for toolName, config := range configs {
		if toolName == "_global_" {
			continue
		}
		c.Tools[toolName] = config
	}

	c.Logger.Debug("Loaded tool configurations", zap.String("path", configPath), zap.Int("tools", len(c.Tools)))
	return nil
}


func (c *Config) needsOutputConversion(toolName string) bool {
	return toolName == "rg" || toolName == "fd" || toolName == "find" || toolName == "es"
}

func (c *Config) getOutputConversionType(toolName string) string {
	switch toolName {
	case "rg", "grep":
		return "path_in_results"
	case "fd", "find", "es":
		return "pure_file_paths"
	default:
		return "none"
	}
}
