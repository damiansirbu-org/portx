@echo off
REM PORTX Package Builder - Creates ZIP packages for GitHub Releases
REM Usage: build-packages.bat

setlocal EnableDelayedExpansion

echo Building PORTX packages for GitHub Releases...

REM Create output directory
if not exist "releases" mkdir releases
cd releases

echo.
echo [1/3] Creating core-bin package...
if exist "portx-core-bin.zip" del "portx-core-bin.zip"
7za a -tzip -mx9 "portx-core-bin.zip" "..\..\bin\*" -r
echo Created: portx-core-bin.zip

echo.
echo [2/3] Creating individual tool packages...

REM Loop through each tool directory in bin-tools
for /d %%i in ("..\..\packages\*") do (
    set "toolname=%%~ni"
    echo Creating package for: !toolname!
    if exist "portx-!toolname!.zip" del "portx-!toolname!.zip"
    7za a -tzip -mx9 "portx-!toolname!.zip" "%%i\*" -r
    echo Created: portx-!toolname!.zip
)

echo.
echo [3/3] Creating core system packages...

REM Create other essential packages
if exist "portx-core.zip" del "portx-core.zip"
7za a -tzip -mx9 "portx-core.zip" "..\..\bin\*" "..\..\cmd\*" "..\..\etc\*" "..\..\home\*" -r
echo Created: portx-core.zip

if exist "portx-git-system.zip" del "portx-git-system.zip"
7za a -tzip -mx9 "portx-git-system.zip" "..\..\mingw64\*" "..\..\usr\*" -r
echo Created: portx-git-system.zip

echo.
echo Package creation complete!
echo.
echo Packages created in releases\ directory:
dir /b *.zip

cd ..
echo.
echo Next steps:
echo 1. Upload packages to GitHub Releases
echo 2. Update package manager manifest
echo 3. Remove LFS tracking