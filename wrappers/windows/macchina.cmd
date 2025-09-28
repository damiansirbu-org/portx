@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for macchina/macchina
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=macchina
set EXE_RELATIVE_PATH=macchina.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
