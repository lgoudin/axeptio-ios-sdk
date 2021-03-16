#!/bin/bash

BASEDIR=`dirname "$0"`

# Path to public project directory
PUBLIC_PROJECT_DIR="$BASEDIR/../AxeptioSDK Public"

# Get pod spec
PODSPEC="$PUBLIC_PROJECT_DIR/AxeptioSDK.podspec"
if [ ! -f "$PODSPEC" ]; then
	echo "Pod spec $PODSPEC not found"
	exit 1
fi

# Get version
VERSION=`cat "$PODSPEC" | awk '/s.version *=/{print $(NF)}'`
VERSION="${VERSION%\'}"
VERSION="${VERSION#\'}"

# Ensure this is a new version
if [ "_`git tag -l $VERSION`" != "_" ]; then
	echo "Version $VERSION already delivered"
	exit 1
fi

# Commit and push
echo "Delivering $PODSPEC $VERSION"
GIT_DIR="$PUBLIC_PROJECT_DIR/.git"
git --git-dir="$GIT_DIR" add *
git --git-dir="$GIT_DIR" commit -m "Release $VERSION"
git --git-dir="$GIT_DIR" tag $VERSION
git --git-dir="$GIT_DIR" push
git --git-dir="$GIT_DIR" push --tag
pod trunk push "$PODSPEC" --allow-warnings
