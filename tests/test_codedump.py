#!/usr/bin/env python3
import os
import sys
import json
import subprocess
import tempfile
import shutil
import unittest
from pathlib import Path

class TestCodeDump(unittest.TestCase):
    
    def setUp(self):
        """Create temporary test environment"""
        self.test_dir = tempfile.mkdtemp()
        self.original_dir = os.getcwd()
        os.chdir(self.test_dir)
        
        # Copy scripts
        shutil.copy("../code_dump.py", self.test_dir)
        shutil.copy("../bin.sh", self.test_dir)
        
        # Make executable
        os.chmod("bin.sh", 0o755)
        os.chmod("code_dump.py", 0o755)
        
        # Create test files
        os.makedirs("code/subdir", exist_ok=True)
        with open("code/main.py", "w") as f:
            f.write("print('hello world')\n")
        with open("code/subdir/test.txt", "w") as f:
            f.write("test content")
        with open("code/ignore.log", "w") as f:
            f.write("should be ignored")
    
    def tearDown(self):
        """Clean up"""
        os.chdir(self.original_dir)
        shutil.rmtree(self.test_dir)
    
    # =========================================================
    # TEST CASE 1: Mode 1 - Simple code folder
    # =========================================================
    def test_mode1_simple_folder(self):
        """Test Mode 1: Process ./code folder"""
        result = subprocess.run(
            ['bash', '-c', 'echo "1" | ./bin.sh'],
            capture_output=True,
            text=True,
            cwd=self.test_dir
        )
        
        # Check output file exists
        self.assertTrue(os.path.exists("code_report.txt"))
        
        # Check content
        with open("code_report.txt", "r") as f:
            content = f.read()
            self.assertIn("main.py", content)
            self.assertIn("test.txt", content)
            self.assertNotIn("ignore.log", content)  # Should be ignored
            self.assertIn("GitHub", content)  # Promo line
        
        print("✓ Mode 1 passed")
    
    # =========================================================
    # TEST CASE 2: Mode 2 - With settings.json
    # =========================================================
    def test_mode2_with_config(self):
        """Test Mode 2: Process projects from settings.json"""
        
        # Create settings.json
        config = {
            "enabled": True,
            "global": {
                "include_extensions": [".py", ".txt"],
                "exclude_dirs": ["ignore_me"]
            },
            "projects": [
                {
                    "name": "TestProject",
                    "path": "./code",
                    "enabled": True
                }
            ]
        }
        
        with open("settings.json", "w") as f:
            json.dump(config, f, indent=2)
        
        # Create ignored folder
        os.makedirs("code/ignore_me", exist_ok=True)
        with open("code/ignore_me/ignored.py", "w") as f:
            f.write("ignored")
        
        # Run Mode 2
        result = subprocess.run(
            ['bash', '-c', 'echo "2" | ./bin.sh'],
            capture_output=True,
            text=True,
            cwd=self.test_dir
        )
        
        # Check output
        self.assertTrue(os.path.exists("code_report_TestProject.txt"))
        
        with open("code_report_TestProject.txt", "r") as f:
            content = f.read()
            self.assertIn("main.py", content)
            self.assertIn("test.txt", content)
            self.assertNotIn("ignored.py", content)  # In excluded dir
        
        print("✓ Mode 2 passed")
    
    # =========================================================
    # TEST CASE 3: JSON validation
    # =========================================================
    def test_json_validation(self):
        """Test JSON validation catches errors"""
        
        # Invalid JSON
        with open("settings.json", "w") as f:
            f.write("{ invalid json }")
        
        result = subprocess.run(
            ['bash', '-c', 'echo "2" | ./bin.sh'],
            capture_output=True,
            text=True,
            cwd=self.test_dir
        )
        
        # Should show error about invalid JSON
        self.assertIn("Invalid JSON", result.stdout)
        self.assertFalse(os.path.exists("code_report_*.txt"))
        
        # Missing 'projects' field
        with open("settings.json", "w") as f:
            json.dump({"something": "else"}, f)
        
        result = subprocess.run(
            ['bash', '-c', 'echo "2" | ./bin.sh'],
            capture_output=True,
            text=True,
            cwd=self.test_dir
        )
        
        self.assertIn("Missing 'projects'", result.stdout)
        
        print("✓ JSON validation passed")
    
    # =========================================================
    # TEST CASE 4: No enabled projects
    # =========================================================
    def test_no_enabled_projects(self):
        """Test when all projects are disabled"""
        
        config = {
            "projects": [
                {"name": "Disabled", "path": "./code", "enabled": False}
            ]
        }
        
        with open("settings.json", "w") as f:
            json.dump(config, f, indent=2)
        
        result = subprocess.run(
            ['bash', '-c', 'echo "2" | ./bin.sh'],
            capture_output=True,
            text=True,
            cwd=self.test_dir
        )
        
        self.assertIn("No enabled projects", result.stdout)
        
        print("✓ No enabled projects test passed")
    
    # =========================================================
    # TEST CASE 5: Missing code folder (Mode 1)
    # =========================================================
    def test_missing_code_folder(self):
        """Test Mode 1 when code folder doesn't exist"""
        
        shutil.rmtree("code")
        
        result = subprocess.run(
            ['bash', '-c', 'echo "1" | ./bin.sh'],
            capture_output=True,
            text=True,
            cwd=self.test_dir
        )
        
        self.assertIn("code folder not found", result.stdout)
        
        print("✓ Missing folder test passed")
    
    # =========================================================
    # TEST CASE 6: Empty code folder
    # =========================================================
    def test_empty_code_folder(self):
        """Test Mode 1 with empty code folder"""
        
        # Remove all files
        for f in Path("code").glob("**/*"):
            if f.is_file():
                f.unlink()
        
        result = subprocess.run(
            ['bash', '-c', 'echo "1" | ./bin.sh'],
            capture_output=True,
            text=True,
            cwd=self.test_dir
        )
        
        self.assertIn("empty", result.stdout.lower())
        
        print("✓ Empty folder test passed")
    
    # =========================================================
    # TEST CASE 7: File extension filtering
    # =========================================================
    def test_extension_filtering(self):
        """Test include_extensions filtering"""
        
        # Create various file types
        with open("code/test.js", "w") as f:
            f.write("console.log()")
        with open("code/test.css", "w") as f:
            f.write("body {}")
        
        config = {
            "global": {
                "include_extensions": [".py", ".txt"]
            },
            "projects": [
                {"name": "FilterTest", "path": "./code", "enabled": True}
            ]
        }
        
        with open("settings.json", "w") as f:
            json.dump(config, f, indent=2)
        
        subprocess.run(
            ['bash', '-c', 'echo "2" | ./bin.sh'],
            capture_output=True,
            text=True,
            cwd=self.test_dir
        )
        
        with open("code_report_FilterTest.txt", "r") as f:
            content = f.read()
            self.assertIn("main.py", content)   # .py included
            self.assertIn("test.txt", content)  # .txt included
            self.assertNotIn("test.js", content)   # .js excluded
            self.assertNotIn("test.css", content)  # .css excluded
        
        print("✓ Extension filtering passed")
    
    # =========================================================
    # TEST CASE 8: Backup creation
    # =========================================================
    def test_backup_creation(self):
        """Test automatic backup in Mode 2"""
        
        config = {
            "global": {
                "backup": {"enabled": True}
            },
            "projects": [
                {"name": "BackupTest", "path": "./code", "enabled": True}
            ]
        }
        
        with open("settings.json", "w") as f:
            json.dump(config, f, indent=2)
        
        subprocess.run(
            ['bash', '-c', 'echo "2" | ./bin.sh'],
            capture_output=True,
            text=True,
            cwd=self.test_dir
        )
        
        # Check backup directory exists and has files
        self.assertTrue(os.path.exists("backup"))
        backup_files = list(Path("backup").glob("BackupTest_*.txt"))
        self.assertGreater(len(backup_files), 0)
        
        print("✓ Backup test passed")
    
    # =========================================================
    # TEST CASE 9: Python direct call
    # =========================================================
    def test_python_direct_call(self):
        """Test code_dump.py called directly"""
        
        result = subprocess.run(
            ['python3', 'code_dump.py', './code', '--single', '--output', 'direct_output.txt'],
            capture_output=True,
            text=True,
            cwd=self.test_dir
        )
        
        self.assertTrue(os.path.exists("direct_output.txt"))
        
        with open("direct_output.txt", "r") as f:
            content = f.read()
            self.assertIn("main.py", content)
        
        print("✓ Python direct call passed")
    
    # =========================================================
    # TEST CASE 10: Invalid choice input
    # =========================================================
    def test_invalid_choice(self):
        """Test invalid menu choice"""
        
        result = subprocess.run(
            ['bash', '-c', 'echo "99" | ./bin.sh'],
            capture_output=True,
            text=True,
            cwd=self.test_dir
        )
        
        self.assertIn("Invalid choice", result.stdout)
        
        print("✓ Invalid choice test passed")


# =========================================================
# Cross-Platform Test Runner
# =========================================================
def run_tests():
    """Run all tests with platform detection"""
    
    print("\n" + "=" * 60)
    print(f"🧪 RUNNING TESTS ON: {sys.platform}")
    print("=" * 60 + "\n")
    
    # Create test suite
    loader = unittest.TestLoader()
    suite = loader.loadTestsFromTestCase(TestCodeDump)
    runner = unittest.TextTestRunner(verbosity=2)
    result = runner.run(suite)
    
    print("\n" + "=" * 60)
    if result.wasSuccessful():
        print("✅ ALL TESTS PASSED")
    else:
        print(f"❌ {len(result.failures)} test(s) failed")
    print("=" * 60)
    
    return 0 if result.wasSuccessful() else 1


if __name__ == "__main__":
    sys.exit(run_tests())
