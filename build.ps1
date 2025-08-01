# PORTX Build Script
param(
    [switch]$Clean = $false
)

$Version = Get-Content -Path "VERSION" -Raw | ForEach-Object { $_.Trim() }
$ArchiveName = "portx-$Version.zip"

Write-Host "Building PORTX $Version..." -ForegroundColor Green

if ($Clean) {
    Write-Host "Cleaning previous builds..." -ForegroundColor Yellow
    Remove-Item -Path "portx-*.zip" -Force -ErrorAction SilentlyContinue
}

# Remove existing archive
if (Test-Path $ArchiveName) {
    Remove-Item $ArchiveName -Force
}

# Create archive excluding certain directories/files
$Exclude = @('.git', '.claude', '*.zip', 'build.ps1', 'Makefile')
$Items = Get-ChildItem -Path . | Where-Object { 
    $item = $_
    -not ($Exclude | Where-Object { $item.Name -like $_ })
}

Write-Host "Creating archive: $ArchiveName" -ForegroundColor Cyan
Compress-Archive -Path $Items -DestinationPath $ArchiveName -CompressionLevel Optimal

Write-Host "Build complete: $ArchiveName" -ForegroundColor Green
Write-Host "Archive size: $((Get-Item $ArchiveName).Length / 1MB | Format-List {0:N2}) MB" -ForegroundColor Gray