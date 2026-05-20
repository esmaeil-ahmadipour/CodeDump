# ⚙️ **Configuration Guide**

Complete reference for all configuration options in `settings.json`.

## 📋 **Configuration Structure**

```json
{
  "version": "1.0",
  "enabled": true,
  "skip_menu": false,
  "global": {
    "exclude_dirs": ["node_modules", "dist", "build", "__pycache__", ".git"],
    "exclude_files": ["*.log", "*.tmp", ".env*"],
    "include_extensions": [
      ".js",
      ".ts",
      ".json",
      ".md",
      ".txt",
      ".py",
      ".sh",
      ".yaml"
    ],
    "exclude_patterns": [".freezed.dart", ".g.dart", "generated"],
    "max_file_size_mb": 10,
    "output_format": "single",
    "backup": {
      "enabled": true,
      "compress": false,
      "retention_days": 30
    }
  },
  "projects": [
    {
      "name": "Sample",
      "path": "/absolute/path/to/project",
      "enabled": true,
      "include_extensions": [".txt", ".dart"]
    }
  ]
}
```

## 📊 **Field Reference**

### **Root Level Settings**

| Field       | Type    | Default | Description                           |
| ----------- | ------- | ------- | ------------------------------------- |
| `version`   | string  | "1.0"   | Configuration version                 |
| `enabled`   | boolean | true    | Master switch for extraction          |
| `skip_menu` | boolean | false   | Skip interactive menu (headless mode) |

### **Global Settings**

| Field                | Type   | Default             | Description                                    |
| -------------------- | ------ | ------------------- | ---------------------------------------------- |
| `exclude_dirs`       | array  | `[]`                | Directory names to exclude                     |
| `exclude_files`      | array  | `[]`                | File patterns to exclude (wildcards supported) |
| `include_extensions` | array  | All text extensions | File extensions to include                     |
| `exclude_patterns`   | array  | `[]`                | String patterns to exclude                     |
| `max_file_size_mb`   | number | 10                  | Maximum file size to process (MB)              |
| `output_format`      | string | "single"            | Output format ("single" only currently)        |

### **Backup Settings**

| Field                   | Type    | Default | Description                    |
| ----------------------- | ------- | ------- | ------------------------------ |
| `backup.enabled`        | boolean | true    | Enable automatic backups       |
| `backup.compress`       | boolean | false   | Compress backup files (future) |
| `backup.retention_days` | number  | 30      | Days to keep backups           |

### **Project Settings**

| Field                | Type    | Required | Description                        |
| -------------------- | ------- | -------- | ---------------------------------- |
| `name`               | string  | Yes      | Display name for the project       |
| `path`               | string  | Yes      | Absolute path to project directory |
| `enabled`            | boolean | No       | Enable/disable this project        |
| `include_extensions` | array   | No       | Override global extensions         |
| `exclude_dirs`       | array   | No       | Override global excluded dirs      |

## 🎯 **Filter Patterns**

### **Wildcard Patterns (exclude_files)**

| Pattern     | Matches                                 |
| ----------- | --------------------------------------- |
| `*.log`     | All `.log` files                        |
| `*.tmp`     | All `.tmp` files                        |
| `.env*`     | `.env`, `.env.local`, `.env.production` |
| `test_*.py` | `test_main.py`, `test_utils.py`         |

### **Directory Exclusions**

```json
"exclude_dirs": [
  "node_modules",    // NPM packages
  "dist",           // Build output
  "build",          // Build output
  "__pycache__",    // Python cache
  ".git",           // Git repository
  ".idea",          // IDE config
  "venv", ".venv"   // Virtual environments
]
```

### **Pattern Exclusions**

```json
"exclude_patterns": [
  ".freezed.dart",  // Generated code
  ".g.dart",        // Generated code
  "generated"       // Generated folders
]
```

## 📝 **Example Configurations**

### **Example 1: Web Development Project**

```json
{
  "version": "1.0",
  "enabled": true,
  "skip_menu": false,
  "global": {
    "exclude_dirs": ["node_modules", "dist", "build", ".next", "out"],
    "exclude_files": ["*.log", "*.map", ".env*"],
    "include_extensions": [
      ".js",
      ".ts",
      ".jsx",
      ".tsx",
      ".json",
      ".md",
      ".css",
      ".scss"
    ],
    "max_file_size_mb": 5
  },
  "projects": [
    {
      "name": "Frontend",
      "path": "/home/user/projects/frontend",
      "enabled": true
    }
  ]
}
```

### **Example 2: Python Backend Project**

