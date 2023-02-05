if ("$env:PATH".Contains("Microsoft\WindowsApps")) {
    $wrapper=(iwr https://mac.svnx.dev/builds/scripts/spice.cmd.txt).Content
    Set-Content -Path "$env:LOCALAPPDATA\Microsoft\WindowsApps\spice.cmd" -Force -Value $wrapper
    Write-Host "Setup finished, you can use spice command now" -Foreground green
} else {
    Write-Host "Could not find directory to setup spice to in $env:PATH" -Foreground red
}
