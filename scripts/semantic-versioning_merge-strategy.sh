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
  echo "Usage: sh file-name <version> <date> <branch> [--verbose]"
  exit 1
fi

# Accept mergedSince as a parameter
if [ -z "$2" ]; then
  echo "Usage: sh file-name <version> <date> <branch> [--verbose]"
  exit 1
fi
# Accept branch as a parameter
if [ -z "$3" ]; then
  echo "Usage: sh file-name <version> <date> <branch> [--verbose]"
  exit 1
fi

#mergedSince=${2:-$(TZ=UTC date -u -v-24H +'%Y-%m-%dT%H:%M:%SZ')}
version=$1
mergedSince=$2
branch=$3
major=false
minor=false
patch=false

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
    echo "[VERBOSE] $1"
  fi
}

log_verbose "version: $version date:$mergedSince branch:$branch"

# Process the output to only include commit messages
commits=$(gh pr list --state merged --base "$branch" --search "merged:>=$mergedSince" --json title,mergedAt,author,commits | \
jq -r '.[] | .commits[] | .messageHeadline')

log_verbose "Search in: $commits"
if $VERBOSE; then
  echo "$commits" | while read -r commit; do
      if echo "$commit" | grep -qi "^BREAKING[ -]CHANGE\s*:*\|^.*BREAKING[ -]CHANGE\s*:"; then
        log_verbose "MAJOR: $commit"
      elif echo "$commit" | head -n1 | grep -qiE "^feat(\([^)]+\))?\s*:*"; then
        log_verbose "MINOR: $commit"
      elif echo "$commit" | head -n1 | grep -qiE "^(fix|perf)(\([^)]+\))?\s*:*"; then
        log_verbose "PATCH: $commit"
      fi
  done
fi
# Process each commit message
result=$(echo "$commits" | while read -r commit; do
  # First check entire commit message for breaking changes, with or without colon
  if echo "$commit" | grep -qi "^BREAKING[ -]CHANGE\s*:*\|^.*BREAKING[ -]CHANGE\s*:"; then
    echo "major"
  # If no breaking changes, check the first line for feat/fix/perf, with or without colon
  elif echo "$commit" | head -n1 | grep -qiE "^feat(\([^)]+\))?\s*:*"; then
    echo "minor"
  elif echo "$commit" | head -n1 | grep -qiE "^(fix|perf)(\([^)]+\))?\s*:*"; then
    echo "patch"
  fi
done)

case "$result" in
  *major*) major=true ;;
  *minor*) minor=true ;;
  *patch*) patch=true ;;
esac

log_verbose "major:$major minor:$minor patch:$patch"


new_version=$(increment_version "$version" "$major" "$minor" "$patch")

log_verbose "Old version: $version"
log_verbose "New version: $new_version"

# Output the new version
echo $new_version
