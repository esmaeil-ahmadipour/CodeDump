#!/bin/bash
set -e

BUILD_DIR="build/macos"
DIST_DIR="dist"

mkdir -p "$BUILD_DIR" "$DIST_DIR"

cp bin.sh code_dump.py settings.json "$BUILD_DIR/"
chmod +x "$BUILD_DIR/bin.sh" "$BUILD_DIR/code_dump.py"

# Create double-click launcher
cat > "$BUILD_DIR/run.command" << 'EOF'
#!/usr/bin/env bash
cd "$(dirname "$0")"
clear
echo "🍎 CodeDump for macOS"
echo ""
./bin.sh
EOF
chmod +x "$BUILD_DIR/run.command"

tar -czvf "$DIST_DIR/CodeDump-macOS.tar.gz" -C "$BUILD_DIR" .

echo "✅ macOS build complete"
