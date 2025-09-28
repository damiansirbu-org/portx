@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for 7zip/7za
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=7zip
set EXE_RELATIVE_PATH=7za.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
