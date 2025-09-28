@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for duckdb/duckdb
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=duckdb
set EXE_RELATIVE_PATH=duckdb.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
