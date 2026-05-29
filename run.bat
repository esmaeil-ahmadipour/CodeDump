@echo off
chcp 65001 > nul
title CodeDump

echo ============================================
echo Select operation mode:
echo 1) Process ./code folder
echo 2) Process projects from settings.json
echo ============================================
set /p choice="Enter your choice (1 or 2): "

if "%choice%"=="1" (
    if exist "code\" (
        python code_dump.py code --single --output code_report.txt
    ) else if exist "CODE\" (
        python code_dump.py CODE --single --output code_report.txt
    ) else (
        echo ERROR: 'code' folder not found!
    )
) else if "%choice%"=="2" (
    if not exist "settings.json" (
        echo ERROR: settings.json not found!
        exit /b 1
    )
    python -c "import json; [print(f'Processing {p[\"name\"]}...') or __import__('subprocess').call(['python', 'code_dump.py', p['path'], '--single', '--output', f'code_report_{p[\"name\"]}.txt']) for p in json.load(open('settings.json'))['projects'] if p.get('enabled', True)]"
) else (
    echo Invalid choice!
)

pause
