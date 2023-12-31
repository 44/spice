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

echo "Configuring offline mode"
# export NUGET_SKIP_RESTORE=yes
export SYSTEM_ACCESSTOKEN=irrelevant
nuget sources add -Name "offline" -Source "/Volumes/data/offline/nuget" -ConfigFile $HOME/.CxCache/NugetCache/nuget_server.config
nuget sources disable -Name "OneDrive.Client-Aggregate" -ConfigFile $HOME/.CxCache/NugetCache/nuget_server.config

if [[ -f "$(brew --prefix nvm)/nvm.sh" ]]; then
    echo "Loading nvm"
    source $(brew --prefix nvm)/nvm.sh
    echo "Loading node"
    nvm use 18
fi

yarn config set yarn-offline-mirror "/Volumes/data/offline/yarn"
yarn config set offline true

echo "Configuring Xcode"
defaults write com.apple.dt.xcodebuild PBXNumberOfParallelBuildSubtasks 4
defaults write com.apple.dt.xcodebuild IDEBuildOperationMaxNumberOfConcurrentCompileTasks 4
defaults write com.apple.dt.Xcode PBXNumberOfParallelBuildSubtasks 4
defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks 4

lolcat $HOME/spice/msg/welcome.txt

export SPICE_REPO=$(pwd)
#TODO: configure
export SPICE_LOGS=$HOME/reports/logs

cat $HOME/spice/msg/connect.md | envsubst | bat -p --file-name connect.md

#TODO: should be in path
export XCBUILDFILTER=$HOME/.local/bin/upretty
ln -s $SPICE_REPO/client/onedrive/Product/SyncEngine/mac/Scripts/od ~/.local/bin/dev
export PATH="$HOME/.local/bin:$PATH"
/bin/zsh -i

rm $HOME/state/current-spice-session
