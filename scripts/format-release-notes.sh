#!/bin/bash

#set -x  # Enable debug mode
#set -e  # Exit immediately if a command exits with a non-zero status

# Accept version as a parameter
if [ -z "$1" ]; then
  echo "No release notes"
  exit 0
fi

PR_LIST=$1

PR_LIST_FORMATTED=$(echo "$PR_LIST" | base64 -d)

PR_LIST_FORMATTED=$(echo "$PR_LIST_FORMATTED" | sed -E 's|^[[:space:]]*([a-f0-9]{8})|[<https://github.com/sulhadin/devops-workflow-toolkit/commit/\1\|\1>] |g')
PR_LIST_FORMATTED=$(echo "$PR_LIST_FORMATTED" | sed -E 's|#([a-zA-Z0-9]{8}[a-z0-9]*)|<https://app.clickup.com/t/\1\|#\1>|g')
PR_LIST_FORMATTED=$(echo "$PR_LIST_FORMATTED" | sed -E 's|\(#([0-9]+)\)|(<https://github.com/sulhadin/devops-workflow-toolkit/pull/\1\|#\1>)|g')

PR_LIST_FORMATTED="${PR_LIST_FORMATTED//\\n/$'\n'}"

echo "$PR_LIST_FORMATTED"

