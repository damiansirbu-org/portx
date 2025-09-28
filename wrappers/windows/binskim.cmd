@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for binskim/binskim
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=binskim
set EXE_RELATIVE_PATH=BinSkim.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
