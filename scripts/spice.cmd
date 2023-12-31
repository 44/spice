@echo off

if not exist "%LOCALAPPDATA%\Microsoft\Spice" mkdir "%LOCALAPPDATA%\Microsoft\Spice"

powershell "Set-Content -Path $env:LOCALAPPDATA\Microsoft\Spice\launcher.ps1 -Value (iwr -ErrorAction Stop -TimeoutSec 20 -UseBasicParsing -Uri https://mac.svnx.dev/builds/scripts/launcher.ps1).Content"

if not exist "%LOCALAPPDATA%\Microsoft\Spice\launcher.ps1" (
    echo "Failed to download launcher"
    exit /b 1
) else (
    powershell -File "%LOCALAPPDATA%\Microsoft\Spice\launcher.ps1" %*
)
