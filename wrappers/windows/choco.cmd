@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for chocolatey/choco
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=chocolatey
set EXE_RELATIVE_PATH=choco.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
