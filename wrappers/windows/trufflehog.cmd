@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for trufflehog/trufflehog
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=trufflehog
set EXE_RELATIVE_PATH=trufflehog.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
