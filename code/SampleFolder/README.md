# 📄 CodeDump - Code Documentation Tool

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)
[![Python 3.8+](https://img.shields.io/badge/Python-3.8+-green.svg)](https://python.org)
[![Bash](https://img.shields.io/badge/Bash-4.0+-green.svg)](https://gnu.org/software/bash)
[![Platform](https://img.shields.io/badge/Platform-Linux%20%7C%20macOS%20%7C%20WSL-blue.svg)](https://github.com)

A professional tool for automatically extracting all text files from your projects and converting them into a unified report. Perfect for sending code to ChatGPT, Claude, and other LLMs, documenting entire projects, and automatic code backups.

```
┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
┃          CODE DUMP - DUAL MODE               ┃
┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
```

## ✨ **Features**

| Feature                      | Description                               |
| ---------------------------- | ----------------------------------------- |
| ✅ **Multi-Project Support** | Process several projects simultaneously   |
| ✅ **JSON Configuration**    | Advanced settings with validation         |
| ✅ **Headless Mode**         | Automatic execution without user input    |
| ✅ **Auto Backup**           | Timestamped backups with retention policy |
| ✅ **20+ File Formats**      | Support for all major code file types     |
| ✅ **Filter System**         | Exclude directories, files, and patterns  |
| ✅ **Markdown Output**       | Standard format with syntax highlighting  |
| ✅ **Cross-Platform**        | Linux, macOS, and Windows (WSL)           |

## 🚀 **Quick Start**

### **Installation**

```bash
# Clone the repository
git clone https://github.com/esmaeil-ahmadipour/text-extractor.git
cd text-extractor

# Make scripts executable
chmod +x bin.sh code_dump.py

# Run the tool
./bin.sh
```

### **Basic Usage**

```bash
# Interactive mode (asks for input)
./bin.sh

# Headless mode (automatic)
# Set "skip_menu": true in settings.json
```

## 📊 **Supported File Extensions**

| Category    | Extensions                                    |
| ----------- | --------------------------------------------- |
| **Mobile**  | `.dart`, `.java`, `.kt`, `.swift`             |
| **Web**     | `.js`, `.ts`, `.jsx`, `.tsx`, `.html`, `.css` |
| **Backend** | `.py`, `.sh`, `.bat`, `.ps1`                  |
| **Data**    | `.json`, `.yaml`, `.yml`, `.xml`              |
| **Docs**    | `.md`, `.txt`, `.rst`                         |

## 🎯 **Use Cases**

### **1. LLM Code Analysis**

Send entire codebases to ChatGPT, Claude, or Gemini for:

- Code review and optimization
- Documentation generation
- Bug detection
- Architecture analysis

### **2. Project Documentation**

- Automatic codebase documentation
- Shareable code reports
- Knowledge transfer

### **3. Automated Backups**

- Scheduled code extraction
- Version tracking
- Offline code archives

### **4. Team Collaboration**

- Share project structure
- Code review without access
- Training material generation

## 📁 **Output Structure**

```
text-extractor/
├── bin.sh                              # Main script
├── code_dump.py                   # Python engine
├── settings.json                       # Configuration
├── code_report_Sample.txt              # Report for Sample project
├── code_report_Resume.txt              # Report for Resume project
└── backup/                            # Automatic backups
    ├── Sample_2026-05-20_22-06-17.txt
    └── Resume_2026-05-20_22-06-18.txt
```

## 🔧 **System Requirements**

| Requirement | Minimum         | Recommended   |
| ----------- | --------------- | ------------- |
| **OS**      | Linux/macOS/WSL | Ubuntu 20.04+ |
| **Python**  | 3.8+            | 3.10+         |
| **Bash**    | 4.0+            | 5.0+          |
| **jq**      | Optional        | 1.6+          |
| **RAM**     | 256 MB          | 512 MB        |
| **Disk**    | 50 MB           | 100 MB        |

## 💡 **Example Output**

```markdown
# PROJECT: Sample

# PATH: /home/user/projects/sample

# Generated: 2026-05-20 22:06:17.053321

#----------------------------------------------------------------------

---

/_
FILE: src/main.js
SIZE: 2.5 KB
_/

console.log("Hello World");
```

## 📈 Performance

Speed: ~1000 files/second (depends on file size)

Memory: ~50 MB for 10,000 files

Concurrency: Sequential processing (configurable)

## 🔒 Security

No external API calls

Local processing only

No data collection

Open source auditability

## 🤝 Contributing

Fork the repository

Create a feature branch

Commit your changes

Push to the branch

Open a Pull Request

## 📄 License

MIT License - Free for any use

## 👤 Author

Esmaeil Ahmadipour

Email: software686@gmail.com

GitHub: @esmaeil-ahmadipour

LinkedIn: esmaeil-ahmadipour

Portfolio: https://ea2.ir
Website: https://tarvix.org

## ⭐ Star on GitHub

If this tool helps you, please give it a star on GitHub!

## 📖 [Installation Guide](./INSTALLATION.md) | ⚙️ [Configuration](./CONFIGURATION.md) | 📚 [API Reference](./API.md)
