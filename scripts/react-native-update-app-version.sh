#!/bin/bash

new_version=$1

if [ -z "$new_version" ]; then
  echo "Usage: sh update_version.sh <version>"
  exit 1
fi

# iOS - Update project version and build number
cd ios
current_ios_version=$(defaults read $(pwd)/your_app_name/Info CFBundleShortVersionString)
echo "Current version found: $current_ios_version"

if [ "$current_ios_version" = "$new_version" ]; then
  xcrun agvtool next-version -all
  echo "iOS: Incremented build number only for version $current_ios_version"
else
  xcrun agvtool new-marketing-version "$new_version"
  xcrun agvtool new-version -all 1

  if [ -f "$(pwd)/your_app_name/InfoStaging.plist" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $new_version" "$(pwd)/your_app_name/InfoStaging.plist"
    /usr/libexec/PlistBuddy -c "Set :CFBundleVersion 1" "$(pwd)/your_app_name/InfoStaging.plist"
    echo "iOS: Updated InfoStaging.plist version to $new_version"
  fi

  echo "iOS: Updated version to $new_version and reset build number"
fi
cd ..

# Android - Update version name and version code
cd android/app

# Extract current version name and code
current_android_version=$(grep "versionName" build.gradle | sed 's/.*"\(.*\)"/\1/')
current_android_code=$(grep "versionCode" build.gradle | grep -o '[0-9]\+')

if [ "$current_android_version" = "$new_version" ]; then
  new_android_code=$((current_android_code + 1))
  sed -i '' "s/versionCode $current_android_code/versionCode $new_android_code/" build.gradle
  echo "Android: Incremented build number only for version $current_android_version"
else
  new_android_code=1
  sed -i '' "s/versionName \"$current_android_version\"/versionName \"$new_version\"/" build.gradle
  sed -i '' "s/versionCode $current_android_code/versionCode $new_android_code/" build.gradle
  echo "Android: Updated version to $new_version and reset build number"
fi

cd ..
cd ..

#jq ".version = \"$new_version\"" package.json > temp.json && mv temp.json package.json
jq ".version = \"$new_version\"" version.json > temp.json && mv temp.json version.json

echo "package.json: Updated version to $new_version"

echo "Version updates completed for Android, iOS, and package.json."
