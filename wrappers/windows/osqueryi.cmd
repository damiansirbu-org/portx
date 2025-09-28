@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for osquery/osqueryi
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=osquery
set EXE_RELATIVE_PATH=osqueryi.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
