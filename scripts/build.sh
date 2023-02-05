BRANCH=$1
BUILD_ID=$2
BUILD_DIR=$HOME/reports/status/$BUILD_ID
START_DATE=$(date)

echo "Building branch $BRANCH"
echo "Logs available in $BUILD_DIR"
echo "Current PID: $$"
echo "$$" >$BUILD_DIR/pid
echo "SPICE_STARTED=\"$START_DATE\"" >>$BUILD_DIR/info.txt

function report {
    echo "SPICE_PROGRESS=\"$1\"" >>$BUILD_DIR/info.txt
    echo "warning: $1" >>$BUILD_DIR/full-build-active.log
    echo "$1"
}

trap "unlink $HOME/reports/active.txt" INT TERM

start_time=$(date +%s)

cd $HOME/build
report "Cleaning worktree"
git clean -f
COMMIT_ID=$(git show-ref -s refs/heads/$BRANCH)
report "Checking out commit $COMMIT_ID"
git checkout $COMMIT_ID
report "Unlocking keychain"
security unlock-keychain -p null $HOME/Library/Keychains/ODSPMacBuildKeychain.keychain-db
report "Starting build"
echo "Building $BRANCH ($COMMIT_ID)" >>$BUILD_DIR/full-build-active.log
set -o pipefail && xcodebuild -IDEBuildOperationMaxNumberOfConcurrentCompileTasks=4 -project client/onedrive/Product/SyncEngine/mac/MacClientAndTests/MacClientAndTests.xcodeproj -scheme 'Build All' -showBuildTimingSummary NUGET_SKIP_RESTORE=yes 2>&1 | tee -a $BUILD_DIR/full-build-active.log | xcbeautify
BUILD_STATUS=$?
report "Build finished"
unlink $HOME/reports/active.txt
cp $BUILD_DIR/full-build-active.log $BUILD_DIR/full-build.log

end_time=$(date +%s)
elapsed=$(( end_time - start_time ))
echo "SPICE_DURATION=$elapsed" >> $BUILD_DIR/info.txt
echo "SPICE_BUILD_EXIT_CODE=$BUILD_STATUS" >> $BUILD_DIR/info.txt

echo >> $BUILD_DIR/full-build-active.log
echo "warning: Build finished in $elapsed seconds with exit code: $BUILD_STATUS" >> $BUILD_DIR/full-build-active.log
echo "warning: Logs available at https://mac.svnx.dev/builds/status/$BUILD_ID" >> $BUILD_DIR/full-build-active.log
rm $BUILD_DIR/full-build-active.log
cat $BUILD_DIR/full-build.log | xcbeautify --disable-colored-output >$BUILD_DIR/compact-build.log
FINISH_DATE=$(date)
echo "SPICE_FINISHED=\"$FINISH_DATE\"" >> $BUILD_DIR/info.txt
if [ $BUILD_STATUS -eq 0 ]; then
    echo "SPICE_BUILD_STATUS=Succeeded" >> $BUILD_DIR/info.txt
else
    echo "SPICE_BUILD_STATUS=Failed" >> $BUILD_DIR/info.txt
fi
echo "SPICE_PROGRESS=Done" >> $BUILD_DIR/info.txt
tail_pid=$(ps x | grep "tail" | grep "status/$BUILD_ID/" | awk '{print $1;}')
kill $tail_pid
