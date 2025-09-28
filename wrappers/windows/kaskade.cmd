@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for kaskade/kaskade
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=kaskade
set EXE_RELATIVE_PATH=python/Scripts/kaskade.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
