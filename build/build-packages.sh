#!/bin/bash
# PORTX Package Builder - Creates ZIP packages for GitHub Releases
# Usage: ./build-packages.sh

set -e

echo "Building PORTX packages for GitHub Releases..."

# Create output directory
mkdir -p releases
cd releases

echo
echo "[1/3] Creating core-bin package..."
rm -f portx-core-bin.zip
zip -r -9 portx-core-bin.zip ../../bin/
echo "Created: portx-core-bin.zip"

echo
echo "[2/3] Creating individual tool packages..."

# Loop through each tool directory in bin-tools
for tool_dir in ../../packages/*/; do
    if [ -d "$tool_dir" ]; then
        toolname=$(basename "$tool_dir")
        echo "Creating package for: $toolname"
        rm -f "portx-${toolname}.zip"
        zip -r -9 "portx-${toolname}.zip" "$tool_dir"
        echo "Created: portx-${toolname}.zip"
    fi
done

echo
echo "[3/3] Creating core system packages..."

# Create other essential packages
echo "Creating core package..."
rm -f portx-core.zip
zip -r -9 portx-core.zip ../../bin/ ../../cmd/ ../../etc/ ../../home/ 2>/dev/null || true
echo "Created: portx-core.zip"

echo "Creating git system package..."
rm -f portx-git-system.zip
zip -r -9 portx-git-system.zip ../../mingw64/ ../../usr/ 2>/dev/null || true
echo "Created: portx-git-system.zip"

echo
echo "Package creation complete!"
echo
echo "Packages created in releases/ directory:"
ls -1 *.zip

cd ..
echo
echo "Next steps:"
echo "1. Upload packages to GitHub Releases"
echo "2. Update package manager manifest"
echo "3. Remove LFS tracking"