@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for cosign/cosign
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=cosign
set EXE_RELATIVE_PATH=cosign.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
