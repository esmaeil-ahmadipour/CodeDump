#!/usr/bin/env bash

echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┃          CODE DUMP - DUAL MODE                    ┃"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
echo ""


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="$SCRIPT_DIR/settings.json"

# ============================================
# Colors for better output
# ============================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================
# Find CODE folder (case insensitive)
# ============================================
find_code_folder() {

    
    # Check for code (lowercase)
    if [ -d "$SCRIPT_DIR/code" ]; then
        echo "$SCRIPT_DIR/code"
        return 0
    fi
    
 
    
    return 1
}

# ============================================
# JSON validation function
# ============================================
validate_json() {
    local json_file="$1"
    
    # Check 1: File exists?
    if [ ! -f "$json_file" ]; then
        echo -e "${RED}✗ Configuration file not found: $json_file${NC}"
        return 1
    fi
    
    # Check 2: File is not empty?
    if [ ! -s "$json_file" ]; then
        echo -e "${RED}✗ Configuration file is empty: $json_file${NC}"
        return 1
    fi
    
    # Check 3: jq is installed?
    if ! command -v jq &> /dev/null; then
        echo -e "${RED}✗ jq is required but not installed${NC}"
        echo -e "${YELLOW}  Install it: sudo apt install jq${NC}"
        return 1
    fi
    
    # Check 4: Validate JSON syntax
    if ! jq empty "$json_file" 2>/dev/null; then
        echo -e "${RED}✗ Invalid JSON syntax in configuration file${NC}"
        echo -e "${YELLOW}  Common issues: trailing commas, missing quotes, or extra brackets${NC}"
        echo ""
        echo -e "${BLUE}  Error details:${NC}"
        jq -r '""' "$json_file" 2>&1 | head -3
        return 1
    fi
    
    # Check 5: Required fields exist
    local has_projects=$(jq 'has("projects")' "$json_file" 2>/dev/null)
    
    if [ "$has_projects" != "true" ]; then
        echo -e "${RED}✗ Missing 'projects' field in configuration${NC}"
        echo -e "${YELLOW}  Your settings.json should have a 'projects' array${NC}"
        return 1
    fi
    
    # Check 6: projects must be an array
    local is_array=$(jq 'if .projects | type == "array" then true else false end' "$json_file")
    if [ "$is_array" != "true" ]; then
        echo -e "${RED}✗ 'projects' must be an array, not an object${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ Configuration file is valid${NC}"
    return 0
}

# ============================================
# Validate enabled projects
# ============================================
validate_projects() {
    local json_file="$1"
    
    local enabled_count=$(jq '[.projects[] | select(.enabled != false)] | length' "$json_file" 2>/dev/null)
    
    if [ "$enabled_count" -eq 0 ]; then
        echo -e "${YELLOW}⚠ No enabled projects found in settings.json${NC}"
        echo -e "${YELLOW}  Make sure at least one project has 'enabled': true${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ Found $enabled_count enabled project(s)${NC}"
    
    # Validate each project
    local issues=0
    for i in $(seq 0 $((enabled_count - 1))); do
        local name=$(jq -r "[.projects[] | select(.enabled != false)][$i].name // \"unnamed\"" "$json_file")
        local path=$(jq -r "[.projects[] | select(.enabled != false)][$i].path // \"\"" "$json_file")
        
        if [ -z "$path" ] || [ "$path" = "null" ] || [ "$path" = "" ]; then
            echo -e "${RED}  ✗ Project '$name': missing path${NC}"
            issues=$((issues + 1))
        elif [ ! -d "$path" ]; then
            echo -e "${YELLOW}  ⚠ Project '$name': path does not exist: $path${NC}"
            issues=$((issues + 1))
        else
            echo -e "${GREEN}  ✓ Project '$name': ready${NC}"
        fi
    done
    
    if [ $issues -gt 0 ]; then
        echo -e "${YELLOW}⚠ $issues project(s) have issues (check paths)${NC}"
    fi
    
    return 0
}

