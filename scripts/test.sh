#!/bin/sh
source $HOME/spice/check.sh silent
BRANCH=$1
mkdir -p $HOME/state
echo "$BRANCH" >$HOME/state/current-spice-session
cd $HOME/build
echo "Cleaning worktree"
git checkout -- $(git ls-files --modified)
git clean -f
echo "Checking out $BRANCH"
git -c advice.detachedHead=false checkout $(git show-ref -s refs/heads/$BRANCH)
echo "Unlocking keychain"
security unlock-keychain -p null $HOME/Library/Keychains/ODSPMacBuildKeychain.keychain-db

export SYSTEM_ACCESSTOKEN=irrelevant
export SPICE_REPO=$(pwd)
#TODO: configure
export SPICE_LOGS=$HOME/reports/logs
#TODO: should be in path
export XCBUILDFILTER=$HOME/.local/bin/upretty
ln -s $SPICE_REPO/client/onedrive/Product/SyncEngine/mac/Scripts/od ~/.local/bin/dev
export PATH="$HOME/.local/bin:$PATH"
shift
dev bf $@

rm $HOME/state/current-spice-session
