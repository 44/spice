REM @echo off

set GIT_BIN=%PROGRAMFILES%\Git\usr\bin
if not exist "%GIT_BIN%\bash.exe" (
    echo "Git for Windows is not installed"
    goto :EOF
)

if not exist "%LOCALAPPDATA%\Microsoft\Spice" mkdir "%LOCALAPPDATA%\Microsoft\Spice"

pushd "%LOCALAPPDATA%\Microsoft\Spice"

curl.exe -s -o launcher.sh -z launcher.sh https://tools.svnx.dev/dist/spice/latest/client/launcher.sh

popd

if not exist "%LOCALAPPDATA%\Microsoft\Spice\launcher.sh" (
    echo "Failed to download launcher"
    goto :EOF
) else (
    REM "%GIT_BIN%\bash.exe" "%LOCALAPPDATA%\Microsoft\Spice\launcher.sh" %*
)

:EOF

