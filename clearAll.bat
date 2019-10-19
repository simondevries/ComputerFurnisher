REM This is intended to be run from the shared folder (rather than the D: drive)

call config.bat

Powershell.exe -executionpolicy bypass -File "./clearAll.ps1" 