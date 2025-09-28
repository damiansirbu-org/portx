@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for volatility/vol
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=volatility
set EXE_RELATIVE_PATH=vol.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
