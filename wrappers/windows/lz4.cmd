@echo off
rem PORTX Universal Wrapper for lz4/lz4
rem Calls universal portx-wrap.exe with intelligent path conversion

set PORTX_ROOT=C:\App\PORTX

"%PORTX_ROOT%\go\target\portx-wrap.exe" "lz4" %*
