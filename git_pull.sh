#!/usr/bin/env bash

# Performs a git pull on all of the sub repositories that are checked out. If the repository has local changes, those changes are stashed before the pull.

DIR=$(dirname "$0")

do_git_pull () {
  GIT_DIR=$1
  cd $DIR/$GIT_DIR
  GIT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
  echo "-------"
  if [[ `git status --porcelain` ]]; then
    echo "warning: stashing local changes on $GIT_DIR $GIT_BRANCH ..."
    git stash
  fi
  echo "pulling $GIT_DIR $GIT_BRANCH ..."
  git pull
}

if [ -d "$DIR/aprexis-api" ]; then
  do_git_pull "aprexis-api"
fi

if [ -d "$DIR/aprexis-api-ui" ]; then
  do_git_pull "aprexis-api-ui"
fi

if [ -d "$DIR/aprexis-engine" ]; then
  do_git_pull "aprexis-engine"
fi

if [ -d "$DIR/aprexis-platform-5" ]; then
  do_git_pull "aprexis-platform-5"
fi

if [ -d "$DIR/aprexis-etl" ]; then
  do_git_pull "aprexis-etl"
fi

cd $DIR
