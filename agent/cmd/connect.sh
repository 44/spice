#!/bin/sh
source $SPICE_SCRIPTS/cmd/check.sh silent

echo "$SPICE_BRANCH" >$SPICE_STATE/current-spice-session

cd $SPICE_REPO
prepare_repo
prepare_workspace

echo "Unlocking keychain"
security unlock-keychain -p null $HOME/Library/Keychains/ODSPMacBuildKeychain.keychain-db

if [[ -f "$(brew --prefix nvm)/nvm.sh" ]]; then
    echo "Activating node@18 using nvm"
    source $(brew --prefix nvm)/nvm.sh
    nvm use 18
fi

lolcat $SPICE_SCRIPTS/msg/welcome.txt

export SPICE_REPO=$(pwd)

cat $SPICE_SCRIPTS/msg/connect.md | envsubst | bat -p --file-name connect.md

#TODO: should be in path
export XCBUILDFILTER=$HOME/.local/bin/upretty
ln -f -s $SPICE_REPO/client/onedrive/Product/SyncEngine/mac/Scripts/od ~/.local/bin/dev
export PATH="$HOME/.local/bin:$PATH"

export SYSTEM_ACCESSTOKEN=irrelevant
/bin/zsh -i

rm $SPICE_STATE/current-spice-session

echo "Good bye!!!"
