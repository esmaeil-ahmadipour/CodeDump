#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import json
import argparse
from pathlib import Path
from datetime import datetime

# ======================== DEFAULT CONSTANTS ========================
DEFAULT_EXCLUDED_DIRS = [
    "build", ".dart_tool", ".idea", "node_modules",
    "__pycache__", "venv", ".venv", "dist", "out"
]

DEFAULT_ALLOWED_EXTENSIONS = [
    ".dart", ".yaml", ".md", ".txt", ".json", ".arb",
    ".html", ".css", ".js", ".sh", ".py", ".bat", ".ps1"
]

DEFAULT_IGNORED_PATTERNS = [
    ".freezed.dart", ".g.dart", ".gr.dart", ".config.dart",
    "generated", ".mocks.dart",
]

DEFAULT_MAX_FILE_SIZE_MB = 10
DEFAULT_OUTPUT_FORMAT = "single"


# ======================== CONFIGURATION LOADER ========================
def normalize_path(path):
    """Normalize path for comparison (remove trailing slashes, resolve, etc.)"""
    if not path:
        return path
    return str(Path(path).resolve())

def load_config(config_path=None):
    """Load configuration from JSON file"""
    config = {
        "enabled": True,
        "global": {
            "exclude_dirs": DEFAULT_EXCLUDED_DIRS.copy(),
            "exclude_files": [],
            "include_extensions": DEFAULT_ALLOWED_EXTENSIONS.copy(),
            "exclude_patterns": DEFAULT_IGNORED_PATTERNS.copy(),
            "max_file_size_mb": DEFAULT_MAX_FILE_SIZE_MB,
            "output_format": DEFAULT_OUTPUT_FORMAT,
            "backup": {
                "enabled": True,
                "compress": False,
                "retention_days": 30
            }
        },
        "projects": []
    }
    
    if config_path is None:
        possible_paths = [
            "settings.json",
            os.path.join(os.path.dirname(__file__), "settings.json"),
            os.path.join(os.getcwd(), "settings.json")
        ]
        for path in possible_paths:
            if os.path.exists(path):
                config_path = path
                break
    
    if config_path and os.path.exists(config_path):
        try:
            with open(config_path, "r", encoding="utf-8") as f:
                user_config = json.load(f)
            
            if "enabled" in user_config:
                config["enabled"] = user_config["enabled"]
            
            if "global" in user_config:
                global_config = user_config["global"]
                
                if "exclude_dirs" in global_config and global_config["exclude_dirs"] is not None:
                    config["global"]["exclude_dirs"] = global_config["exclude_dirs"]
                
                if "exclude_files" in global_config and global_config["exclude_files"] is not None:
                    config["global"]["exclude_files"] = global_config["exclude_files"]
                
                if "include_extensions" in global_config and global_config["include_extensions"] is not None:
                    exts = []
                    for ext in global_config["include_extensions"]:
                        if not ext.startswith("."):
                            ext = "." + ext
                        exts.append(ext.lower())
                    config["global"]["include_extensions"] = exts
                
                if "exclude_patterns" in global_config and global_config["exclude_patterns"] is not None:
                    config["global"]["exclude_patterns"] = global_config["exclude_patterns"]
                
                if "max_file_size_mb" in global_config and global_config["max_file_size_mb"] is not None:
                    config["global"]["max_file_size_mb"] = global_config["max_file_size_mb"]
                
                if "output_format" in global_config and global_config["output_format"] is not None:
                    config["global"]["output_format"] = global_config["output_format"]
                
                if "backup" in global_config and global_config["backup"] is not None:
                    backup = global_config["backup"]
                    if "enabled" in backup and backup["enabled"] is not None:
                        config["global"]["backup"]["enabled"] = backup["enabled"]
                    if "compress" in backup and backup["compress"] is not None:
                        config["global"]["backup"]["compress"] = backup["compress"]
                    if "retention_days" in backup and backup["retention_days"] is not None:
                        config["global"]["backup"]["retention_days"] = backup["retention_days"]
            
            if "projects" in user_config and user_config["projects"] is not None:
                config["projects"] = user_config["projects"]
                
        except json.JSONDecodeError as e:
            print(f"⚠️ Error parsing settings.json: {e}")
        except Exception as e:
            print(f"⚠️ Error loading settings.json: {e}")
    
    return config

