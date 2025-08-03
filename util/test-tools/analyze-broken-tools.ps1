#Requires -Version 5.0
<#
.SYNOPSIS
    Advanced PORTX Tool Analysis - Identifies broken tools and suggests replacements
    
.DESCRIPTION
    Analyzes the tool test results and provides detailed breakdown of issues,
    categorizes problems, and suggests specific actions for broken tools.
    
.PARAMETER TestLogPath
    Path to the tool test log file
    
.EXAMPLE
    .\analyze-broken-tools.ps1 -TestLogPath "C:\App\PORTX\tool-test-report.txt"
#>

param(
    [string]$TestLogPath = "C:\App\PORTX\tool-test-report.txt"
)

Write-Host "🔍 PORTX Tool Analysis - Advanced Diagnostic" -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $TestLogPath)) {
    Write-Error "Test log file not found: $TestLogPath"
    Write-Host "Please run test-all-tools.bat first to generate the test report."
    exit 1
}

# Parse test results
$testResults = Get-Content $TestLogPath
$brokenTools = @()
$workingTools = @()
$missingTools = @()

foreach ($line in $testResults) {
    if ($line -match '^\[BROKEN\]\s+(.+?)/(.+?)\s+-\s+(.+)$') {
        $brokenTools += @{
            Category = $matches[1]
            Tool = $matches[2]
            Error = $matches[3]
            FullName = "$($matches[1])/$($matches[2])"
        }
    }
    elseif ($line -match '^\[WORKING\]\s+(.+?)/(.+)') {
        $workingTools += @{
            Category = $matches[1]
            Tool = $matches[2]
            FullName = "$($matches[1])/$($matches[2])"
        }
    }
    elseif ($line -match '^\[MISSING\]\s+(.+?)/(.+?)') {
        $missingTools += @{
            Category = $matches[1]
            Tool = $matches[2]
            FullName = "$($matches[1])/$($matches[2])"
        }
    }
}

# Statistics
$totalTools = $brokenTools.Count + $workingTools.Count + $missingTools.Count
$successRate = if ($totalTools -gt 0) { [math]::Round(($workingTools.Count / $totalTools) * 100, 1) } else { 0 }

Write-Host "📊 Overall Statistics:" -ForegroundColor Yellow
Write-Host "  Total Tools: $totalTools"
Write-Host "  Working: $($workingTools.Count) ($successRate%)" -ForegroundColor Green
Write-Host "  Broken: $($brokenTools.Count)" -ForegroundColor Red
Write-Host "  Missing: $($missingTools.Count)" -ForegroundColor Yellow
Write-Host ""

# Categorize broken tools by type
$categorizedBroken = @{}
foreach ($tool in $brokenTools) {
    if (-not $categorizedBroken.ContainsKey($tool.Category)) {
        $categorizedBroken[$tool.Category] = @()
    }
    $categorizedBroken[$tool.Category] += $tool
}

Write-Host "🔧 Broken Tools by Category:" -ForegroundColor Red
foreach ($category in $categorizedBroken.Keys | Sort-Object) {
    Write-Host "  $category ($($categorizedBroken[$category].Count) tools):" -ForegroundColor Yellow
    foreach ($tool in $categorizedBroken[$category] | Sort-Object Tool) {
        Write-Host "    ❌ $($tool.Tool) - $($tool.Error)" -ForegroundColor Red
    }
    Write-Host ""
}

# Common broken tools analysis
$commonBrokenTools = @{
    'python' = 'Install Python or use python.exe from bin-tools'
    'node' = 'Install Node.js or use node.exe from bin-tools'
    'java' = 'Install Java JDK or use java.exe from bin-tools'
    'make' = 'Use make.exe from bin-ext (enhanced version)'
    'gcc' = 'Use MinGW GCC from mingw64/bin'
    'git' = 'Use git.exe from mingw64/bin (Git for Windows)'
    'ssh' = 'Use ssh.exe from usr/bin or mingw64/bin'
    'curl' = 'Use curl.exe from mingw64/bin'
    'wget' = 'Install wget or use curl as alternative'
    'vim' = 'Use vim.exe from usr/bin or micro.exe as alternative'
    'nano' = 'Use nano.exe from usr/bin or micro.exe as alternative'
}

Write-Host "💡 Suggested Actions for Common Issues:" -ForegroundColor Cyan
$suggestions = @()
foreach ($tool in $brokenTools) {
    $toolName = $tool.Tool.ToLower()
    if ($commonBrokenTools.ContainsKey($toolName)) {
        $suggestions += "🔄 $($tool.Tool): $($commonBrokenTools[$toolName])"
    }
}

if ($suggestions.Count -gt 0) {
    $suggestions | Sort-Object | ForEach-Object { Write-Host "  $_" -ForegroundColor White }
} else {
    Write-Host "  No common tools detected in broken list" -ForegroundColor Green
}
Write-Host ""

