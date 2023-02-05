$SPICE_BUILD="spice@mac.svnx.dev"
$SPICE_REMOTE="spice@mac.svnx.dev:build"

# type $env:USERPROFILE\.ssh\id_rsa.pub | ssh $SPICE_BUILD "cat >> .ssh/authorized_keys"

$GIT_STATUS=git status --porcelain
if ( -not [string]::IsNullOrEmpty($GIT_STATUS) ) {
    Write-Host "Working tree is dirty, forgot to commit your changes?" -Foreground yellow
    git status
    $RESPONSE=Read-Host -Prompt "Continue? [y/N]"
    if ($RESPONSE -ne "y") {
        exit 1
    }
}

$GIT_SPICE_REMOTE=git remote get-url spice 2>$null
if ( $GIT_SPICE_REMOTE -ne "$SPICE_REMOTE" ) {
    Write-Host "Configuring remote spice"
    git config checkout.defaultRemote origin
    git remote remove spice 2>$null
    git remote add spice $SPICE_REMOTE
    Write-Host "Remote spice $SPICE_REMOTE added" -Foreground green
}

Write-Host "Testing connection"
$CONNECTED_OVER_SSH=ssh -oBatchMode=yes $SPICE_BUILD echo connected
if ( $CONNECTED_OVER_SSH -ne "connected" ) {
    Write-Host "Public key authentication is not configured" -Foreground yellow
    # TODO: check if id_rsa.pub exists
    $RESPONSE=Read-Host -Prompt "Configure it? [Y/n]"
    if ($RESPONSE -ne "n") {
        type $env:USERPROFILE\.ssh\id_rsa.pub | ssh $SPICE_BUILD 'cat >>.ssh/authorized_keys'
    }
}

Write-Host "Refreshing spice"
git fetch spice master
$GIT_BRANCH=git rev-parse --abbrev-ref HEAD
$GIT_BRANCH_TARGET="$GIT_BRANCH"
if (-not ($GIT_BRANCH -like 'user/*')) {
    Write-Host "Current branch name does not start with user/*"
    $RESPONSE=Read-Host -Prompt "Continue? [y/N]"
    if ($RESPONSE -ne "y") {
        exit 1
    }
    $GIT_BRANCH_TARGET=Get-Random
    $GIT_BRANCH_TARGET="$GIT_BRANCH" + "-" + "$GIT_BRANCH_TARGET"
}
Write-Host "Pushing branch $GIT_BRANCH as $GIT_BRANCH_TARGET to $SPICE_REMOTE"
git push spice ${GIT_BRANCH}:${GIT_BRANCH_TARGET} --force
Write-Host "Your branch $GIT_BRANCH is pushed to spice" -Foreground green

ssh $SPICE_BUILD ./spice/spice.sh build $GIT_BRANCH_TARGET
