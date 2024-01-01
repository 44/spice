export SPICE_STATE=$HOME/Library/Caches/spice
mkdir -p $SPICE_STATE

# env.sh is expected to populate SPICE_REPO
source $HOME/Library/Caches/spice/env.sh

function prepare_repo() {
    echo "Cleaning worktree"
    git checkout -- $(git ls-files --modified)
    git clean -f

    echo "Checking out $SPICE_BRANCH"
    git -c advice.detachedHead=false checkout $(git show-ref -s refs/heads/$SPICE_BRANCH)
}

function prepare_workspace() {
    SPICE_WORKSPACE=$(echo $SPICE_BRANCH | sed -e 's|^spice/||' | sed -e 's|/.*||')
    echo "Preparing workspace $SPICE_WORKSPACE"
    mkdir -p $SPICE_STATE/ws/$SPICE_WORKSPACE
    export SPICE_LOGS=$SPICE_STATE/ws/$SPICE_WORKSPACE
    export LOGS=$SPICE_LOGS
}
