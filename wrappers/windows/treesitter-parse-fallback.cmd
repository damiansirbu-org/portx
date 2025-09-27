@echo off
rem PORTX Universal Wrapper for treesitter/treesitter-parse-fallback
rem Calls universal portx-wrap.exe with intelligent path conversion

set PORTX_ROOT=C:\App\PORTX

"%PORTX_ROOT%\go\target\portx-wrap.exe" "treesitter-parse-fallback" %*
