@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for gpg/gpg-connect-agent
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=gpg
set EXE_RELATIVE_PATH=gpg-connect-agent.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
