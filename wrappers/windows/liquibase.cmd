@echo off
rem PORTX-WRAPPER: Auto-generated wrapper for liquibase/liquibase
set PORTX_ROOT=C:\App\PORTX
set PACKAGE_NAME=liquibase
set EXE_RELATIVE_PATH=liquibase.bat
set EXECUTABLE_PATH=%PORTX_ROOT%\packages\%PACKAGE_NAME%\%EXE_RELATIVE_PATH%

"%EXECUTABLE_PATH%" %*
