@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for osquery/osqueryd
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=osquery
set EXE_RELATIVE_PATH=osqueryd.exe
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
