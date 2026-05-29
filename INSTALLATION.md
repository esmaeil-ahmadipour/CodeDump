# 🔧 **Installation Guide**

Complete step-by-step installation instructions for all platforms.

## 📋 **Pre-Installation Checklist**

- [ ] Check Python version (3.8+ required)
- [ ] Check Bash version (4.0+ required)
- [ ] Ensure sufficient disk space (50 MB)
- [ ] Verify internet connection (for download)

## 🐧 **Linux Installation**

### **Ubuntu/Debian (20.04+)**

```bash
# 1. Update package list
sudo apt update

# 2. Install Python if not present
sudo apt install -y python3 python3-pip

# 3. Install jq (required for Mode 2 - projects from settings.json)
sudo apt install -y jq

# 4. Verify installations
python3 --version  # Should be >= 3.8
jq --version       # Should show version
bash --version     # Should be >= 4.0

# 5. Clone repository
git clone https://github.com/esmaeil-ahmadipour/text-extractor.git
cd text-extractor

# 6. Set permissions
chmod +x bin.sh code_dump.py

# 7. Test run
./bin.sh
```
After running `./bin.sh`, you will see:

Select operation mode:
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃ 1) Process ./code folder (also accepts ./CODE)    ┃
┃ 2) Process projects from settings.json            ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛


- **Mode 1**: Simple mode - place your code in `./code/` folder
- **Mode 2**: Advanced mode - configure projects in `settings.json`

---

### **Fedora/RHEL (35+)**

```bash
# 1. Update system
sudo dnf update

# 2. Install dependencies
sudo dnf install -y python3 python3-pip jq

# 3. Clone and setup
git clone https://github.com/esmaeil-ahmadipour/text-extractor.git
cd text-extractor
chmod +x bin.sh code_dump.py

# 4. Run
./bin.sh
```

### **Arch Linux**

```bash
# 1. Install dependencies
sudo pacman -S python python-pip jq

# 2. Clone repository
git clone https://github.com/esmaeil-ahmadipour/text-extractor.git
cd text-extractor

# 3. Make executable
chmod +x bin.sh code_dump.py

# 4. Execute
./bin.sh
```

## 🍎 **macOS Installation**

### **Using Homebrew (Recommended)**

```bash
# 1. Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install dependencies
brew install python3 jq

# 3. Verify installation
python3 --version
jq --version

# 4. Clone repository
git clone https://github.com/esmaeil-ahmadipour/text-extractor.git
cd text-extractor

# 5. Set permissions
chmod +x bin.sh code_dump.py

# 6. Run (allow permission if prompted)
./bin.sh
```

### **Manual Installation**

```bash
# 1. Download Python from python.org
# 2. Download jq from https://stedolan.github.io/jq/download/
# 3. Add to PATH
export PATH="$PATH:/usr/local/bin"

# 4. Clone and setup
git clone https://github.com/esmaeil-ahmadipour/text-extractor.git
cd text-extractor
chmod +x bin.sh code_dump.py

# 5. Run
./bin.sh
```

## 🪟 **Windows Installation**

### **Method 1: WSL2 (Recommended)**

```bash
# 1. Enable WSL2
# Open PowerShell as Administrator:
wsl --install

# 2. Restart computer

# 3. Launch Ubuntu from Start Menu

# 4. Inside WSL, follow Linux installation:
sudo apt update
sudo apt install -y python3 python3-pip jq

# 5. Clone repository
git clone https://github.com/esmaeil-ahmadipour/text-extractor.git
cd text-extractor

# 6. Run
./bin.sh
```

### **Method 2: Git Bash (Limited)**

```bash
# 1. Download Git for Windows
# https://git-scm.com/download/win

# 2. Install with default options

# 3. Download Python for Windows
# https://python.org/downloads/

# 4. Add Python to PATH during installation

# 5. Open Git Bash

# 6. Clone repository
git clone https://github.com/esmaeil-ahmadipour/text-extractor.git
cd text-extractor

# 7. Note: jq not available in Git Bash
# Use Mode 1 only (current directory)

# 8. Run (may need to use python instead of python3)
python code_dump.py
```

## 🐳 **Docker Installation**

**Dockerfile:**

```dockerfile
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    jq \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY . .

RUN chmod +x bin.sh code_dump.py

CMD ["./bin.sh"]
```

**Build and run:**

```bash
# Build image
docker build -t text-extractor .

# Run container
docker run -it --rm -v $(pwd):/app text-extractor
```

## 🔧 **Post-Installation Verification**

Run this test to verify everything works:

```bash
# Create test directory
mkdir -p test-project/src
echo "console.log('test');" > test-project/src/main.js

# Create minimal settings.json
cat > settings.json << 'EOF'
{
  "enabled": true,
  "skip_menu": true,
  "global": {
    "include_extensions": [".js"]
  },
  "projects": [
    {
      "name": "Test",
      "path": "./test-project",
      "enabled": true
    }
  ]
}
EOF

# Run extractor
./bin.sh

# Check output
ls -la code_report_Test.txt

# Cleanup
rm -rf test-project settings.json code_report_Test.txt backup/
```

**Expected output:**

```
✓ Configuration loaded: settings.json
🚀 Headless mode: skip_menu enabled
Processing projects from settings.json...
📦 Project: Test
📂 Path: ./test-project
✓ Backed up to: ./backup/Test_2026-05-20_22-06-17.txt
📄 Report size: 1.2K
✅ All projects processed
```

## ❌ **Troubleshooting**

<details>
<summary><b>Problem: "python3: command not found"</b></summary>

**Solution:**

```bash
# Ubuntu/Debian
sudo apt install python3

# macOS
brew install python3

# Windows (WSL)
sudo apt install python3
```

</details>

<details>
<summary><b>Problem: "jq: command not found"</b></summary>

**Solution:**

```bash
# Ubuntu/Debian
sudo apt install jq

# macOS
brew install jq

# Or continue without jq (Mode 2 disabled)
```

</details>

<details>
<summary><b>Problem: "Permission denied"</b></summary>

**Solution:**

```bash
chmod +x bin.sh code_dump.py
```

</details>

<details>
<summary><b>Problem: "bad interpreter: No such file"</b></summary>

**Solution:**

```bash
# Fix line endings (Windows issue)
sed -i 's/\r$//' bin.sh code_dump.py
```

</details>

## ✅ **Verification Checklist**

After installation, verify:

```bash
# 1. Python version
python3 --version
# ✅ Should show Python 3.8+

# 2. Bash version
bash --version
# ✅ Should show Bash 4.0+

# 3. jq version (optional)
jq --version
# ✅ Should show version or "command not found"

# 4. Script permissions
ls -la bin.sh code_dump.py
# ✅ Should show -rwxr-xr-x (executable)

# 5. Test run
./bin.sh
# ✅ Should show menu or headless output
```

## 🔄 **Updating**

```bash
# Navigate to installation directory
cd text-extractor

# Pull latest changes
git pull

# Re-set permissions
chmod +x bin.sh code_dump.py

# Done!
```

## 📤 **Uninstallation**

```bash
# Simply delete the directory
rm -rf text-extractor

# Remove backups (if desired)
rm -rf ~/text-extractor-backups
```

[⬆️ Back to Top](#-installation-guide) | [📖 Main README](./README.md) | [⚙️ Configuration](./CONFIGURATION.md)
