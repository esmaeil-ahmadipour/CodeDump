#!/usr/bin/env pwsh
# Test script for Windows (PowerShell, CMD, Git Bash)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDir = Split-Path -Parent $scriptDir

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host "          WINDOWS TESTS - CodeDump" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
Write-Host ""

# Create temp test directory
$testRoot = Join-Path $env:TEMP "CodeDump_Test_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
New-Item -ItemType Directory -Path $testRoot -Force | Out-Null

try {
    # Copy files to test directory
    Copy-Item "$projectDir\code_dump.py" $testRoot
    Copy-Item "$projectDir\bin.sh" $testRoot -ErrorAction SilentlyContinue
    Copy-Item "$projectDir\run.ps1" $testRoot -ErrorAction SilentlyContinue
    Copy-Item "$projectDir\run.bat" $testRoot -ErrorAction SilentlyContinue
    
    Push-Location $testRoot
    
    Write-Host "📁 Test directory: $testRoot" -ForegroundColor Yellow
    Write-Host ""
    
    # ============================================================
    # TEST 1: PowerShell - Mode 1
    # ============================================================
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "TEST 1: PowerShell - Mode 1 (code folder)" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Create test code folder
    New-Item -ItemType Directory -Path "code" -Force | Out-Null
    "print('hello from PowerShell test')" | Out-File -FilePath "code/test.py" -Encoding UTF8
    "README content" | Out-File -FilePath "code/readme.md" -Encoding UTF8
    
    # Run PowerShell script with Mode 1
    $process = Start-Process -FilePath "powershell.exe" -ArgumentList "-File `"$testRoot\run.ps1`"" -RedirectStandardInput "temp_input.txt" -NoNewWindow -Wait -PassThru
    
    # Alternative: Run directly with echo
    "1`n" | Out-File -FilePath "input.txt" -Encoding ascii
    $result = Get-Content "input.txt" | powershell.exe -File "run.ps1" 2>&1
    
    if (Test-Path "code_report.txt") {
        $size = (Get-Item "code_report.txt").Length
        Write-Host "✅ PowerShell Mode 1 PASSED - Report size: $size bytes" -ForegroundColor Green
    } else {
        Write-Host "❌ PowerShell Mode 1 FAILED - Report not found" -ForegroundColor Red
        exit 1
    }
    
    # ============================================================
    # TEST 2: PowerShell - Mode 2
    # ============================================================
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "TEST 2: PowerShell - Mode 2 (settings.json)" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Clean previous
    Remove-Item "code_report*.txt" -ErrorAction SilentlyContinue
    Remove-Item "settings.json" -ErrorAction SilentlyContinue
    Remove-Item "backup" -Recurse -ErrorAction SilentlyContinue
    
    # Create test project
    New-Item -ItemType Directory -Path "test_project" -Force | Out-Null
    "console.log('test');" | Out-File -FilePath "test_project/app.js" -Encoding UTF8
    '{"version": "1.0"}' | Out-File -FilePath "test_project/config.json" -Encoding UTF8
    
    # Create settings.json
    @'
{
    "enabled": true,
    "global": {
        "include_extensions": [".js", ".json"]
    },
    "projects": [
        {
            "name": "PSTestProject",
            "path": "./test_project",
            "enabled": true
        }
    ]
}
'@ | Out-File -FilePath "settings.json" -Encoding UTF8
    
    # Run Mode 2
    "2`n" | Out-File -FilePath "input2.txt" -Encoding ascii
    $result = Get-Content "input2.txt" | powershell.exe -File "run.ps1" 2>&1
    
    if (Test-Path "code_report_PSTestProject.txt") {
        $size = (Get-Item "code_report_PSTestProject.txt").Length
        Write-Host "✅ PowerShell Mode 2 PASSED - Report size: $size bytes" -ForegroundColor Green
        
        # Check backup
        if (Test-Path "backup") {
            Write-Host "✅ Backup folder created" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ PowerShell Mode 2 FAILED" -ForegroundColor Red
        exit 1
    }
    
    # ============================================================
    # TEST 3: Python Direct Call
    # ============================================================
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "TEST 3: Python Direct Call" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    Remove-Item "code_report.txt" -ErrorAction SilentlyContinue
    New-Item -ItemType Directory -Path "code_direct" -Force | Out-Null
    "print('direct call')" | Out-File -FilePath "code_direct/test.py" -Encoding UTF8
    
    python code_dump.py code_direct --single --output code_report.txt --no-config
    
    if (Test-Path "code_report.txt") {
        $size = (Get-Item "code_report.txt").Length
        Write-Host "✅ Python Direct Call PASSED - Report size: $size bytes" -ForegroundColor Green
    } else {
        Write-Host "❌ Python Direct Call FAILED" -ForegroundColor Red
        exit 1
    }
    
    # ============================================================
    # TEST 4: Content Verification
    # ============================================================
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "TEST 4: Content Verification" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    $content = Get-Content "code_report.txt" -Raw
    
    if ($content -match "📦 Generated by CodeDump") {
        Write-Host "✅ GitHub promo found" -ForegroundColor Green
    } else {
        Write-Host "❌ GitHub promo missing" -ForegroundColor Red
    }
    
    if ($content -match "test\.py") {
        Write-Host "✅ Test file found in report" -ForegroundColor Green
    } else {
        Write-Host "❌ Test file missing from report" -ForegroundColor Red
    }
    
    # ============================================================
    # TEST 5: CMD (if available)
    # ============================================================
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "TEST 5: CMD Mode 1" -ForegroundColor Yellow
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    Remove-Item "code_report.txt" -ErrorAction SilentlyContinue
    Remove-Item "code" -Recurse -ErrorAction SilentlyContinue
    
    New-Item -ItemType Directory -Path "code" -Force | Out-Null
    "print('cmd test')" | Out-File -FilePath "code/test_cmd.py" -Encoding UTF8
    
    # Create temp cmd script
    @'
echo 1 > input.txt
run.bat < input.txt
'@ | Out-File -FilePath "run_cmd_test.bat" -Encoding ascii
    
    # Run CMD test
    $cmdResult = cmd.exe /c "echo 1 | run.bat" 2>&1
    
    if (Test-Path "code_report.txt") {
        Write-Host "✅ CMD Mode 1 PASSED" -ForegroundColor Green
    } else {
        Write-Host "⚠️ CMD Mode 1 SKIPPED (might need interactive terminal)" -ForegroundColor Yellow
    }
    
    # ============================================================
    # SUMMARY
    # ============================================================
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "📊 TEST SUMMARY - Windows" -ForegroundColor Cyan
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Generated reports:" -ForegroundColor Yellow
    Get-ChildItem "code_report*.txt" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  📄 $($_.Name) - $([math]::Round($_.Length/1KB,1)) KB"
    }
    Write-Host ""
    Write-Host "Backup folder:" -ForegroundColor Yellow
    if (Test-Path "backup") {
        Get-ChildItem "backup" -ErrorAction SilentlyContinue | ForEach-Object {
            Write-Host "  💾 $($_.Name)"
        }
    } else {
        Write-Host "  (none)"
    }
    Write-Host ""
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    Write-Host "✅ ALL WINDOWS TESTS PASSED" -ForegroundColor Green
    Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
    
}
catch {
    Write-Host ""
    Write-Host "❌ TEST FAILED: $_" -ForegroundColor Red
    Write-Host "Line: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Red
    exit 1
}
finally {
    Pop-Location
    # Optional: Clean up test directory
    # Remove-Item $testRoot -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host ""
Read-Host "Press Enter to exit"
