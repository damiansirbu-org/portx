package main

import (
	"encoding/json"
	"fmt"
	"os"
	"path/filepath"
	"strings"
)

// OutputExceptionConfig defines the complete output exception configuration
type OutputExceptionConfig struct {
	SchemaVersion string                       `json:"_schema_version"`
	Description   string                       `json:"_description"`
	OutputExceptions OutputExceptions         `json:"output_exceptions"`
}

// OutputExceptions contains all output exception categories
type OutputExceptions struct {
	Description       string                       `json:"_description"`
	InteractiveTools  ToolCategory                `json:"interactive_tools"`
}

// ToolCategory defines behavior for a category of tools
type ToolCategory struct {
	Description        string   `json:"_description"`
	Tools              []string `json:"tools"`
	ConversionSkip     bool     `json:"conversion_skip,omitempty"`
}

// ConfigManager handles loading and querying tool configurations
type ConfigManager struct {
	config *OutputExceptionConfig
	loaded bool
}

// NewConfigManager creates a new configuration manager
func NewConfigManager() *ConfigManager {
	return &ConfigManager{}
}

// LoadConfig loads the tool-exceptions.json configuration
func (cm *ConfigManager) LoadConfig() error {
	if cm.loaded {
		return nil
	}

	// Try multiple possible config paths
	configPaths := []string{
		"config/tool-exceptions.json",
		"../config/tool-exceptions.json",
		"/App/PORTX/pathx/config/tool-exceptions.json",
		"C:/App/PORTX/pathx/config/tool-exceptions.json",
	}

	var configPath string
	for _, path := range configPaths {
		if _, err := os.Stat(path); err == nil {
			configPath = path
			break
		}
	}

	if configPath == "" {
		return fmt.Errorf("tool-exceptions.json not found in any expected location")
	}

	data, err := os.ReadFile(configPath)
	if err != nil {
		return fmt.Errorf("failed to read config file %s: %w", configPath, err)
	}

	cm.config = &OutputExceptionConfig{}
	if err := json.Unmarshal(data, cm.config); err != nil {
		return fmt.Errorf("failed to parse config file %s: %w", configPath, err)
	}

	cm.loaded = true
	return nil
}

// ShouldSkipConversion returns true if the tool should skip output conversion
func (cm *ConfigManager) ShouldSkipConversion(toolPath string) bool {
	if !cm.loaded {
		return false
	}

	toolName := cm.extractToolName(toolPath)

	// Check if tool is in the conversion skip list
	if cm.containsTool(cm.config.OutputExceptions.InteractiveTools.Tools, toolName) {
		return cm.config.OutputExceptions.InteractiveTools.ConversionSkip
	}

	// Default: convert all Windows paths
	return false
}

// extractToolName extracts the tool name from a path
func (cm *ConfigManager) extractToolName(toolPath string) string {
	toolName := filepath.Base(toolPath)
	// Remove common extensions
	for _, ext := range []string{".exe", ".cmd", ".bat", ".sh"} {
		if strings.HasSuffix(strings.ToLower(toolName), ext) {
			toolName = toolName[:len(toolName)-len(ext)]
			break
		}
	}
	return strings.ToLower(toolName)
}

// containsTool checks if a tool name is in the given list
func (cm *ConfigManager) containsTool(tools []string, toolName string) bool {
	for _, tool := range tools {
		if strings.EqualFold(tool, toolName) {
			return true
		}
	}
	return false
}

