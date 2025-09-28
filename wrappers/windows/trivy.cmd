@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for trivy/trivy
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=trivy
set EXE_RELATIVE_PATH=trivy.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
