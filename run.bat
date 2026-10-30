@echo off
chcp 65001 > nul
cd /d "%~dp0"
python code_dump.py %*
pause
