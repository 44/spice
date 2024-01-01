#!/bin/sh
source $SPICE_SCRIPTS/setenv.sh
echo "export SPICE_REPO=$SPICE_REPO"
CMD=$1

case "$CMD" in
    "check")
        echo "export SPICE_REPO_SYNC=no"
        ;;
    "help")
        echo "export SPICE_REPO_SYNC=no"
        ;;
    *)
        echo "export SPICE_REPO_SYNC=yes"
        ;;
esac
