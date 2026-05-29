param(
    [string]$OutputDir = "dist"
)

$BuildDir = "build/windows/CodeDump"
$DistDir = $OutputDir

New-Item -ItemType Directory -Path $BuildDir -Force | Out-Null
New-Item -ItemType Directory -Path $DistDir -Force | Out-Null

# Copy files
Copy-Item "bin.sh" -Destination $BuildDir
Copy-Item "code_dump.py" -Destination $BuildDir
Copy-Item "settings.json" -Destination $BuildDir

# PowerShell runner
@"
Write-Host "CodeDump for Windows" -ForegroundColor Cyan
`$choice = Read-Host "Select mode (1=code folder, 2=settings.json)"

if (`$choice -eq "1") {
    if (Test-Path "code") { python code_dump.py code --single --output code_report.txt }
    elseif (Test-Path "CODE") { python code_dump.py CODE --single --output code_report.txt }
    else { Write-Host "ERROR: code folder not found!" -ForegroundColor Red }
}
elseif (`$choice -eq "2") {
    if (Test-Path "settings.json") {
        `$config = Get-Content settings.json -Raw | ConvertFrom-Json
        foreach (`$proj in `$config.projects | Where-Object { `$_.enabled -ne `$false }) {
            Write-Host "Processing `$(`$proj.name)..."
            python code_dump.py `$proj.path --single --output "code_report_`$(`$proj.name).txt"
        }
    }
    else { Write-Host "ERROR: settings.json not found!" -ForegroundColor Red }
}
Read-Host "Press Enter to exit"
"@ | Out-File -FilePath "$BuildDir/run.ps1" -Encoding UTF8

# CMD runner
@"
@echo off
set /p choice="Select mode (1=code folder, 2=settings.json): "
if "%choice%"=="1" (
    if exist code\ (python code_dump.py code --single --output code_report.txt) else (echo code folder not found!)
) else if "%choice%"=="2" (
    if exist settings.json (python code_dump.py settings.json) else (echo settings.json not found!)
) else (echo Invalid choice!)
pause
"@ | Out-File -FilePath "$BuildDir/run.bat" -Encoding ascii

Compress-Archive -Path "$BuildDir/*" -DestinationPath "$DistDir/CodeDump-Windows.zip" -Force

Write-Host "✅ Windows build complete" -ForegroundColor Green
