#!/bin/bash
set -e

PROJECT_NAME="CodeDump"
BUILD_DIR="build/linux"
DIST_DIR="dist"

mkdir -p "$BUILD_DIR" "$DIST_DIR"

# Copy files
cp bin.sh code_dump.py settings.json "$BUILD_DIR/"
chmod +x "$BUILD_DIR/bin.sh" "$BUILD_DIR/code_dump.py"

# Create README
cat > "$BUILD_DIR/README.md" << 'EOF'
# CodeDump for Linux

## Quick Start
```bash
# Install dependencies
sudo apt install python3 jq

# Run
./bin.sh
