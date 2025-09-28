@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for atac/atac
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=atac
set EXE_RELATIVE_PATH=atac.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
