#!/bin/sh

if [[ -f $HOME/state/current-spice-session ]]; then
    export SPICE_SESSION=$(cat $HOME/state/current-spice-session)
    cat $HOME/spice/msg/busy.md | envsubst | bat -p --file-name busy.md
    exit 1
fi

if [[ "$1" != "silent" ]]; then
    bat -p $HOME/spice/msg/ready.md
fi
