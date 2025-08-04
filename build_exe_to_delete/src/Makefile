# PORTX Build System
# Industry-standard C project structure with TCC compiler

# Configuration
TARGET_EXEC := portx.exe
SRC_DIR := .
BUILD_DIR := ../bin
DIST_DIR := ../bin

# Compiler settings - using build/tools directory
CC := ../tools/tinycc/tcc.exe
CFLAGS := -Wall -O2 -I../tools/tinycc/include
LDFLAGS := -L../tools/tinycc/lib

# Source files
SOURCES := $(wildcard $(SRC_DIR)/*.c)
OBJECTS := $(SOURCES:$(SRC_DIR)/%.c=$(BUILD_DIR)/%.o)
RESOURCE := $(BUILD_DIR)/portx.res

# Default target
.PHONY: all clean install test

all: $(DIST_DIR)/$(TARGET_EXEC)

# Create directories
$(BUILD_DIR) $(DIST_DIR):
	mkdir -p $@

# Compile object files
$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	@echo "Compiling $<..."
	$(CC) $(CFLAGS) -c $< -o $@

# Compile resource file
$(RESOURCE): $(SRC_DIR)/portx.rc | $(BUILD_DIR)
	@echo "Compiling resource file..."
	../tools/tinycc/tiny_impdef.exe -o $@ $<

# Link executable
$(DIST_DIR)/$(TARGET_EXEC): $(OBJECTS) | $(DIST_DIR)
	@echo "Linking $(TARGET_EXEC)..."
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	@echo "✅ Build complete: $(DIST_DIR)/$(TARGET_EXEC)"

# Install target (copy to portx/bin for system use)
install: $(DIST_DIR)/$(TARGET_EXEC)
	@echo "Installing $(TARGET_EXEC) to portx/bin/..."
	mkdir -p ../../bin/
	cp $(DIST_DIR)/$(TARGET_EXEC) ../../bin/
	@echo "✅ Installed: ../../bin/$(TARGET_EXEC)"

# Test target
test: $(DIST_DIR)/$(TARGET_EXEC)
	@echo "Testing PORTX executable..."
	$(DIST_DIR)/$(TARGET_EXEC) version
	$(DIST_DIR)/$(TARGET_EXEC) status
	@echo "✅ Tests completed"

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR) $(DIST_DIR)
	rm -f bin/$(TARGET_EXEC)
	@echo "✅ Clean complete"

# Show build configuration
info:
	@echo "PORTX Build Configuration"
	@echo "========================"
	@echo "Target: $(TARGET_EXEC)"
	@echo "Compiler: $(CC)"
	@echo "Flags: $(CFLAGS)"
	@echo "Sources: $(SOURCES)"
	@echo "Objects: $(OBJECTS)"
	@echo "Build Dir: $(BUILD_DIR)"
	@echo "Dist Dir: $(DIST_DIR)"

# Help target
help:
	@echo "PORTX Build System"
	@echo "=================="
	@echo ""
	@echo "Available targets:"
	@echo "  all      - Build the executable (default)"
	@echo "  install  - Install to bin/ directory"
	@echo "  test     - Run basic tests"
	@echo "  clean    - Remove build artifacts"
	@echo "  info     - Show build configuration"
	@echo "  help     - Show this help"
	@echo ""
	@echo "Example usage:"
	@echo "  make           # Build portx.exe"
	@echo "  make install   # Build and install to bin/"
	@echo "  make test      # Build and test"
	@echo "  make clean     # Clean up"