def get_project_config(config, project_path):
    """Get merged configuration for a specific project"""
    project_config = {
        "exclude_dirs": config["global"]["exclude_dirs"].copy(),
        "exclude_files": config["global"]["exclude_files"].copy(),
        "include_extensions": config["global"]["include_extensions"].copy(),
        "exclude_patterns": config["global"]["exclude_patterns"].copy(),
        "max_file_size_mb": config["global"]["max_file_size_mb"],
        "output_format": config["global"]["output_format"]
    }
    
    normalized_project_path = normalize_path(project_path)
    
    for proj in config.get("projects", []):
        if not proj.get("enabled", True):
            continue
        
        proj_path = proj.get("path")
        if not proj_path:
            continue
        
        normalized_proj_path = normalize_path(proj_path)
        
        if normalized_proj_path == normalized_project_path:
            if "options" in proj and proj["options"] is not None:
                opts = proj["options"]
                
                if "exclude_dirs" in opts and opts["exclude_dirs"] is not None:
                    project_config["exclude_dirs"] = opts["exclude_dirs"]
                
                if "exclude_files" in opts and opts["exclude_files"] is not None:
                    project_config["exclude_files"] = opts["exclude_files"]
                
                if "include_extensions" in opts and opts["include_extensions"] is not None:
                    exts = []
                    for ext in opts["include_extensions"]:
                        if not ext.startswith("."):
                            ext = "." + ext
                        exts.append(ext.lower())
                    project_config["include_extensions"] = exts
                
                if "exclude_patterns" in opts and opts["exclude_patterns"] is not None:
                    project_config["exclude_patterns"] = opts["exclude_patterns"]
                
                if "max_file_size_mb" in opts and opts["max_file_size_mb"] is not None:
                    project_config["max_file_size_mb"] = opts["max_file_size_mb"]
            
            if "include_extensions" in proj and proj["include_extensions"] is not None:
                exts = []
                for ext in proj["include_extensions"]:
                    if not ext.startswith("."):
                        ext = "." + ext
                    exts.append(ext.lower())
                project_config["include_extensions"] = exts
            
            if "exclude_dirs" in proj and proj["exclude_dirs"] is not None:
                project_config["exclude_dirs"] = proj["exclude_dirs"]
            
            break
    
    return project_config

def get_project_name_from_config(config, project_path):
    """Get project name from config for a given path"""
    normalized_project_path = normalize_path(project_path)
    
    for proj in config.get("projects", []):
        if not proj.get("enabled", True):
            continue
        
        proj_path = proj.get("path")
        if not proj_path:
            continue
        
        normalized_proj_path = normalize_path(proj_path)
        
        if normalized_proj_path == normalized_project_path:
            name = proj.get("name")
            if name:
                return name
    
    return None


# ======================== UTILITY FUNCTIONS ========================
def setup_console_encoding():
    """Setup console encoding"""
    if sys.platform == "win32":
        import io
        sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="ignore")
        sys.stderr = io.TextIOWrapper(sys.stderr.buffer, encoding="utf-8", errors="ignore")
    else:
        if sys.stdout.encoding != 'utf-8':
            import codecs
            sys.stdout = codecs.getwriter('utf-8')(sys.stdout.buffer)
            sys.stderr = codecs.getwriter('utf-8')(sys.stderr.buffer)

def get_size_str(size_bytes):
    """Format file size"""
    if size_bytes < 1024:
        return f"{size_bytes} b"
    elif size_bytes < 1024 * 1024:
        return f"{size_bytes / 1024:.1f} KB"
    else:
        return f"{size_bytes / (1024 * 1024):.1f} MB"

def is_text_file(filepath, config):
    """Check if file should be processed based on config"""
    try:
        ext = os.path.splitext(filepath)[1].lower()
        
        if config["include_extensions"]:
            if ext not in config["include_extensions"]:
                return False
        
        name = os.path.basename(filepath)
        for pattern in config.get("exclude_files", []):
            import fnmatch
            if fnmatch.fnmatch(name, pattern):
                return False
        
        if config.get("max_file_size_mb"):
            size_mb = os.path.getsize(filepath) / (1024 * 1024)
            if size_mb > config["max_file_size_mb"]:
                return False
        
        with open(filepath, "r", encoding="utf-8") as f:
            f.read(1024)
        return True
    except (UnicodeDecodeError, IOError):
        return False

def should_ignore(filepath, config):
    """Check if file/dir should be ignored"""
    name = os.path.basename(filepath)
    path_parts = filepath.split(os.sep)
    
    for pattern in config.get("exclude_patterns", []):
        if pattern in filepath or name.endswith(pattern):
            return True
    
    for excluded_dir in config.get("exclude_dirs", []):
        if excluded_dir in path_parts:
            return True
    
    if name.startswith(".") and name not in [".gitignore", ".gitattributes", ".gitkeep"]:
        return True
    
    return False

def get_file_language(extension):
    """Get language identifier"""
    ext_map = {
        '.dart': 'dart', '.yaml': 'yaml', '.yml': 'yaml',
        '.json': 'json', '.html': 'html', '.css': 'css',
        '.js': 'javascript', '.jsx': 'jsx', '.ts': 'typescript',
        '.tsx': 'tsx', '.py': 'python', '.sh': 'bash',
        '.md': 'markdown', '.txt': 'text', '.arb': 'json',
        '.bat': 'batch', '.ps1': 'powershell'
    }
    return ext_map.get(extension.lower(), '')


