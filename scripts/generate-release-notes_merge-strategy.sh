#!/bin/bash

# GitHub Release Notes Generator
# Usage: ./generate_release_notes.sh <target_branch> <merged_since>

# Exit on any error
set -e

# Required parameters
TARGET_BRANCH="${1:-main}"
MERGED_SINCE="${2:-$(date -v-1d '+%Y-%m-%d')}"

# Validate GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "Error: GitHub CLI (gh) is not installed"
    exit 1
fi

# Validate jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is not installed"
    exit 1
fi

# Function to generate release notes
generate_release_notes() {
    local target_branch="$1"
    local merged_since="$2"
    local output_file="merged_prs.txt"

    # Fetch merged PRs
    gh pr list \
        --state merged \
        --base "$target_branch" \
        --search "merged:>=$merged_since" \
        --json title,url,mergedAt,author \
        | jq -r '.[] | "\(.title) by \(.author.login)"' > "$output_file"

    # Check if any PRs were merged
    local pr_list
    pr_list=$(cat "$output_file")

    if [ -z "$pr_list" ]; then
        echo "No PRs merged since $merged_since, skipping"
        exit 0
    fi

    echo "PR List:$pr_list"

    # Optional: Generate a markdown release notes file
    generate_markdown_release_notes "$pr_list"
}

# Function to create markdown release notes
generate_markdown_release_notes() {
    local pr_list="$1"
    local release_notes_file="RELEASE_NOTES.md"
    local current_date
    current_date=$(date '+%Y-%m-%d')

    # Create release notes header
    echo "# Release Notes" > "$release_notes_file"
    echo "## $current_date" >> "$release_notes_file"
    echo "" >> "$release_notes_file"
    echo "### Merged Pull Requests" >> "$release_notes_file"

    # Add PRs to release notes
    echo "$pr_list" | while IFS= read -r pr_line; do
        echo "- $pr_line" >> "$release_notes_file"
    done

    echo "Release notes generated: $release_notes_file"
}

# Main execution
main() {
    # Check if required arguments are provided
    if [ $# -lt 1 ]; then
        echo "Usage: $0 <target_branch> [merged_since_date]"
        echo "Example: $0 main 2023-06-01"
        exit 1
    fi

    # Generate release notes
    generate_release_notes "$TARGET_BRANCH" "$MERGED_SINCE"
}

# Run the script
main "$@"