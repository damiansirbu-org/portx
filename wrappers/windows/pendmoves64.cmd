@echo off
rem PORTX Universal Wrapper for sysinternals/pendmoves64
rem Calls universal portx-wrap.exe with intelligent path conversion

set PORTX_ROOT=C:\App\PORTX

"%PORTX_ROOT%\go\target\portx-wrap.exe" "pendmoves64" %*
