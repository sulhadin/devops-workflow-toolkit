#!/bin/bash

# Release Notes Generator
# Usage: ./generate_release_notes.sh <target_branch> <current_branch>

# Default branches if not provided
TARGET_BRANCH="${1:-main}"
CURRENT_BRANCH="${2:-$(git rev-parse --abbrev-ref HEAD)}"

# Ensure we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo "Error: Not in a git repository"
    exit 1
fi

# Fetch latest changes from remote
git fetch origin

# Generate release notes
generate_release_notes() {
    local target_branch="$1"
    local current_branch="$2"
    local output_file="merged_prs.txt"

    # Print branch comparison
    echo "Diff branches $target_branch..$current_branch"

    # Capture commit log between branches
    (git log --oneline "origin/$target_branch".."origin/$current_branch") > "$output_file"

    # Check if there are any commits
    local pr_list
    pr_list=$(cat "$output_file")

    if [ -z "$pr_list" ]; then
        echo "No commits found between branches, skipping"
        exit 0
    fi

    # Display separator
    echo "*****"

    echo "$pr_list"

    # Generate markdown release notes
    generate_markdown_release_notes "$pr_list"
}

# Generate markdown release notes
generate_markdown_release_notes() {
    local commit_list="$1"
    local release_notes_file="RELEASE_NOTES.md"
    local current_date
    current_date=$(date '+%Y-%m-%d')

    # Create release notes header
    echo "# Release Notes" > "$release_notes_file"
    echo "## $current_date" >> "$release_notes_file"
    echo "" >> "$release_notes_file"
    echo "### Commits" >> "$release_notes_file"

    # Add commits to release notes
    echo "$commit_list" | while IFS= read -r commit_line; do
        echo "- $commit_line" >> "$release_notes_file"
    done

    echo "Release notes generated: $release_notes_file"
}

# Main execution
main() {
    # Validate input
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <target_branch> [current_branch]"
        echo "Example: $0 main feature/new-implementation"
        exit 1
    fi

    # Generate release notes
    generate_release_notes "$TARGET_BRANCH" "$CURRENT_BRANCH"
}

# Run the script
main "$@"