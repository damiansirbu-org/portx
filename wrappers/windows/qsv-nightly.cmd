@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for qsv/qsv-nightly
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=qsv
set EXE_RELATIVE_PATH=qsv_nightly.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
