@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for musikube/musikcube-gui
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=musikube
set EXE_RELATIVE_PATH=musikcube-gui.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
