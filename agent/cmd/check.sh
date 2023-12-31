#!/bin/sh

source $SPICE_SCRIPTS/setenv.sh
if [[ -f $SPICE_STATE/current-spice-session ]]; then
    export SPICE_SESSION=$(cat $SPICE_STATE/current-spice-session)
    cat $SPICE_SCRIPTS/msg/busy.md | envsubst | bat -p --file-name busy.md
    exit 1
fi

if [[ "$1" != "silent" ]]; then
    bat -p $SPICE_SCRIPTS/msg/ready.md
fi
