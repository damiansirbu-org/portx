@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for uefitools/uefi-find
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=uefitools
set EXE_RELATIVE_PATH=UEFIFind.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
