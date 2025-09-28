package main

import (
	"io"
	"regexp"
	"strings"

	"github.com/spf13/pflag"
)

// ArgType represents the type of a parsed argument
type ArgType string

const (
	ArgFlag      ArgType = "flag"
	ArgFlagValue ArgType = "flag_value"
	ArgFlagWith  ArgType = "flag_with_value"
	ArgPos       ArgType = "positional"
)

// ParsedArg represents a properly parsed command line argument
type ParsedArg struct {
	Type     ArgType
	Original string
	Flag     string
	Value    string
	Position int
}

// Platform represents the target platform for path conversion
type Platform string

const (
	PlatformWSL    Platform = "wsl"
	PlatformMSYS2  Platform = "msys2"
	PlatformCygwin Platform = "cygwin"
)

// PathConverter handles platform-specific path conversion
type PathConverter struct {
	platform     Platform
	unixPathRegex *regexp.Regexp
}

// NewPathConverter creates a path converter for the specified platform
func NewPathConverter(platform Platform) *PathConverter {
	return &PathConverter{
		platform:     platform,
		unixPathRegex: regexp.MustCompile(`^/[^/\s]*/.*`),
	}
}

// convertInput processes command line arguments and converts Unix paths to Windows
func (pc *PathConverter) convertInput(args []string) ([]string, error) {
	if len(args) == 0 {
		return args, nil
	}

	parsed := pc.parseArgs(args)
	return pc.convertParsedArgs(parsed), nil
}

// parseArgs tokenizes command line arguments using pflag logic
func (pc *PathConverter) parseArgs(args []string) []ParsedArg {
	var parsed []ParsedArg
	flagSet := pflag.NewFlagSet("tool", pflag.ContinueOnError)
	flagSet.SetOutput(io.Discard)
	flagSet.ParseErrorsWhitelist.UnknownFlags = true

	posCount := 0
	i := 0

	for i < len(args) {
		arg := args[i]

		if strings.HasPrefix(arg, "--") {
			if strings.Contains(arg, "=") {
				// --flag=value format
				parts := strings.SplitN(arg, "=", 2)
				parsed = append(parsed, ParsedArg{
					Type:     ArgFlagWith,
					Original: arg,
					Flag:     parts[0],
					Value:    parts[1],
					Position: i,
				})
			} else {
				// --flag format, check if next arg is value
				parsed = append(parsed, ParsedArg{
					Type:     ArgFlag,
					Original: arg,
					Flag:     arg,
					Value:    "",
					Position: i,
				})

				if i+1 < len(args) && !strings.HasPrefix(args[i+1], "-") {
					i++
					parsed = append(parsed, ParsedArg{
						Type:     ArgFlagValue,
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
				parsed = append(parsed, ParsedArg{
					Type:     ArgFlag,
					Original: arg,
					Flag:     arg,
					Value:    "",
					Position: i,
				})

				if i+1 < len(args) && !strings.HasPrefix(args[i+1], "-") {
					i++
					parsed = append(parsed, ParsedArg{
						Type:     ArgFlagValue,
						Original: args[i],
						Flag:     arg,
						Value:    args[i],
						Position: i,
					})
				}
			} else {
				// Multiple short flags -abc (treat as single flag)
				parsed = append(parsed, ParsedArg{
					Type:     ArgFlag,
					Original: arg,
					Flag:     arg,
					Value:    "",
					Position: i,
				})
			}
		} else {
			// Positional argument
			parsed = append(parsed, ParsedArg{
				Type:     ArgPos,
				Original: arg,
				Flag:     "",
				Value:    arg,
				Position: posCount,
			})
			posCount++
		}

		i++
	}

	return parsed
}

// convertParsedArgs converts parsed arguments, handling each type appropriately
func (pc *PathConverter) convertParsedArgs(parsed []ParsedArg) []string {
	var result []string

	for _, arg := range parsed {
		switch arg.Type {
		case ArgFlagWith:
			// Reconstruct --flag=value with converted value
			converted := pc.convertPath(arg.Value)
			if converted != arg.Value {
				result = append(result, arg.Flag+"="+converted)
			} else {
				result = append(result, arg.Original)
			}
		case ArgFlag:
			result = append(result, arg.Original)
		case ArgFlagValue, ArgPos:
			converted := pc.convertPath(arg.Value)
			result = append(result, converted)
		}
	}

	return result
}

// convertPath converts a Unix path to Windows path based on platform
func (pc *PathConverter) convertPath(path string) string {
	if !pc.isUnixPath(path) {
		return path
	}

	switch pc.platform {
	case PlatformWSL:
		return pc.convertWSLPath(path)
	case PlatformMSYS2:
		return pc.convertMSYS2Path(path)
	case PlatformCygwin:
		return pc.convertCygwinPath(path)
	}

	return path
}

// isUnixPath checks if a path is a Unix absolute path
func (pc *PathConverter) isUnixPath(path string) bool {
	if len(path) < 2 {
		return false
	}

	// Don't convert regex patterns that look like paths
	if pc.isRegexPattern(path) {
		return false
	}

	return pc.unixPathRegex.MatchString(path)
}

// isRegexPattern checks if a string is likely a regex pattern
func (pc *PathConverter) isRegexPattern(s string) bool {
	// Simple heuristics for regex patterns
	regexChars := []string{"^", "$", ".*", ".+", "\\d", "\\w", "\\s", "[", "]", "(", ")", "{", "}"}
	for _, char := range regexChars {
		if strings.Contains(s, char) {
			return true
		}
	}
	return false
}

// convertWSLPath converts /mnt/c/path to C:\path
func (pc *PathConverter) convertWSLPath(path string) string {
	if len(path) < 7 || !strings.HasPrefix(path, "/mnt/") {
		return path
	}

	if path[5] >= 'a' && path[5] <= 'z' && len(path) > 6 && path[6] == '/' {
		drive := path[5] - 'a' + 'A'
		result := make([]byte, 0, len(path))
		result = append(result, drive, ':', '\\')

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

// convertMSYS2Path converts /c/path to C:\path
func (pc *PathConverter) convertMSYS2Path(path string) string {
	if len(path) < 3 || path[0] != '/' {
		return path
	}

	// Check if it's a valid drive letter
	if !((path[1] >= 'a' && path[1] <= 'z') || (path[1] >= 'A' && path[1] <= 'Z')) {
		return path
	}

	// Must have '/' after drive letter
	if path[2] != '/' {
		return path
	}

	drive := path[1]
	if drive >= 'a' && drive <= 'z' {
		drive = drive - 'a' + 'A'
	}

	// Handle root path /c/
	if len(path) == 3 {
		return string([]byte{drive, ':', '\\'})
	}

	// Handle longer paths /c/path
	result := make([]byte, 0, len(path))
	result = append(result, drive, ':', '\\')

	for i := 3; i < len(path); i++ {
		if path[i] == '/' {
			result = append(result, '\\')
		} else {
			result = append(result, path[i])
		}
	}
	return string(result)
}

// convertCygwinPath converts /cygdrive/c/path to C:\path
func (pc *PathConverter) convertCygwinPath(path string) string {
	if len(path) < 12 || !strings.HasPrefix(path, "/cygdrive/") {
		return path
	}

	if path[10] >= 'a' && path[10] <= 'z' && len(path) > 11 && path[11] == '/' {
		drive := path[10] - 'a' + 'A'
		result := make([]byte, 0, len(path))
		result = append(result, drive, ':', '\\')

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