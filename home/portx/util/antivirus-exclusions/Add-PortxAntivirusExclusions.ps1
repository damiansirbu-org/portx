#Requires -RunAsAdministrator

param(
    [string]$PortxPath,
    [switch]$Force
)

# Auto-detect PORTX path if not provided
if (-not $PortxPath) {
    $possiblePaths = @(
        "C:\App\PORTX",
        "C:\Tools\PORTX", 
        "C:\PORTX",
        "$env:USERPROFILE\PORTX"
    )
    
    foreach ($path in $possiblePaths) {
        if (Test-Path "$path\portx.cmd") {
            $PortxPath = $path
            break
        }
    }
    
    if (-not $PortxPath) {
        Write-Error "PORTX installation not found. Please specify -PortxPath parameter."
        exit 1
    }
}

Write-Host "PORTX Antivirus Exclusion Setup" -ForegroundColor Cyan
Write-Host "PORTX Path: $PortxPath" -ForegroundColor Green

# Function to detect installed antivirus products
function Get-AntivirusProducts {
    try {
        $namespace = "Root\SecurityCenter2"
        $products = Get-CimInstance -Namespace $namespace -ClassName AntiVirusProduct -ErrorAction SilentlyContinue
        return $products
    }
    catch {
        Write-Warning "Could not query SecurityCenter2. Checking Windows Defender only."
        return $null
    }
}

# Function to add Windows Defender exclusions
function Add-WindowsDefenderExclusions {
    param([string]$BasePath)
    
    Write-Host "Configuring Windows Defender exclusions..." -ForegroundColor Yellow
    
    try {
        # Check if Windows Defender is active
        $defenderStatus = Get-MpComputerStatus -ErrorAction SilentlyContinue
        if (-not $defenderStatus.AntivirusEnabled) {
            Write-Host "Windows Defender is not active" -ForegroundColor Blue
            return $false
        }
        
        # PORTX directory exclusions
        $pathExclusions = @(
            $BasePath,
            "$BasePath\bin",
            "$BasePath\bin-ext", 
            "$BasePath\bin-tools",
            "$BasePath\mingw64",
            "$BasePath\usr"
        )
        
        foreach ($path in $pathExclusions) {
            if (Test-Path $path) {
                Add-MpPreference -ExclusionPath $path -ErrorAction SilentlyContinue
                Write-Host "  Added path exclusion: $path" -ForegroundColor Green
            }
        }
        
        # Process exclusions for key executables
        $processExclusions = @(
            "bash.exe",
            "git.exe", 
            "sh.exe",
            "portsh.exe",
            "mingw32-make.exe",
            "gcc.exe",
            "g++.exe"
        )
        
        foreach ($process in $processExclusions) {
            Add-MpPreference -ExclusionProcess $process -ErrorAction SilentlyContinue
            Write-Host "  Added process exclusion: $process" -ForegroundColor Green
        }
        
        Write-Host "Windows Defender exclusions configured successfully!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Error "Failed to configure Windows Defender: $($_.Exception.Message)"
        return $false
    }
}

# Function to provide manual instructions
function Show-ManualInstructions {
    param([string]$AntivirusName, [string]$BasePath)
    
    Write-Host "Manual exclusion setup required for $AntivirusName" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Please add the following paths to your antivirus exclusions:" -ForegroundColor White
    Write-Host "  $BasePath" -ForegroundColor Cyan
    Write-Host "  $BasePath\bin" -ForegroundColor Cyan  
    Write-Host "  $BasePath\bin-ext" -ForegroundColor Cyan
    Write-Host "  $BasePath\bin-tools" -ForegroundColor Cyan
    Write-Host "  $BasePath\mingw64" -ForegroundColor Cyan
    Write-Host "  $BasePath\usr" -ForegroundColor Cyan
    Write-Host ""
}

# Main execution
Write-Host ""

# Validate PORTX installation
if (-not (Test-Path $PortxPath)) {
    Write-Error "PORTX path not found: $PortxPath"
    exit 1
}

if (-not (Test-Path "$PortxPath\portx.cmd")) {
    Write-Error "Invalid PORTX installation: portx.cmd not found in $PortxPath"
    exit 1
}

# Get confirmation unless -Force is used
if (-not $Force) {
    $confirmation = Read-Host "Add antivirus exclusions for PORTX? This will improve performance significantly. (Y/N)"
    if ($confirmation -notmatch '^[Yy]') {
        Write-Host "Operation cancelled by user." -ForegroundColor Yellow
        exit 0
    }
}

# Detect and configure antivirus exclusions
$antivirusProducts = Get-AntivirusProducts
$exclusionsAdded = $false

if ($antivirusProducts) {
    Write-Host "Detected antivirus products:" -ForegroundColor Blue
    foreach ($av in $antivirusProducts) {
        Write-Host "  $($av.displayName)" -ForegroundColor White
        
        if ($av.displayName -like "*Windows Defender*") {
            $exclusionsAdded = Add-WindowsDefenderExclusions $PortxPath
        }
        elseif ($av.displayName -like "*Bitdefender*") {
            Show-ManualInstructions "Bitdefender" $PortxPath
        }
        elseif ($av.displayName -like "*Symantec*") {
            Show-ManualInstructions "Symantec Endpoint Protection" $PortxPath
        }
        elseif ($av.displayName -like "*McAfee*") {
            Show-ManualInstructions "McAfee Endpoint Security" $PortxPath
        }
        else {
            Show-ManualInstructions $av.displayName $PortxPath
        }
    }
}
else {
    # Fallback to Windows Defender only
    Write-Host "No third-party antivirus detected, configuring Windows Defender..." -ForegroundColor Blue
    $exclusionsAdded = Add-WindowsDefenderExclusions $PortxPath
}

# Summary
Write-Host ""
Write-Host "Configuration Summary:" -ForegroundColor Cyan
Write-Host "  PORTX Path: $PortxPath" -ForegroundColor White
if ($exclusionsAdded) {
    Write-Host "  Exclusions Added: Yes" -ForegroundColor Green
    Write-Host ""
    Write-Host "Success! PORTX antivirus exclusions configured." -ForegroundColor Green
    Write-Host "Git Bash and development tools should now run significantly faster!" -ForegroundColor Green
}
else {
    Write-Host "  Exclusions Added: Manual required" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Manual configuration required for optimal performance." -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Tip: Run 'git config --global core.fscache true' for additional Git performance boost!" -ForegroundColor Blue