def process_single_report(project_path, output_file, config, project_name=None):
    """Process a single project and create report"""
    total_files = 0
    total_size = 0
    
    # Use provided project name, otherwise use folder name
    if project_name:
        display_name = project_name
    else:
        display_name = os.path.basename(project_path)
    
    try:
        with open(output_file, "w", encoding="utf-8") as report:
            # ========== GITHUB PROMO AT VERY TOP ==========
            report.write("📦 Generated by CodeDump\n")
            report.write("🔗 GitHub: https://github.com/esmaeil-ahmadipour/CodeDump\n")
            report.write("⭐ Star this repo if it helped you!\n\n")
            # ========== END PROMO ==========
            
            report.write(f"# PROJECT: {display_name}\n")
            report.write(f"# PATH: {project_path}\n")
            report.write(f"# Generated: {datetime.now()}\n")
            report.write("#" + "-" * 70 + "\n\n")

            for root, dirs, files in os.walk(project_path):
                dirs[:] = [d for d in dirs 
                          if not should_ignore(os.path.join(root, d), config)]

                for file in sorted(files):
                    path = os.path.join(root, file)
                    
                    if should_ignore(path, config) or not is_text_file(path, config):
                        continue

                    try:
                        file_size = os.path.getsize(path)
                        total_size += file_size
                        
                        with open(path, "r", encoding="utf-8", errors="ignore") as f:
                            content = f.read()

                        try:
                            rel_path = os.path.relpath(path, project_path)
                        except ValueError:
                            rel_path = path

                        rel_path = rel_path.replace('\\', '/')

                        report.write("-" * 3 + "\n\n")
                        report.write("/*\n")
                        report.write(f"FILE:  {rel_path}\n")
                        report.write(f"SIZE:  {get_size_str(file_size)}\n")
                        report.write("*/\n")
                        
                        ext = os.path.splitext(file)[1]
                        lang = get_file_language(ext)
                        
                        if lang:
                            report.write(f"```{lang}\n")
                        else:
                            report.write("```\n")
                        
                        report.write(content.rstrip() + "\n")
                        report.write("```\n\n")

                        total_files += 1

                    except Exception as e:
                        print(f"  [err] {rel_path}: {e}")

    except IOError as e:
        print(f"  [err] Cannot write to {output_file}: {e}")
        return 0, 0

    return total_files, total_size

# ======================== MAIN ========================
def parse_arguments():
    parser = argparse.ArgumentParser(description='Extract text files from directories')
    parser.add_argument('target_dir', nargs='?', default=None, help='Target directory to process')
    parser.add_argument('--single', '-s', action='store_true', help='Create single combined report')
    parser.add_argument('--output', '-o', default='code_report.txt', help='Output filename')
    parser.add_argument('--config', '-c', default='settings.json', help='Path to settings.json')
    parser.add_argument('--no-config', action='store_true', help='Ignore settings.json file')
    return parser.parse_args()

def main():
    setup_console_encoding()
    args = parse_arguments()
    
    # Determine target directory FIRST
    if args.target_dir:
        target_dir = os.path.abspath(args.target_dir)
        if not os.path.isdir(target_dir):
            print(f"❌ Error: '{args.target_dir}' is not a valid directory")
            sys.exit(1)
    else:
        target_dir = os.getcwd()
    
    # Handle config based on --no-config flag
    if args.no_config:
        # Use default config without loading settings.json
        config = {
            "enabled": True,
            "global": {
                "exclude_dirs": DEFAULT_EXCLUDED_DIRS.copy(),
                "exclude_files": [],
                "include_extensions": DEFAULT_ALLOWED_EXTENSIONS.copy(),
                "exclude_patterns": DEFAULT_IGNORED_PATTERNS.copy(),
                "max_file_size_mb": DEFAULT_MAX_FILE_SIZE_MB,
                "output_format": DEFAULT_OUTPUT_FORMAT,
                "backup": {"enabled": False, "compress": False, "retention_days": 30}
            },
            "projects": []
        }
        project_config = config["global"].copy()
        project_name = None
    else:
        config = load_config(args.config)
        
        if not config.get("enabled", True):
            print("❌ Extraction is disabled")
            sys.exit(0)
        
        project_config = get_project_config(config, target_dir)
        project_name = get_project_name_from_config(config, target_dir)
    
    # Print status
    print("━" * 3)
    print("CODE DUMP")
    print("━" * 3)
    print(f"dir: {target_dir}")
    print(f"output: {args.output}")
    if project_name:
        print(f"project name: {project_name}")
    print("─" * 3)
    
    # Process with project name
    total_files, total_size = process_single_report(
        target_dir, 
        args.output, 
        project_config,
        project_name
    )
    
    print("─" * 3)
    if total_files > 0:
        print(f"📊 Processing complete")
        print(f"📄 Total files: {total_files:,d}")
        print(f"💾 Total size: {get_size_str(total_size)}")
        if os.path.exists(args.output):
            print(f"📁 Output: {args.output} ({get_size_str(os.path.getsize(args.output))})")
    else:
        print("📭 No files extracted")
    
    print("━" * 3)
    
    if total_files > 0:
        return 0
    return 1

if __name__ == "__main__":
    sys.exit(main())
