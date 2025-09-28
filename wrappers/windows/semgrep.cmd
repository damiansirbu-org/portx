@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for semgrep/semgrep
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=semgrep
set EXE_RELATIVE_PATH=semgrep.cmd
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
