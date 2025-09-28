@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for k9s/k9s
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=k9s
set EXE_RELATIVE_PATH=k9s.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
