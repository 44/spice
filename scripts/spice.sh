# TODO: Check no builds atm
# Layout:
#    status
#    active
export PATH="$PATH":/usr/local/bin
BRANCH=$1
COMMAND=$2
shift
shift
if [[ -f $HOME/spice/$COMMAND.sh ]]; then
    echo
    sh $HOME/spice/$COMMAND.sh $BRANCH $@ || exit 1
else
    echo "Unknown command $COMMAND"
    exit 1
fi

exit
# Assign ID using mktemp
BRANCH=$2
BUILD_DIR=$(mktemp -d $HOME/reports/status/XXXX)
chmod og+rx $BUILD_DIR
BUILD_ID=$(basename $BUILD_DIR)
cd $HOME/build
COMMIT_ID=$(git show-ref -s refs/heads/$BRANCH)
SUBMIT_DATE=$(date)
cat <<EOF >$BUILD_DIR/info.txt
SPICE_ID=$BUILD_ID
SPICE_BRANCH=$BRANCH
SPICE_COMMIT_ID=$COMMIT_ID
SPICE_SUBMITTED="$SUBMIT_DATE"
SPICE_PROGRESS=Submitted
EOF

ln -s ./status/$BUILD_ID/info.txt $HOME/reports/active.txt

# Generate status file
# Write starting to file
# Generate build scipt
# Create tmux session
# Submit build to tmux session
#
#
echo >$BUILD_DIR/full-build-active.log
tmux new-session -d -s spice-build
cp $HOME/spice/build.sh $BUILD_DIR/build-script.sh
chmod +x $BUILD_DIR/build-script.sh
tmux new-window -n $BUILD_ID -t spice-build: $BUILD_DIR/build-script.sh $BRANCH $BUILD_ID
sleep 1
echo "Build $BUILD_ID launched in background, monitor in:"
echo "\tssh -t spice@mac.svnx.dev /usr/local/bin/tmux attach -t spice-build:$BUILD_ID"
echo "\thttps://mac.svnx.dev/builds/status/$BUILD_ID"
echo
echo "Feel free to leave (Ctrl-C) at any moment."
echo
tail -f $BUILD_DIR/full-build-active.log | xcpretty -c