```json
{
  "version": "1.0",
  "enabled": true,
  "skip_menu": true,
  "global": {
    "exclude_dirs": [
      "__pycache__",
      "venv",
      ".venv",
      "dist",
      "build",
      ".pytest_cache"
    ],
    "exclude_files": ["*.pyc", "*.log", ".env*", "pytest.ini"],
    "include_extensions": [
      ".py",
      ".yaml",
      ".yml",
      ".json",
      ".md",
      ".txt",
      ".sh"
    ],
    "max_file_size_mb": 10
  },
  "projects": [
    {
      "name": "API",
      "path": "/home/user/projects/api",
      "enabled": true
    },
    {
      "name": "Worker",
      "path": "/home/user/projects/worker",
      "enabled": true
    }
  ]
}
```

### **Example 3: Flutter Mobile Project**

```json
{
  "version": "1.0",
  "enabled": true,
  "skip_menu": false,
  "global": {
    "exclude_dirs": [
      "build",
      ".dart_tool",
      ".idea",
      "android",
      "ios",
      "node_modules"
    ],
    "exclude_files": ["*.lock", "*.g.dart", "*.freezed.dart", ".env*"],
    "include_extensions": [".dart", ".yaml", ".json", ".md", ".txt", ".arb"],
    "exclude_patterns": [".g.dart", ".freezed.dart", "generated"],
    "max_file_size_mb": 5
  },
  "projects": [
    {
      "name": "MobileApp",
      "path": "/home/user/projects/mobile_app",
      "enabled": true,
      "include_extensions": [".dart", ".yaml", ".json"]
    }
  ]
}
```

### **Example 4: Multiple Projects with Different Settings**

```json
{
  "version": "1.0",
  "enabled": true,
  "skip_menu": true,
  "global": {
    "exclude_dirs": ["node_modules", "dist", "__pycache__"],
    "include_extensions": [".js", ".py", ".json", ".md"]
  },
  "projects": [
    {
      "name": "Frontend",
      "path": "/projects/frontend",
      "enabled": true,
      "include_extensions": [".js", ".jsx", ".css"]
    },
    {
      "name": "Backend",
      "path": "/projects/backend",
      "enabled": true,
      "include_extensions": [".py", ".yaml"]
    },
    {
      "name": "Docs",
      "path": "/projects/docs",
      "enabled": false,
      "include_extensions": [".md"]
    }
  ]
}
```

## 💡 **Best Practices**

### **1. Path Handling**

✅ **DO: Use absolute paths**

```json
"path": "/home/user/projects/myapp"
```

❌ **DON'T: Use relative paths in production**

```json
"path": "./myapp"  // May break in automation
```

### **2. Extension Configuration**

✅ **DO: Be specific with extensions**

```json
"include_extensions": [".js", ".ts", ".jsx"]
```

❌ **DON'T: Include binary extensions**

```json
"include_extensions": [".exe", ".dll", ".so"]  // Won't work anyway
```

### **3. Exclusion Patterns**

✅ **DO: Use wildcards for log files**

```json
"exclude_files": ["*.log", "*.tmp"]
```

✅ **DO: Exclude large generated folders**

```json
"exclude_dirs": ["node_modules", "dist", "build"]
```

### **4. Backup Strategy**

✅ **DO: Enable backups for important projects**

```json
"backup": {
  "enabled": true,
  "retention_days": 90
}
```

### **5. Headless Mode for Automation**

✅ **DO: Use skip_menu for cron jobs**

```json
"skip_menu": true
```

## 🔄 **Configuration Precedence**

1. **Project-level settings** (highest priority)
2. **Global settings**
3. **Default constants** (lowest priority)

**Example:**

```json
{
  "global": {
    "include_extensions": [".js", ".json"] // Default
  },
  "projects": [
    {
      "name": "Special",
      "path": "/special",
      "include_extensions": [".ts"] // Overrides global
    }
  ]
}
```

## ⚠️ **Common Mistakes**

| Mistake                    | Consequence            | Solution                         |
| -------------------------- | ---------------------- | -------------------------------- |
| Missing dot in extensions  | Files not detected     | Use `.js` not `js`               |
| Trailing slash in path     | Path mismatch          | Use `/path` not `/path/`         |
| Empty `include_extensions` | No files processed     | Provide at least one extension   |
| Missing `enabled` field    | Project may be skipped | Explicitly set `"enabled": true` |

## 🧪 **Testing Configuration**

Test your configuration with:

```bash
# Validate JSON syntax
jq . settings.json

# Check specific value
jq '.projects[0].name' settings.json

# Count enabled projects
jq '[.projects[] | select(.enabled != false)] | length' settings.json
```

---

[⬆️ Back to Top](#-configuration-guide) | [📖 Main README](./README.md) | [🔧 Installation](./INSTALLATION.md)
