SPICE_BUILD="spice@mac.svnx.dev"
SPICE_REMOTE="spice@mac.svnx.dev:build"

git_sync_needed=yes
GIT_BRANCH_TARGET=unknown

[[ "$1" == "help" ]] && git_sync_needed=no
[[ "$1" == "check" ]] && git_sync_needed=no

echo "git sync needed: $git_sync_needed"

if [[ "$git_sync_needed" == "yes" ]]; then
    GIT_STATUS=$(git status --porcelain)
    if [[ ! -z "$GIT_STATUS" ]]; then
        git status --short
        echo "Working tree is dirty, forgot to commit your changes?"
        read -p "Continue? [y/N]" response
        if [[ "$response" != "y" ]]; then
            exit 1
        fi
    fi
    GIT_SPICE_REMOTE=$(git remote get-url spice 2>/dev/null)
    if [[ "$GIT_SPICE_REMOTE" != "$SPICE_REMOTE" ]]; then
        echo "Configuring remote spice"
        git config checkout.defaultRemote origin
        git remote remove spice 2>/dev/null
        git remote add spice $SPICE_REMOTE
        echo "Remote spice $SPICE_REMOTE added"
    fi
fi

echo "Testing connection"
CONNECTED_OVER_SSH=$(ssh -oBatchMode=yes $SPICE_BUILD echo connected)
if [[ "$CONNECTED_OVER_SSH" != "connected" ]]; then
    echo "Public key authentication is not configured"
    read -p "Configure it? [Y/n]" response
    if [[ "$response" != "n" ]]; then
        cat $HOME/.ssh/id_rsa.pub | ssh $SPICE_BUILD 'cat >>.ssh/authorized_keys'
    fi
fi

if [[ "$git_sync_needed" == "yes" ]]; then
    echo "Refreshing spice"
    GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    if [[ ! "$GIT_BRANCH" =~ ^user/ ]]; then
        echo "Current branch name does not start with user/*"
        read -p "Continue? [y/N]" response
        if [[ "$response" != "y" ]]; then
            exit 1
        fi
    fi
    GIT_BRANCH_SHORT_NAME=$(echo $GIT_BRANCH | sed -E 's/[^\/]*\/[^\/]*\///')
    GIT_BRANCH_TARGET="spice/$USERNAME/$GIT_BRANCH_SHORT_NAME"
    if [[ -z "$USE_STASH" ]]; then
        git branch --force $GIT_BRANCH_TARGET HEAD
    else
        GIT_STASH_REF=stash@{0}
        echo "Stashing uncommitted changes as $GIT_STASH_REF"
        git stash push --include-untracked --message "spice-push"
        echo "Checkout out $GIT_BRANCH_TARGET"
        git branch -D $GIT_BRANCH_TARGET
        git checkout -b $GIT_BRANCH_TARGET
        echo "Applying uncommitted changes"
        git stash apply $GIT_STASH_REF
        git status
        echo "Adding uncommitted changes"
        git add .
        git status
        echo "Committing uncommitted changes"
        git commit -m "Applying uncommitted changes"
        git status
        echo "Restoring"
        git checkout $GIT_BRANCH
        git status
        echo "Restoring stash"
        git stash apply $GIT_STASH_REF
        # git stash drop $GIT_STASH_REF
    fi

    echo "Pushing branch $GIT_BRANCH as $GIT_BRANCH_TARGET to $SPICE_REMOTE"
    git push spice ${GIT_BRANCH_TARGET}:${GIT_BRANCH_TARGET} --force --no-verify
    echo "Your branch $GIT_BRANCH is pushed to spice"
fi

ssh -o LogLevel=QUIET -tt $SPICE_BUILD ./spice/spice.sh $GIT_BRANCH_TARGET "$@"

exit

# stash experiments
STASH_REF=stash@{0}
# can be stash^{/spice-push}
git stash push --include-untracked --message "spice-push"
# remember current branch
git checkout -b spice/xxx
git stash apply $STASH_REF
git add .
git commit -m "spice-push"
#spice push
git checkout -
git stash apply $STASH_REF
git stash drop $STASH_REF


if ( $git_sync_needed ) {
    Write-Host "Refreshing spice"
    $GIT_BRANCH=git rev-parse --abbrev-ref HEAD

    if (-not ($GIT_BRANCH -like 'user/*')) {
        Write-Host "Current branch name does not start with user/*"
        $RESPONSE=Read-Host -Prompt "Continue? [y/N]"
        if ($RESPONSE -ne "y") {
            exit 1
        }
    }

    $GIT_BRANCH_SHORT_NAME=$GIT_BRANCH -replace '[^/]*/[^/].*/', ''
    $GIT_BRANCH_TARGET="spice/$env:USERNAME/$GIT_BRANCH_SHORT_NAME"
    git branch --force $GIT_BRANCH_TARGET HEAD

    Write-Host "Pushing branch $GIT_BRANCH as $GIT_BRANCH_TARGET to $SPICE_REMOTE"
    git push spice ${GIT_BRANCH_TARGET}:${GIT_BRANCH_TARGET} --force --no-verify

    Write-Host "Your branch $GIT_BRANCH is pushed to spice" -Foreground green
}

function Enable-ANSIEscapes {
	# Enable ANSI / VT100 16-color escape sequences:
	# Original discovery blog post:
	# http://stknohg.hatenablog.jp/entry/2016/02/22/195644
	# Esc sequence support documentation
	# https://msdn.microsoft.com/en-us/library/windows/desktop/mt638032(v=vs.85).aspx

	# This doesn't do anything if the type is already added, so don't worry
	# about doing this every single time, I guess
	Add-Type -MemberDefinition @"
[DllImport("kernel32.dll", SetLastError=true)]
public static extern bool SetConsoleMode(IntPtr hConsoleHandle, int mode);
[DllImport("kernel32.dll", SetLastError=true)]
public static extern IntPtr GetStdHandle(int handle);
[DllImport("kernel32.dll", SetLastError=true)]
public static extern bool GetConsoleMode(IntPtr handle, out int mode);
"@ -Namespace Win32 -Name NativeMethods

	# GetStdHandle: https://msdn.microsoft.com/en-us/library/windows/desktop/ms683231(v=vs.85).aspx
	# -11 is the code for STDOUT (-10 is STDIN, -12 is STDERR)
	$Handle = [Win32.NativeMethods]::GetStdHandle(-11)

	# GetConsoleMode: https://msdn.microsoft.com/en-us/library/windows/desktop/ms683167(v=vs.85).aspx
	# get the console "mode" --- contains info about how to handle
	# wrapping, etc. $Mode is set by reference by GetConsoleMode
	$Mode = 0
	$ret = [Win32.NativeMethods]::GetConsoleMode($Handle, [ref]$Mode)
	# the mode is a bitmask so we binary or with 0x0004
	# (ENABLE_VIRTUAL_TERMINAL_PROCESSING)

	# SetConsoleMode: https://msdn.microsoft.com/en-us/library/windows/desktop/ms686033(v=vs.85).aspx
	return [Win32.NativeMethods]::SetConsoleMode($Handle, $Mode -bor 4)
}

$enabled = Enable-ANSIEscapes

ssh -o LogLevel=QUIET -t $SPICE_BUILD ./spice/spice.sh $GIT_BRANCH_TARGET "$args"
