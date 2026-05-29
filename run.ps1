#!/usr/bin/env pwsh
# CodeDump - Windows PowerShell Runner

# Set console to UTF-8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$PSDefaultParameterValues['*:Encoding'] = 'utf8'

Write-Host "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓" -ForegroundColor Cyan
Write-Host "┃          CODE DUMP - DUAL MODE (PowerShell)     ┃" -ForegroundColor Cyan
Write-Host "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛" -ForegroundColor Cyan
Write-Host ""

Write-Host "Select operation mode:" -ForegroundColor Yellow
Write-Host "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
Write-Host "┃ 1) Process ./code folder (also accepts ./CODE)    ┃"
Write-Host "┃ 2) Process projects from settings.json           ┃"
Write-Host "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
Write-Host ""

$choice = Read-Host "Enter your choice (1 or 2)"

switch ($choice) {
    "1" {
        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host "📁 Processing code folder..." -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        
        # Find code folder (case insensitive)
        $codeFolder = $null
        if (Test-Path "CODE") { $codeFolder = "CODE" }
        elseif (Test-Path "code") { $codeFolder = "code" }
        elseif (Test-Path "Code") { $codeFolder = "Code" }
        
        if (-not $codeFolder) {
            Write-Host "✗ ERROR: 'code' folder not found!" -ForegroundColor Red
            Write-Host "  Please create a folder named 'code' or 'CODE'"
        }
        else {
            $fileCount = (Get-ChildItem -Path $codeFolder -File -Recurse -ErrorAction SilentlyContinue).Count
            if ($fileCount -eq 0) {
                Write-Host "⚠ Warning: code folder is empty!" -ForegroundColor Yellow
            }
            else {
                Write-Host "📂 Input folder: $codeFolder"
                Write-Host "📄 Output file: $PSScriptRoot\code_report.txt"
                Write-Host "📊 Found $fileCount file(s) to process"
                Write-Host ""
                
                python code_dump.py $codeFolder --single --output code_report.txt --no-config
                
                if ($LASTEXITCODE -eq 0 -and (Test-Path "code_report.txt")) {
                    $size = Get-Item "code_report.txt" | Select-Object -ExpandProperty Length
                    $sizeKB = [math]::Round($size / 1KB, 1)
                    Write-Host ""
                    Write-Host "✓ Extraction completed successfully!" -ForegroundColor Green
                    Write-Host "📄 Report saved to: $PSScriptRoot\code_report.txt"
                    Write-Host "📏 File size: $sizeKB KB"
                }
                else {
                    Write-Host "✗ Extraction failed!" -ForegroundColor Red
                }
            }
        }
    }
    
    "2" {
        Write-Host ""
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        Write-Host "📦 Processing projects from settings.json..." -ForegroundColor Cyan
        Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        
        if (-not (Test-Path "settings.json")) {
            Write-Host "✗ ERROR: settings.json not found!" -ForegroundColor Red
            break
        }
        
        try {
            $config = Get-Content "settings.json" -Raw -Encoding UTF8 | ConvertFrom-Json
            
            if (-not $config.projects) {
                Write-Host "✗ Missing 'projects' field in configuration" -ForegroundColor Red
                break
            }
            
            $enabledProjects = $config.projects | Where-Object { $_.enabled -ne $false }
            
            if ($enabledProjects.Count -eq 0) {
                Write-Host "⚠ No enabled projects found in settings.json" -ForegroundColor Yellow
                break
            }
            
            Write-Host "✓ Found $($enabledProjects.Count) enabled project(s)" -ForegroundColor Green
            
            $successCount = 0
            $failCount = 0
            
            foreach ($proj in $enabledProjects) {
                $projectName = $proj.name
                if (-not $projectName) { $projectName = "project_$i" }
                
                $projectPath = $proj.path
                
                Write-Host ""
                Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Magenta
                Write-Host "📦 Project: $projectName" -ForegroundColor Yellow
                Write-Host "📂 Path: $projectPath"
                
                if (-not (Test-Path $projectPath)) {
                    Write-Host "✗ SKIPPED: Path does not exist" -ForegroundColor Red
                    $failCount++
                    continue
                }
                
                $outputFile = "code_report_$projectName.txt"
                Write-Host "▶️ Running code_dump.py..."
                
                python code_dump.py $projectPath --single --output $outputFile
                
                if ($LASTEXITCODE -eq 0 -and (Test-Path $outputFile)) {
                    $size = Get-Item $outputFile | Select-Object -ExpandProperty Length
                    $sizeKB = [math]::Round($size / 1KB, 1)
                    Write-Host "✓ Success! Report size: $sizeKB KB" -ForegroundColor Green
                    $successCount++
                    
                    # Create backup
                    $backupDir = "backup"
                    if (-not (Test-Path $backupDir)) {
                        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
                    }
                    $timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
                    Copy-Item $outputFile "$backupDir/${projectName}_${timestamp}.txt"
                    Write-Host "💾 Backup saved to: $backupDir/${projectName}_${timestamp}.txt"
                }
                else {
                    Write-Host "✗ Failed! Exit code: $LASTEXITCODE" -ForegroundColor Red
                    $failCount++
                }
            }
            
            Write-Host ""
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
            Write-Host "✓ Extraction complete!" -ForegroundColor Green
            Write-Host "📊 Summary: $successCount successful, $failCount failed"
            Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Cyan
        }
        catch {
            Write-Host "✗ Error parsing settings.json: $_" -ForegroundColor Red
        }
    }
    
    default {
        Write-Host "✗ Invalid choice! Please enter 1 or 2" -ForegroundColor Red
    }
}

Write-Host ""
Read-Host "Press Enter to close"
