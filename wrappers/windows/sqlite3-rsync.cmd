@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for sqlite/sqlite3-rsync
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=sqlite
set EXE_RELATIVE_PATH=sqlite3_rsync.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
