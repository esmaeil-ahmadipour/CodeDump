# 📚 **API Reference**

Technical reference for command-line interface, exit codes, and integration patterns.

## 🖥️ **Command-Line Interface**

### **code_dump.py**

```bash
usage: code_dump.py [-h] [--single] [--output OUTPUT] [--config CONFIG] [--no-config] [target_dir]

Extract text files from directories

positional arguments:
  target_dir            Target directory to process (default: current directory)
  --no-config           Ignore settings.json file (use only default settings)

optional arguments:
  -h, --help            Show this help message and exit
  --single, -s          Create single combined report
  --output OUTPUT, -o OUTPUT
                        Output filename (default: code_report.txt)
  --config CONFIG, -c CONFIG
                        Path to settings.json config file
```

### **bin.sh**

```bash
usage: ./bin.sh

No command-line arguments. Configuration via settings.json.
Interactive menu or headless mode based on skip_menu setting.
```

## 🔢 **Exit Codes**

| Code | Meaning | Description                                        |
| ---- | ------- | -------------------------------------------------- |
| `0`  | Success | Extraction completed successfully                  |
| `1`  | Error   | General error (invalid input, missing files, etc.) |

## 🎮 **Usage Examples**

### **Basic Usage**

```bash
# Process current directory
python3 code_dump.py

# Process specific directory
python3 code_dump.py /path/to/project

# Custom output file
python3 code_dump.py /path/to/project --output myreport.txt

# Use custom config
python3 code_dump.py --config myconfig.json
```

### **Programmatic Usage (Python)**

```python
import subprocess
import sys

# Run extractor from Python
result = subprocess.run([
    sys.executable,
    'code_dump.py',
    '/path/to/project',
    '--single',
    '--output', 'report.txt'
])

if result.returncode == 0:
    print("Extraction successful")
else:
    print("Extraction failed")
```

### **Shell Script Integration**

```bash
#!/bin/bash

# Run extractor and check result
if python3 code_dump.py /path/to/project --output report.txt; then
    echo "✅ Report generated: report.txt"

    # Optional: Send report via email
    mail -s "Code Report" user@example.com < report.txt
else
    echo "❌ Extraction failed"
    exit 1
fi
```

## 🔄 **Integration Examples**

### **Cron Job (Daily Backup)**

```bash
# Edit crontab
crontab -e

# Add line for daily execution at 2 AM
0 2 * * * /path/to/text-extractor/bin.sh >> /var/log/text-extractor.log 2>&1
```

**Weekly with different config:**

```bash
# Weekly on Monday at 9 AM
0 9 * * 1 /path/to/text-extractor/bin.sh --config /path/to/weekly-config.json
```

### **GitHub Actions**

```yaml
name: Extract Code Reports

on:
  schedule:
    - cron: "0 2 * * *" # Daily at 2 AM
  workflow_dispatch: # Manual trigger

jobs:
  extract:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: "3.10"

      - name: Install jq
        run: sudo apt-get install -y jq

      - name: Run CODE DUMP
        run: |
          chmod +x bin.sh code_dump.py
          ./bin.sh

      - name: Upload Reports
        uses: actions/upload-artifact@v3
        with:
          name: code-reports
          path: code_report_*.txt

      - name: Upload Backups
        uses: actions/upload-artifact@v3
        with:
          name: backups
          path: backup/*.txt
```

### **GitLab CI/CD**

```yaml
stages:
  - extract

extract_reports:
  stage: extract
  script:
    - apt-get update && apt-get install -y jq
    - chmod +x bin.sh code_dump.py
    - ./bin.sh
  artifacts:
    paths:
      - code_report_*.txt
      - backup/*.txt
    expire_in: 30 days
  only:
    - schedules
```

### **Pre-commit Hook**

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Generating code report before commit..."
./bin.sh

if [ $? -ne 0 ]; then
    echo "Failed to generate code report"
    exit 1
fi

git add code_report_*.txt backup/
```

## 🔧 **Advanced Patterns**

### **Batch Processing Multiple Projects**

```bash
#!/bin/bash

# List of projects
PROJECTS=(
    "/path/to/project1"
    "/path/to/project2"
    "/path/to/project3"
)

for project in "${PROJECTS[@]}"; do
    echo "Processing: $project"
    python3 code_dump.py "$project" --output "report_$(basename $project).txt"
