#!/bin/bash

# Check if verbose flag is set
VERBOSE=false
for arg in "$@"; do
  if [ "$arg" = "--verbose" ]; then
    VERBOSE=true
    break
  fi
done

# Accept version as a parameter
if [ -z "$1" ]; then
  echo "Usage: sh file-name <version> <base> <branch> [--verbose]"
  exit 1
fi

# Accept mergedSince as a parameter
if [ -z "$2" ]; then
  echo "Usage: sh file-name <version> <base> <branch> [--verbose]"
  exit 1
fi
# Accept branch as a parameter
if [ -z "$3" ]; then
  echo "Usage: sh file-name <version> <base> <branch> [--verbose]"
  exit 1
fi

#mergedSince=${2:-$(TZ=UTC date -u -v-24H +'%Y-%m-%dT%H:%M:%SZ')}
version=$1
base=$2
branch=$3

major=false
minor=false
patch=false

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# Function to increment version
increment_version() {
  local version=$1
  local major_increment=$2
  local minor_increment=$3
  local patch_increment=$4

  major=$(echo "$version" | cut -d. -f1)
  minor=$(echo "$version" | cut -d. -f2)
  patch=$(echo "$version" | cut -d. -f3)

  if [ "$major_increment" = true ]; then
    major=$((major + 1))
    minor=0
    patch=0
  elif [ "$minor_increment" = true ]; then
    minor=$((minor + 1))
    patch=0
  elif [ "$patch_increment" = true ]; then
    patch=$((patch + 1))
  fi

  echo "$major.$minor.$patch"
}
# Function to log messages if verbose is enabled
log_verbose() {
  if $VERBOSE; then
    echo "${CYAN}[VERBOSE]${RESET}"
    echo "$1"
    echo "${RED}------------------------------------------------------${RESET}"
  fi
}

log_verbose "version: $version base:$base branch:$branch"

# Process the output to only include commit messages
cherry_picks=$(git cherry "$base" "$branch" | grep '^\+' | cut -d' ' -f2)

log_verbose "Found cherry-picked commits:\n$MAGENTA$cherry_picks$RESET"

if $VERBOSE; then
  echo "$cherry_picks" | while read -r hash; do
      commit_msg=$(git log -1 --format="%B" "$hash")
      log_verbose "$BLUE Processing commit:$RESET$MAGENTA $hash $RESET"
      # First check entire commit message for breaking changes, with or without colon
      if echo "$commit_msg" | grep -qiE "^(\* )?( +)?BREAKING[- _]CHANGE(\([^)]+\))? ?:( .*)?"; then
        log_verbose "$RED$commit_msg$RESET"
      # If no breaking changes, check the first line for feat/fix/perf, with or without colon
      elif echo "$commit_msg" | grep -qiE "^feat(\([^)]+\))?\s*:*"; then
        log_verbose "$YELLOW$commit_msg$RESET"
      elif echo "$commit_msg" | grep -qiE "^(fix|perf)(\([^)]+\))?\s*:*"; then
        log_verbose "$GREEN$commit_msg$RESET"
      fi
  done
fi

result=$(echo "$cherry_picks" | while read -r hash; do
  commit_msg=$(git log -1 --format="%B" "$hash")
  # First check entire commit message for breaking changes, with or without colon
  if echo "$commit_msg" | grep -qiE "^(\* )?( +)?BREAKING[- _]CHANGE(\([^)]+\))? ?:( .*)?"; then
    echo "major"
  # If no breaking changes, check the first line for feat/fix/perf, with or without colon
  elif echo "$commit_msg" | grep -qiE "^(( +)?\* )?(feat)(\([^)]+\))? ?:( .*)?"; then
    echo "minor"
  elif echo "$commit_msg" | grep -qiE "^(( +)?\* )?(fix|perf)(\([^)]+\))? ?:( .*)?"; then
    echo "patch"
  fi
done)

case "$result" in
  *major*) major=true ;;
  *minor*) minor=true ;;
  *patch*) patch=true ;;
esac

log_verbose "major:$RED $major $RESET minor:$YELLOW $minor $RESET patch:$GREEN $patch $RESET"


new_version=$(increment_version "$version" "$major" "$minor" "$patch")

log_verbose "Old version:$YELLOW $version $RESET"
log_verbose "New version:$GREEN $new_version $RESET"

# Output the new version
echo "$new_version"
