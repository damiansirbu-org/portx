@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for qsv/qsvdp
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=qsv
set EXE_RELATIVE_PATH=qsvdp.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
