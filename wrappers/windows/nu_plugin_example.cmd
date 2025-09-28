@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for nushell/nu_plugin_example
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=nushell
set EXE_RELATIVE_PATH=nu_plugin_example.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