# MSYS2 specific issues
$msys2Broken = $brokenTools | Where-Object { $_.Category -eq 'MSYS2' }
if ($msys2Broken.Count -gt 0) {
    Write-Host "🚨 MSYS2 Tools Issues:" -ForegroundColor Red
    Write-Host "  $($msys2Broken.Count) MSYS2 tools are broken"
    Write-Host "  Common causes:" -ForegroundColor Yellow
    Write-Host "    - Missing DLL dependencies (msys-*.dll files)" -ForegroundColor Yellow
    Write-Host "    - Path issues in portable environment" -ForegroundColor Yellow
    Write-Host "    - Tools expecting MSYS2 filesystem structure" -ForegroundColor Yellow
    Write-Host ""
    
    # Check for missing DLLs
    $dllPath = "C:\App\PORTX\usr\bin"
    $requiredDlls = @('msys-2.0.dll', 'msys-crypto-1.1.dll', 'msys-ssl-1.1.dll')
    $missingDlls = @()
    
    foreach ($dll in $requiredDlls) {
        if (-not (Test-Path "$dllPath\$dll")) {
            $missingDlls += $dll
        }
    }
    
    if ($missingDlls.Count -gt 0) {
        Write-Host "  ❌ Missing critical DLLs:" -ForegroundColor Red
        $missingDlls | ForEach-Object { Write-Host "    - $_" -ForegroundColor Red }
    } else {
        Write-Host "  ✅ Critical DLLs present" -ForegroundColor Green
    }
    Write-Host ""
}

# Professional tools analysis
$professionalBroken = $brokenTools | Where-Object { $_.Category -like 'Tools-*' }
if ($professionalBroken.Count -gt 0) {
    Write-Host "💼 Professional Tools Issues:" -ForegroundColor Red
    Write-Host "  $($professionalBroken.Count) professional tools are broken"
    
    # Group by package
    $packageIssues = @{}
    foreach ($tool in $professionalBroken) {
        $package = $tool.Category -replace '^Tools-', ''
        if (-not $packageIssues.ContainsKey($package)) {
            $packageIssues[$package] = @()
        }
        $packageIssues[$package] += $tool.Tool
    }
    
    Write-Host "  Issues by package:" -ForegroundColor Yellow
    foreach ($package in $packageIssues.Keys | Sort-Object) {
        Write-Host "    📦 $package - $($packageIssues[$package].Count) broken tools" -ForegroundColor Yellow
        $packageIssues[$package] | ForEach-Object { Write-Host "      - $_" -ForegroundColor Red }
    }
    Write-Host ""
}

# Priority recommendations
Write-Host "🎯 Priority Actions:" -ForegroundColor Green
$criticalTools = @('git', 'bash', 'sh', 'curl', 'ssh', 'make', 'gcc', 'grep', 'sed', 'awk')
$brokenCritical = $brokenTools | Where-Object { $criticalTools -contains $_.Tool.ToLower() }

if ($brokenCritical.Count -gt 0) {
    Write-Host "  🚨 CRITICAL: Fix these essential tools first:" -ForegroundColor Red
    $brokenCritical | ForEach-Object { Write-Host "    - $($_.Tool) ($($_.Category))" -ForegroundColor Red }
} else {
    Write-Host "  ✅ All critical development tools are working" -ForegroundColor Green
}

if ($successRate -lt 80) {
    Write-Host "  📈 Success rate is low ($successRate%) - consider:" -ForegroundColor Yellow
    Write-Host "    - Updating PORTX installation" -ForegroundColor Yellow
    Write-Host "    - Reinstalling problematic packages" -ForegroundColor Yellow
    Write-Host "    - Checking for Windows compatibility issues" -ForegroundColor Yellow
} elseif ($successRate -lt 95) {
    Write-Host "  📊 Success rate is good ($successRate%) - focus on specific issues" -ForegroundColor Green
} else {
    Write-Host "  🎉 Excellent success rate ($successRate%) - minor cleanup only" -ForegroundColor Green
}

Write-Host ""
Write-Host "📋 Next Steps:" -ForegroundColor Cyan
Write-Host "  1. Run detailed individual tool tests for broken items"
Write-Host "  2. Check package documentation in bin-tools/*/package-manual.md"
Write-Host "  3. Consider alternative tools from working categories"
Write-Host "  4. Update or reinstall specific problematic packages"
Write-Host ""

# Save detailed analysis
$analysisFile = "C:\App\PORTX\tool-analysis-detailed.txt"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

@"
PORTX Tool Analysis Report - $timestamp
================================================

STATISTICS:
- Total Tools: $totalTools  
- Working: $($workingTools.Count) ($successRate%)
- Broken: $($brokenTools.Count)
- Missing: $($missingTools.Count)

BROKEN TOOLS BY CATEGORY:
$(foreach ($category in $categorizedBroken.Keys | Sort-Object) {
    "$category ($($categorizedBroken[$category].Count) tools):"
    foreach ($tool in $categorizedBroken[$category] | Sort-Object Tool) {
        "  - $($tool.Tool): $($tool.Error)"
    }
    ""
})

CRITICAL BROKEN TOOLS:
$(if ($brokenCritical.Count -gt 0) {
    $brokenCritical | ForEach-Object { "- $($_.Tool) ($($_.Category)): $($_.Error)" }
} else {
    "None - all critical tools are working"
})

RECOMMENDATIONS:
$(if ($successRate -lt 80) {
    "- LOW SUCCESS RATE: Major issues detected, consider full reinstall"
} elseif ($successRate -lt 95) {
    "- MODERATE ISSUES: Focus on specific broken packages"  
} else {
    "- MINOR ISSUES: Cleanup and optimization only"
})

"@ | Out-File -FilePath $analysisFile -Encoding UTF8

Write-Host "📄 Detailed analysis saved to: $analysisFile" -ForegroundColor Green