# ============================================
# Mode 1: Process CODE/code folder
# ============================================
process_code() {
    local CODE_DIR=$(find_code_folder)
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📁 Processing code folder..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    if [ -z "$CODE_DIR" ]; then
        echo -e "${RED}✗ ERROR: 'code' folder not found!${NC}"
        echo "  Please create a folder named 'code' (lowercase) or 'CODE' (uppercase)"
        echo "  Example: mkdir -p \"$SCRIPT_DIR/code\""
        return 1
    fi
    
    # Check if code folder has files
    local file_count=$(find "$CODE_DIR" -type f 2>/dev/null | wc -l)
    if [ "$file_count" -eq 0 ]; then
        echo -e "${YELLOW}⚠ Warning: code folder is empty!${NC}"
        echo "  Add some files to process."
        return 1
    fi
    
    echo "📂 Input folder: $CODE_DIR"
    echo "📄 Output file: $SCRIPT_DIR/code_report.txt"
    echo "📊 Found $file_count file(s) to process"
    echo ""
    
    python3 "$SCRIPT_DIR/code_dump.py" "$CODE_DIR" --single --output "$SCRIPT_DIR/code_report.txt"
    local exit_code=$?
    
    if [ $exit_code -eq 0 ] && [ -f "$SCRIPT_DIR/code_report.txt" ] && [ -s "$SCRIPT_DIR/code_report.txt" ]; then
        echo ""
        echo -e "${GREEN}✓ Extraction completed successfully!${NC}"
        echo "📄 Report saved to: $SCRIPT_DIR/code_report.txt"
        echo "📏 File size: $(du -h "$SCRIPT_DIR/code_report.txt" | cut -f1)"
        return 0
    else
        echo -e "${RED}✗ Extraction failed (exit code: $exit_code)${NC}"
        return 1
    fi
}

# ============================================
# Mode 2: Process projects from settings.json
# ============================================
process_projects() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 Processing projects from settings.json..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Step 1: Validate JSON
    echo ""
    echo "🔍 Validating configuration file..."
    if ! validate_json "$CONFIG_FILE"; then
        echo -e "${RED}✗ Cannot proceed due to invalid configuration${NC}"
        return 1
    fi
    
    # Step 2: Validate projects
    echo ""
    echo "🔍 Checking projects..."
    validate_projects "$CONFIG_FILE"
    
    # Step 3: Get enabled projects
    local project_count=$(jq '[.projects[] | select(.enabled != false)] | length' "$CONFIG_FILE")
    local success_count=0
    local fail_count=0
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🚀 Starting extraction..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    for i in $(seq 0 $((project_count - 1))); do
        PROJECT_NAME=$(jq -r "[.projects[] | select(.enabled != false)][$i].name" "$CONFIG_FILE")
        PROJECT_PATH=$(jq -r "[.projects[] | select(.enabled != false)][$i].path" "$CONFIG_FILE")
        
        # Set default name if missing
        if [ -z "$PROJECT_NAME" ] || [ "$PROJECT_NAME" = "null" ]; then
            PROJECT_NAME="project_$((i+1))"
        fi
        
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📦 Project: $PROJECT_NAME"
        echo "📂 Path: $PROJECT_PATH"
        
        # Check if path exists
        if [ ! -d "$PROJECT_PATH" ]; then
            echo -e "${RED}✗ SKIPPED: Path does not exist${NC}"
            fail_count=$((fail_count + 1))
            continue
        fi
        
        OUTPUT_FILE="$SCRIPT_DIR/code_report_${PROJECT_NAME}.txt"
        
        echo "▶️ Running code_dump.py..."
        python3 "$SCRIPT_DIR/code_dump.py" "$PROJECT_PATH" --single --output "$OUTPUT_FILE"
        local exit_code=$?
        
        if [ $exit_code -eq 0 ] && [ -f "$OUTPUT_FILE" ] && [ -s "$OUTPUT_FILE" ]; then
            local file_size=$(du -h "$OUTPUT_FILE" | cut -f1)
            echo -e "${GREEN}✓ Success! Report size: $file_size${NC}"
            success_count=$((success_count + 1))
            
            # Create backup
            BACKUP_DIR="$SCRIPT_DIR/backup"
            mkdir -p "$BACKUP_DIR"
            DATESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
            cp "$OUTPUT_FILE" "$BACKUP_DIR/${PROJECT_NAME}_${DATESTAMP}.txt"
            echo "💾 Backup saved to: $BACKUP_DIR/${PROJECT_NAME}_${DATESTAMP}.txt"
        else
            echo -e "${RED}✗ Failed! Exit code: $exit_code${NC}"
            fail_count=$((fail_count + 1))
        fi
    done
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}✓ Extraction complete!${NC}"
    echo "📊 Summary: $success_count successful, $fail_count failed"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ============================================
# Main Menu
# ============================================
echo "Select operation mode:"
echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
echo "┃ 1) Process ./code folder (also accepts ./CODE)    ┃"
echo "┃ 2) Process projects from settings.json           ┃"
echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
echo ""
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1) process_code ;;
    2) process_projects ;;
    *) echo -e "${RED}✗ Invalid choice! Please enter 1 or 2${NC}" ;;
esac

echo ""
read -p "Press Enter to close..."