done
```

### **Conditional Processing**

```bash
#!/bin/bash

# Only process if project has changed
PROJECT="/path/to/project"
HASH_FILE="project.hash"

CURRENT_HASH=$(find "$PROJECT" -type f -exec md5sum {} \; | sort | md5sum)

if [ -f "$HASH_FILE" ] && [ "$(cat $HASH_FILE)" = "$CURRENT_HASH" ]; then
    echo "No changes detected, skipping..."
    exit 0
fi

echo "Changes detected, processing..."
python3 code_dump.py "$PROJECT"

echo "$CURRENT_HASH" > "$HASH_FILE"
```

### **Parallel Processing (Multiple Projects)**

```bash
#!/bin/bash

# Process projects in parallel (use with caution)
PROJECTS=(
    "/path/to/project1"
    "/path/to/project2"
)

for project in "${PROJECTS[@]}"; do
    python3 code_dump.py "$project" --output "report_$(basename $project).txt" &
done

wait
echo "All projects processed"
```

### **Error Handling with Retry**

```bash
#!/bin/bash

MAX_RETRIES=3
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    python3 code_dump.py /path/to/project

    if [ $? -eq 0 ]; then
        echo "Success!"
        exit 0
    fi

    RETRY_COUNT=$((RETRY_COUNT + 1))
    echo "Retry $RETRY_COUNT of $MAX_RETRIES..."
    sleep 5
done

echo "Failed after $MAX_RETRIES attempts"
exit 1
```

## 📊 **Performance Tuning**

### **Optimization Tips**

| Setting              | Recommendation                        | Impact                      |
| -------------------- | ------------------------------------- | --------------------------- |
| `max_file_size_mb`   | Set to 1-5 MB for text files          | Reduces memory usage        |
| `exclude_dirs`       | Exclude `node_modules`, `__pycache__` | Dramatically improves speed |
| `include_extensions` | Be specific, avoid `*.*`              | Reduces processing time     |

### **Large Codebase Optimization**

```json
{
  "global": {
    "exclude_dirs": ["node_modules", "dist", "build", ".git", "__pycache__"],
    "exclude_files": ["*.min.js", "*.bundle.js", "*.chunk.js"],
    "max_file_size_mb": 2,
    "include_extensions": [".js", ".ts", ".py", ".java", ".go"]
  }
}
```

## 🔌 **Extending the Tool**

### **Custom Post-Processing Script**

```bash
#!/bin/bash
# post_process.sh

REPORT_FILE="$1"
PROJECT_NAME="$2"

if [ -f "$REPORT_FILE" ]; then
    # Count lines
    LINES=$(wc -l < "$REPORT_FILE")
    echo "Report has $LINES lines"

    # Compress large reports
    if [ $(stat -f%z "$REPORT_FILE") -gt 10485760 ]; then
        gzip "$REPORT_FILE"
        echo "Compressed large report"
    fi

    # Send notification
    curl -X POST https://hooks.slack.com/services/YOUR/WEBHOOK \
        -H 'Content-type: application/json' \
        --data "{\"text\":\"Report generated for $PROJECT_NAME\"}"
fi
```

### **Custom Hook Integration**

```bash
# Add to bin.sh after report generation
if [ -f "$SCRIPT_DIR/post_process.sh" ]; then
    source "$SCRIPT_DIR/post_process.sh"
    post_process "$REPORT_FILE" "$PROJECT_NAME"
fi
```

## 📈 **Monitoring & Logging**

### **Logging Setup**

```bash
#!/bin/bash
LOG_DIR="/var/log/text-extractor"
mkdir -p "$LOG_DIR"

LOG_FILE="$LOG_DIR/extractor-$(date +%Y%m%d).log"

./bin.sh 2>&1 | tee -a "$LOG_FILE"

# Rotate logs older than 30 days
find "$LOG_DIR" -name "*.log" -mtime +30 -delete
```

### **Metrics Collection**

```bash
#!/bin/bash

# Collect metrics
START_TIME=$(date +%s)

./bin.sh
EXIT_CODE=$?

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Log metrics
echo "{\"timestamp\":\"$(date -Iseconds)\",\"duration\":$DURATION,\"exit_code\":$EXIT_CODE}" >> metrics.jsonl
```

[⬆️ Back to Top](#-api-reference) | [📖 Main README](./README.md) | [🔧 Installation](./INSTALLATION.md)
