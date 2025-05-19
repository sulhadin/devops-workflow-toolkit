# 🚀 DevOps Workflow Toolkit

## Overview
Advanced CI/CD and release management scripts demonstrating professional-grade automation and semantic versioning strategies.

## Features
- 🔢 Semantic Versioning
- 🔄 Cross-Platform Version Management
- 🏗️ Automated Release Workflows
- 🔍 Verbose Logging and Debugging

## Table of Contents
- Scripts
  - Merge Strategy
      * [Semantic Versioning Script](#merge-strategy-script)
      * [Release Notes Generator](#github-release-notes-generator-script)
  - Cherry-pick Strategy
      * [Semantic Versioning Script](#cherry-pick-strategy-script)
      * [Release Notes Generator](#git-cherry-pick-release-notes-generator)
  - Other scripts
      * [Release Notes Formatter Script](#release-notes-formatter-script)
      * [React Native App Version Updater](#extra-react-native-app-version-updater)
- [Quick Navigation](#quick-navigation-)
- [Quick Commands Cheat Sheet](#quick-commands-cheat-sheet-)


# Merge Strategy Script

## Semantic Versioning
### Overview
This bash script automates semantic version incrementation based on merged pull request commits. It follows conventional commit guidelines to determine version bump type (major, minor, or patch).

### Usage
```bash 
sh semantic-versioning_merge-strategy.sh  <version> <date> <branch> [--verbose]
``` 

#### Parameters
- `<version>`: Current semantic version (e.g., `1.2.3`)
- `<date>`: Date to check merged PRs from
- `<branch>`: Target branch to check merged PRs
- `[--verbose]`: Optional flag for detailed logging

### Version Increment Rules
- **Major Bump**: Commit contains "BREAKING CHANGE"
- **Minor Bump**: Commit starts with "feat:"
- **Patch Bump**: Commit starts with "fix:" or "perf:"

### Example
```bash
sh semantic-versioning_merge-strategy.sh 1.0.0 2024-01-01 main --verbose
```

## Release Notes Generator Script

### Overview
A bash script that automatically generates release notes by fetching and documenting merged pull requests from a specified GitHub branch.

### Features
- Fetch merged pull requests for a target branch
- Generate a markdown release notes file
- Supports custom branch and date range
- Validates required CLI tools (gh, jq)

### Usage
```bash 
sh ./generate-release-notes_merge-strategy.sh [target_branch] [merged_since_date]
``` 

#### Parameters
- `target_branch`: Target GitHub branch (default: `main`)
- `merged_since_date`: Date to fetch merged PRs from (default: previous day)

### Example Commands
```bash
# Generate release notes for develop branch since specific date
./generate-release-notes_merge-strategy.sh develop 2024-01-01
``` 

### Output Files
- `merged_prs.txt`: List of merged pull requests
- `RELEASE_NOTES.md`: Markdown-formatted release notes

# Cherry-Pick Strategy Script
## Semantic Versioning

### Overview
This bash script automates semantic version incrementation based on cherry-picked commits between two branches. It follows conventional commit guidelines to determine version bump type (major, minor, or patch).

### Usage
```bash 
sh semantic-versioning_cherry-pick-strategy.sh  <version> <base> <branch> [--verbose]
``` 

#### Parameters
- `<version>`: Current semantic version (e.g., `1.2.3`)
- `<base>`: Base branch to compare from
- `<branch>`: Target branch to check cherry-picked commits
- `[--verbose]`: Optional flag for detailed logging

### Version Increment Rules
- **Major Bump**: Commit contains "BREAKING CHANGE"
- **Minor Bump**: Commit starts with "feat:"
- **Patch Bump**: Commit starts with "fix:" or "perf:"

### Key Features
- Identifies cherry-picked commits between branches
- Color-coded verbose logging
- Supports various commit message formats

### Verbose Mode
When `--verbose` is used, the script provides:
- List of cherry-picked commits
- Color-coded commit message analysis
- Detailed version bump information

### Example
```bash
sh semantic-versioning_cherry-pick-strategy.sh 1.0.0 main develop --verbose
```

# Cherry-Pick Release Notes Generator

## Overview
A bash script that generates release notes by comparing commits between two git branches using cherry-pick strategy.

## Features
- Automatically detect current branch
- Compare commits between target and current branches
- Generate markdown release notes
- Supports custom branch selection

## Usage
```bash 
sh ./generate-release-notes_cherry-pick-strategy.sh [target_branch] [current_branch]
``` 

### Parameters
- `target_branch`: Base branch to compare from (default: `main`)
- `current_branch`: Branch to compare against (default: current branch)

## Example Commands
```bash
# Generate release notes for specific branches
./generate-release-notes_cherry-pick-strategy.sh main develop
``` 

## Output Files
- `merged_prs.txt`: List of commits between branches
- `RELEASE_NOTES.md`: Markdown-formatted release notes


# Release Notes Formatter Script

## Overview
A bash script that transforms raw release notes by adding hyperlinks and formatting commit and PR references.

## Features
- Base64 decoding of input
- Add GitHub commit links
- Add ClickUp task links
- Add GitHub PR links
- Preserve multiline formatting

## Usage
```bash 
sh ./format-release-notes.sh "<base64_encoded_pr_list>"
``` 

### Parameters
- `base64_encoded_pr_list`: Base64 encoded list of PRs/commits to format

## Transformations
1. Commit Hash Links
   - `abcd1234` → `[abcd1234](https://github.com/sulhadin/devops-workflow-toolkit/commit/abcd1234)`

2. ClickUp Task Links
   - `#taskabcd` → `[#taskabcd](https://app.clickup.com/t/taskabcd)`

3. GitHub PR Links
   - `(#123)` → `[#123](https://github.com/sulhadin/devops-workflow-toolkit/pull/123)`

## Example
```bash
# Encode your PR list
base64_pr_list=$(echo "My PR list" | base64)
# Format release notes
./format-release-notes.sh "$base64_pr_list"
```

# (Extra) React Native App Version Updater

## Overview
A bash script to update version across multiple platforms in a React Native project:
- iOS (Xcode)
- Android (Gradle)
- Version JSON file

## Usage
```bash 
sh react-native-update-app-version.sh <new_version>
``` 

### Parameters
- `<new_version>`: New semantic version (e.g., `1.2.3`)

## Features
- Automatic version bump for iOS and Android
- Handles both version and build number
- Updates version JSON
- Supports staging configurations

## Platforms Handled

### iOS
- Updates `Info.plist`
- Uses `xcrun agvtool`
- Supports separate staging configuration
- Increments build number or updates full version

### Android
- Updates `build.gradle`
- Modifies version name and version code
- Resets build number when version changes

### Version Management
- Updates version in `version.json`

## Example
```bash
# Update to version 2.0.0
sh react-native-update-app-version.sh 2.0.0
``` 

## Quick Navigation 🧭

| Script | Type | Purpose | Shortcut |
|--------|------|---------|----------|
| Semantic Versioning (Merge Strategy) | 🔢 Versioning | Increment version based on merged PRs | `semantic-versioning_merge-strategy.sh` |
| GitHub Release Notes Generator | 📝 Documentation | Generate markdown release notes | `generate-release-notes_merge-strategy.sh` |
| Semantic Versioning (Cherry-Pick Strategy) | 🔢 Versioning | Increment version via cherry-picked commits | `semantic-versioning_cherry-pick-strategy.sh` |
| Cherry-Pick Release Notes Generator | 📝 Documentation | Compare commits between branches | `generate-release-notes_cherry-pick-strategy.sh` |
| Release Notes Formatter | 🔗 Formatting | Add hyperlinks to release notes | `format-release-notes.sh` |
| React Native Version Updater | 📱 Cross-Platform | Update versions for mobile platforms | `react-native-update-app-version.sh` |

## Quick Commands Cheat Sheet 🚀

| Category | Command | Description |
|----------|---------|-------------|
| Version Bump (Merge) | `sh semantic-versioning_merge-strategy.sh 1.0.0 2024-01-01 main` | Increment version from merged PRs |
| Release Notes (Merge) | `sh generate-release-notes_merge-strategy.sh main` | Generate notes for main branch |
| Version Bump (Cherry-Pick) | `sh semantic-versioning_cherry-pick-strategy.sh 1.0.0 main develop` | Increment version from cherry-picks |
| Release Notes (Cherry-Pick) | `sh generate-release-notes_cherry-pick-strategy.sh main develop` | Generate notes between branches |
| Mobile Version Update | `sh react-native-update-app-version.sh 2.0.0` | Update mobile app versions |
