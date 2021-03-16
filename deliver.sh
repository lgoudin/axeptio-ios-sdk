#!/bin/bash

BASEDIR=`dirname "$0"`

# Path to public project directory
PUBLIC_PROJECT_DIR="$BASEDIR/../AxeptioSDK Public"

# Get pod spec
PODSPEC="$PUBLIC_PROJECT_DIR/AxeptioSDK.podspec"
if [ ! -f $PODSPEC ]; then
	echo "Pod spec $PODSPEC not found"
	exit 1
fi

# Get version
VERSION=`cat $PODSPEC | awk '/s.version *=/{print $(NF)}'`
VERSION="${VERSION%\'}"
VERSION="${VERSION#\'}"

# Ensure this is a new version
if [ "_`git tag -l $VERSION`" != "_" ]; then
	echo "Version $VERSION already delivered"
	exit 1
fi

# Build universal framework
WORKSPACE="$BASEDIR/AxeptioSDK.xcworkspace"
TARGET=Axeptio
CONFIGURATION=Release
ARCHIVES_DIR="$BASEDIR/Archives"
FRAMEWORKS_DIR="Products/Library/Frameworks"

rm -rf "$ARCHIVES_DIR"

xcodebuild archive -workspace "$WORKSPACE" \
	-scheme "$TARGET" \
	-configuration "$CONFIGURATION" \
	-sdk iphoneos \
	-archivePath "$ARCHIVES_DIR/ios_devices.xcarchive" \
	BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
	SKIP_INSTALL=NO

xcodebuild archive -workspace "$WORKSPACE" \
	-scheme "$TARGET" \
	-configuration "$CONFIGURATION" \
	-sdk iphonesimulator \
	-archivePath "$ARCHIVES_DIR/ios_simulators.xcarchive" \
	BUILD_LIBRARY_FOR_DISTRIBUTION=YES \
	SKIP_INSTALL=NO

xcodebuild -create-xcframework \
	-framework "$ARCHIVES_DIR/ios_devices.xcarchive/$FRAMEWORKS_DIR/$TARGET.framework" \
	-framework "$ARCHIVES_DIR/ios_simulators.xcarchive/$FRAMEWORKS_DIR/$TARGET.framework" \
	-output "$ARCHIVES_DIR/$TARGET.xcframework"

# Copy universal framework in public project
cp -Rf "$ARCHIVES_DIR/$TARGET.xcframework" "$PUBLIC_PROJECT_DIR/AxeptioSDK"

# Clean
rm -rf "$ARCHIVES_DIR"

# Commit and push
echo "Delivering $PODSPEC $VERSION"
GIT_DIR="$PUBLIC_PROJECT_DIR/.git"
git --git-dir "$GIT_DIR" add *
git --git-dir "$GIT_DIR" commit -m "Release $VERSION"
git --git-dir "$GIT_DIR" tag $VERSION
git --git-dir "$GIT_DIR" push
git --git-dir "$GIT_DIR" push --tag
pod trunk push $PODSPEC --allow-warnings
