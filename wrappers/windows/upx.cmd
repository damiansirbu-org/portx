@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for upx/upx
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=upx
set EXE_RELATIVE_PATH=upx.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
