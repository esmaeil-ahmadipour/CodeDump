@echo off
chcp 65001 > nul
title CodeDump

echo ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
echo ┃          CODE DUMP - DUAL MODE (CMD)             ┃
echo ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
echo.

echo Select operation mode:
echo ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
echo ┃ 1) Process ./code folder (also accepts ./CODE)    ┃
echo ┃ 2) Process projects from settings.json           ┃
echo ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
echo.

set /p choice="Enter your choice (1 or 2): "

if "%choice%"=="1" (
    echo.
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo 📁 Processing code folder...
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    if exist "CODE\" (
        set CODE_DIR=CODE
    ) else if exist "code\" (
        set CODE_DIR=code
    ) else if exist "Code\" (
        set CODE_DIR=Code
    ) else (
        echo ✗ ERROR: 'code' folder not found!
        goto :end
    )
    
    echo 📂 Input folder: %CODE_DIR%
    echo 📄 Output file: code_report.txt
    echo.
    
    python code_dump.py %CODE_DIR% --single --output code_report.txt --no-config
    
    if exist "code_report.txt" (
        echo.
        echo ✓ Extraction completed successfully!
        echo 📄 Report saved to: code_report.txt
    ) else (
        echo ✗ Extraction failed!
    )
    
) else if "%choice%"=="2" (
    echo.
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    echo 📦 Processing projects from settings.json...
    echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    
    if not exist "settings.json" (
        echo ✗ ERROR: settings.json not found!
        goto :end
    )
    
    echo ✓ Configuration file found
    echo.
    
    python -c "import json; import subprocess; import os; config = json.load(open('settings.json')); projects = [p for p in config.get('projects', []) if p.get('enabled', True)]; print(f'Found {len(projects)} enabled project(s)'); [subprocess.run(['python', 'code_dump.py', p['path'], '--single', '--output', f'code_report_{p.get(\"name\", \"project\")}.txt']) for p in projects]"
    
) else (
    echo ✗ Invalid choice! Please enter 1 or 2
)

:end
echo.
pause
