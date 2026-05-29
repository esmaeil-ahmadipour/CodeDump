#!/usr/bin/env bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for macOS Terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

clear

echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┃          CODE DUMP - macOS Edition               ┃"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
echo ""

# Check Python3
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}✗ Python3 is not installed${NC}"
    echo "  Install it: brew install python3"
    echo "  Or download from: https://python.org"
    read -p "Press Enter to exit..."
    exit 1
fi

# Check jq
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠ jq is not installed${NC}"
    echo "  Install it: brew install jq"
    echo ""
    echo -e "${CYAN}  Would you like to install jq now? (y/n)${NC}"
    read -p "  > " install_jq
    
    if [[ "$install_jq" == "y" || "$install_jq" == "Y" ]]; then
        if ! command -v brew &> /dev/null; then
            echo -e "${RED}✗ Homebrew is not installed${NC}"
            echo "  Install Homebrew first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        else
            brew install jq
        fi
    else
        echo -e "${YELLOW}⚠ Continuing without jq (Mode 2 will fail)${NC}"
    fi
fi

echo ""
echo "Select operation mode:"
echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┃ 1) Process ./code folder (also accepts ./CODE)    ┃"
echo "┃ 2) Process projects from settings.json           ┃"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
echo ""
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📁 Processing code folder..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        CODE_DIR=""
        if [ -d "$SCRIPT_DIR/CODE" ]; then
            CODE_DIR="$SCRIPT_DIR/CODE"
        elif [ -d "$SCRIPT_DIR/code" ]; then
            CODE_DIR="$SCRIPT_DIR/code"
        elif [ -d "$SCRIPT_DIR/Code" ]; then
            CODE_DIR="$SCRIPT_DIR/Code"
        fi
        
        if [ -z "$CODE_DIR" ]; then
            echo -e "${RED}✗ ERROR: 'code' folder not found!${NC}"
            echo "  Please create a folder named 'code' or 'CODE'"
        else
            file_count=$(find "$CODE_DIR" -type f 2>/dev/null | wc -l)
            if [ "$file_count" -eq 0 ]; then
                echo -e "${YELLOW}⚠ Warning: code folder is empty!${NC}"
            else
                echo "📂 Input folder: $CODE_DIR"
                echo "📄 Output file: $SCRIPT_DIR/code_report.txt"
                echo "📊 Found $file_count file(s) to process"
                echo ""
                
                python3 "$SCRIPT_DIR/code_dump.py" "$CODE_DIR" --single --output "$SCRIPT_DIR/code_report.txt"
                
                if [ $? -eq 0 ] && [ -f "$SCRIPT_DIR/code_report.txt" ]; then
                    size=$(du -h "$SCRIPT_DIR/code_report.txt" | cut -f1)
                    echo ""
                    echo -e "${GREEN}✓ Extraction completed successfully!${NC}"
                    echo "📄 Report saved to: $SCRIPT_DIR/code_report.txt"
                    echo "📏 File size: $size"
                    
                    # Open in default editor (macOS feature)
                    echo ""
                    read -p "Open report in TextEdit? (y/n): " open_report
                    if [[ "$open_report" == "y" || "$open_report" == "Y" ]]; then
                        open -e "$SCRIPT_DIR/code_report.txt"
                    fi
                else
                    echo -e "${RED}✗ Extraction failed!${NC}"
                fi
            fi
        fi
        ;;
    2)
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📦 Processing projects from settings.json..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        if [ ! -f "$SCRIPT_DIR/settings.json" ]; then
            echo -e "${RED}✗ ERROR: settings.json not found!${NC}"
            echo "  Create settings.json with your project configurations"
            exit 1
        fi
        
        if ! command -v jq &> /dev/null; then
            echo -e "${RED}✗ jq is required for Mode 2${NC}"
            echo "  Install it: brew install jq"
            exit 1
        fi
        
        # Validate JSON
        if ! jq empty "$SCRIPT_DIR/settings.json" 2>/dev/null; then
            echo -e "${RED}✗ Invalid JSON syntax in settings.json${NC}"
            exit 1
        fi
        
        if ! jq 'has("projects")' "$SCRIPT_DIR/settings.json" 2>/dev/null | grep -q true; then
            echo -e "${RED}✗ Missing 'projects' field in settings.json${NC}"
            exit 1
        fi
        
        project_count=$(jq '[.projects[] | select(.enabled != false)] | length' "$SCRIPT_DIR/settings.json")
        
        if [ "$project_count" -eq 0 ]; then
            echo -e "${YELLOW}⚠ No enabled projects found${NC}"
            exit 1
        fi
        
        echo -e "${GREEN}✓ Found $project_count enabled project(s)${NC}"
        
        success_count=0
        fail_count=0
        
        for i in $(seq 0 $((project_count - 1))); do
            PROJECT_NAME=$(jq -r "[.projects[] | select(.enabled != false)][$i].name // \"project_$((i+1))\"" "$SCRIPT_DIR/settings.json")
            PROJECT_PATH=$(jq -r "[.projects[] | select(.enabled != false)][$i].path" "$SCRIPT_DIR/settings.json")
            
            echo ""
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo -e "${CYAN}📦 Project: $PROJECT_NAME${NC}"
            echo "📂 Path: $PROJECT_PATH"
            
            if [ ! -d "$PROJECT_PATH" ]; then
                echo -e "${RED}✗ SKIPPED: Path does not exist${NC}"
                fail_count=$((fail_count + 1))
                continue
            fi
            
            OUTPUT_FILE="$SCRIPT_DIR/code_report_${PROJECT_NAME}.txt"
            
            python3 "$SCRIPT_DIR/code_dump.py" "$PROJECT_PATH" --single --output "$OUTPUT_FILE"
            
            if [ $? -eq 0 ] && [ -f "$OUTPUT_FILE" ] && [ -s "$OUTPUT_FILE" ]; then
                size=$(du -h "$OUTPUT_FILE" | cut -f1)
                echo -e "${GREEN}✓ Success! Report size: $size${NC}"
                success_count=$((success_count + 1))
                
                # Backup
                BACKUP_DIR="$SCRIPT_DIR/backup"
                mkdir -p "$BACKUP_DIR"
                DATESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
                cp "$OUTPUT_FILE" "$BACKUP_DIR/${PROJECT_NAME}_${DATESTAMP}.txt"
                echo "💾 Backup saved to: $BACKUP_DIR/${PROJECT_NAME}_${DATESTAMP}.txt"
            else
                echo -e "${RED}✗ Failed!${NC}"
                fail_count=$((fail_count + 1))
            fi
        done
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo -e "${GREEN}✓ Extraction complete!${NC}"
        echo "📊 Summary: $success_count successful, $fail_count failed"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        ;;
    *)
        echo -e "${RED}✗ Invalid choice! Please enter 1 or 2${NC}"
        ;;
esac

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "💡 Tip: You can drag this file to the Dock for quick access"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

read -p "Press Enter to close..."
