#!/bin/sh
source $SPICE_SCRIPTS/cmd/check.sh silent

echo "$SPICE_BRANCH" >$SPICE_STATE/current-spice-session

cd $SPICE_REPO
prepare_repo

echo "Unlocking keychain"
security unlock-keychain -p null $HOME/Library/Keychains/ODSPMacBuildKeychain.keychain-db

echo "Configuring offline mode"

# export SYSTEM_ACCESSTOKEN=irrelevant
# nuget sources add -Name "offline" -Source "/Volumes/data/offline/nuget" -ConfigFile $HOME/.CxCache/NugetCache/nuget_server.config
# nuget sources disable -Name "OneDrive.Client-Aggregate" -ConfigFile $HOME/.CxCache/NugetCache/nuget_server.config

if [[ -f "$(brew --prefix nvm)/nvm.sh" ]]; then
    echo "Activating node@18 using nvm"
    source $(brew --prefix nvm)/nvm.sh
    nvm use 18
fi

# yarn config set yarn-offline-mirror "/Volumes/data/offline/yarn"
#yarn config set offline true

echo "Configuring Xcode"
defaults write com.apple.dt.xcodebuild PBXNumberOfParallelBuildSubtasks 4
defaults write com.apple.dt.xcodebuild IDEBuildOperationMaxNumberOfConcurrentCompileTasks 4
defaults write com.apple.dt.Xcode PBXNumberOfParallelBuildSubtasks 4
defaults write com.apple.dt.Xcode IDEBuildOperationMaxNumberOfConcurrentCompileTasks 4

lolcat $SPICE_SCRIPTS/msg/welcome.txt

export SPICE_REPO=$(pwd)

#TODO: configure
export SPICE_LOGS=$SPICE_STATE/logs
mkdir -p $SPICE_LOGS
export LOGS=$SPICE_LOGS

cat $SPICE_SCRIPTS/msg/connect.md | envsubst | bat -p --file-name connect.md

#TODO: should be in path
export XCBUILDFILTER=$HOME/.local/bin/upretty
ln -f -s $SPICE_REPO/client/onedrive/Product/SyncEngine/mac/Scripts/od ~/.local/bin/dev
export PATH="$HOME/.local/bin:$PATH"
/bin/zsh -i

rm $SPICE_STATE/current-spice-session
