@echo off
REM PORTX 2.0 Universal Package Manager
"%~dp0packages\powershell-core\pwsh.exe" -ExecutionPolicy Bypass -File "%~dp0ps\portx-import.ps1" %*