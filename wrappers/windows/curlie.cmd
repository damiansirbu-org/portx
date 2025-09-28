@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for curlie/curlie
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=curlie
set EXE_RELATIVE_PATH=curlie.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
