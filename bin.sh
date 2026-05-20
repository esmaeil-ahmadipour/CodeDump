#!/usr/bin/env bash

echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┃          CODE DUMP - DUAL MODE               ┃"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
echo ""

# Store script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/settings.json"

# Default values
SKIP_MENU=false

# Check if config exists and has skip_menu option
if [ -f "$CONFIG_FILE" ]; then
    echo "✓ Configuration loaded: settings.json"
    
    if command -v jq &> /dev/null; then
        # Check if extraction is enabled globally
        ENABLED=$(jq -r '.enabled // true' "$CONFIG_FILE")
        if [ "$ENABLED" = "false" ]; then
            echo "❌ Extraction is disabled in settings.json"
            exit 0
        fi
        
        # Check if skip_menu is enabled
        SKIP_MENU=$(jq -r '.skip_menu // false' "$CONFIG_FILE")
        if [ "$SKIP_MENU" = "true" ]; then
            echo "🚀 Headless mode: skip_menu enabled"
        fi
    fi
else
    echo "ℹ️ No settings.json found, using defaults"
fi

# Function to process projects from JSON
process_projects() {
    if [ ! -f "$CONFIG_FILE" ]; then
        echo "❌ settings.json not found!"
        return 1
    fi
    
    if ! command -v jq &> /dev/null; then
        echo "❌ jq is required. Install it: sudo apt install jq"
        return 1
    fi
    
    # Get enabled projects
    PROJECT_COUNT=$(jq '[.projects[] | select(.enabled != false)] | length' "$CONFIG_FILE")
    
    if [ "$PROJECT_COUNT" -eq 0 ]; then
        echo "❌ No enabled projects found in settings.json"
        return 1
    fi
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Processing projects from settings.json..."
    echo ""
    
    # Process each project
    for i in $(seq 0 $((PROJECT_COUNT - 1))); do
        PROJECT_PATH=$(jq -r "[.projects[] | select(.enabled != false)][$i].path" "$CONFIG_FILE")
        PROJECT_NAME=$(jq -r "[.projects[] | select(.enabled != false)][$i].name // \"Untitled_$(date +%Y%m%d_%H%M%S)\"" "$CONFIG_FILE")
        
        if [ -z "$PROJECT_PATH" ] || [ "$PROJECT_PATH" = "null" ]; then
            echo "⚠️ Skipping project $PROJECT_NAME: No path specified"
            continue
        fi
        
        if [ ! -d "$PROJECT_PATH" ]; then
            echo "⚠️ Skipping $PROJECT_NAME: Path does not exist - $PROJECT_PATH"
            continue
        fi
        
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📦 Project: $PROJECT_NAME"
        echo "📂 Path: $PROJECT_PATH"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        # Process the project
        python3 "$SCRIPT_DIR/code_dump.py" "$PROJECT_PATH" --single --output "$SCRIPT_DIR/code_report_${PROJECT_NAME}.txt"
        
        if [ $? -eq 0 ] && [ -f "$SCRIPT_DIR/code_report_${PROJECT_NAME}.txt" ] && [ -s "$SCRIPT_DIR/code_report_${PROJECT_NAME}.txt" ]; then
            # Backup the report
            BACKUP_DIR="$SCRIPT_DIR/backup"
            mkdir -p "$BACKUP_DIR"
            DATESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
            cp "$SCRIPT_DIR/code_report_${PROJECT_NAME}.txt" "$BACKUP_DIR/${PROJECT_NAME}_${DATESTAMP}.txt"
            echo "✓ Backed up to: $BACKUP_DIR/${PROJECT_NAME}_${DATESTAMP}.txt"
            
            # Show file size
            FILE_SIZE=$(du -h "$SCRIPT_DIR/code_report_${PROJECT_NAME}.txt" | cut -f1)
            echo "📄 Report size: $FILE_SIZE"
        else
            echo "❌ Failed to extract or report is empty"
        fi
        
        echo ""
    done
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ All projects processed"
    return 0
}

# Function to process current directory
process_current_dir() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Processing current directory..."
    echo ""
    
    # Handle backup folder temporarily
    BACKUP_PATH="$SCRIPT_DIR/backup"
    ROOT_BACKUP_EXISTED=false
    
    if [ -d "$BACKUP_PATH" ]; then
        echo "⚠️ Backup folder detected - temporarily excluding"
        mv "$BACKUP_PATH" "$SCRIPT_DIR/.backup_excluded"
        ROOT_BACKUP_EXISTED=true
    fi
    
    cd "$SCRIPT_DIR"
    python3 code_dump.py --single --output "$SCRIPT_DIR/code_report.txt"
    PYTHON_EXIT_CODE=$?
    
    if [ "$ROOT_BACKUP_EXISTED" = true ]; then
        mv "$SCRIPT_DIR/.backup_excluded" "$BACKUP_PATH"
        echo "✓ Backup folder restored"
    fi
    
    # Backup the report
    if [ $PYTHON_EXIT_CODE -eq 0 ] && [ -f "$SCRIPT_DIR/code_report.txt" ] && [ -s "$SCRIPT_DIR/code_report.txt" ]; then
        mkdir -p "$BACKUP_PATH"
        DATESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
        cp "$SCRIPT_DIR/code_report.txt" "$BACKUP_PATH/code_report_${DATESTAMP}.txt"
        echo "✓ Report backed up to: $BACKUP_PATH/code_report_${DATESTAMP}.txt"
        echo ""
        echo "📄 FINAL REPORT: $SCRIPT_DIR/code_report.txt"
        
        FILE_SIZE=$(du -h "$SCRIPT_DIR/code_report.txt" | cut -f1)
        echo "📄 Report size: $FILE_SIZE"
    else
        echo "❌ Failed to extract or report is empty"
    fi
}

# Main logic
if [ "$SKIP_MENU" = "true" ]; then
    # Skip menu - directly process projects from JSON
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "Headless mode: Processing projects automatically..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    process_projects
else
    # Show menu for user selection
    echo ""
    echo "Select operation mode:"
    echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo "┃ 1) Current directory (scan all folders)          ┃"
    echo "┃ 2) Use settings.json projects                    ┃"
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    echo ""
    read -p "Enter your choice (1 or 2): " choice
    
    if [[ "$choice" != "1" && "$choice" != "2" ]]; then
        echo "❌ Invalid choice!"
        exit 1
    fi
    
    if [ "$choice" == "2" ]; then
        process_projects
    else
        process_current_dir
    fi
fi

# List all reports in script directory
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📋 All reports in $SCRIPT_DIR:"
ls -la "$SCRIPT_DIR"/code_report_*.txt 2>/dev/null || echo "   No reports found"
echo ""
echo "💾 Backups in $SCRIPT_DIR/backup"

# Auto close
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "This window will close automatically in 5 seconds..."
for i in {5..1}; do
    echo -n "$i... "
    sleep 1
done
echo "Exit"
