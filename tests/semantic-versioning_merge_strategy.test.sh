#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Current date in correct format
current_date=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Test function
test_version_bump() {
    local test_name="$1"
    local version="$2"
    local commit_msg="$3"
    local expected="$4"

    # Create mock gh command
    cat > gh << EOF
#!/bin/bash
echo '[{"commits": [{"messageHeadline": "'"$commit_msg"'"}]}]'
EOF
    chmod +x gh

    # Run the script
    result=$(PATH=".:$PATH" sh ./scripts/semantic-versioning_merge-strategy.sh "$version" "$current_date" "main" --verbose)

    echo "---> $result"
    # Get the last line
    result=$(echo "$result" | tail -n1)

    if [ "$result" = "$expected" ]; then
        echo -e "${GREEN}✓ PASS:${NC} $test_name"
        echo "  Input commit: $commit_msg"
        echo "  Expected: $expected, Got: $result"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}✗ FAIL:${NC} $test_name"
        echo "  Input commit: $commit_msg"
        echo "  Expected: $expected, Got: $result"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo "-----------------------------------"

    rm -f gh
}

echo "Running version bump tests..."
echo "==================================="

# MAJOR version bumps (Breaking Changes)
test_version_bump "Direct Breaking Change" \
    "1.0.0" \
    "BREAKING CHANGE: new API" \
    "2.0.0"

test_version_bump "Breaking Change with hyphen" \
    "1.0.0" \
    "BREAKING-CHANGE: new API" \
    "2.0.0"

test_version_bump "Breaking Change in feat body" \
    "1.0.0" \
    "feat(api): new API structure\n\nBREAKING CHANGE: incompatible API" \
    "2.0.0"

test_version_bump "Breaking Change in fix body" \
    "1.0.0" \
    "fix(api): major fix\n\nBREAKING CHANGE: changes authentication flow" \
    "2.0.0"

# MINOR version bumps (Features)
test_version_bump "Feature with scope" \
    "1.0.0" \
    "feat(auth): add email validation" \
    "1.1.0"

test_version_bump "Feature without scope" \
    "1.0.0" \
    "feat: add dark mode support" \
    "1.1.0"

test_version_bump "Feature without colon" \
    "1.0.0" \
    "feat add login support" \
    "1.1.0"

test_version_bump "Feature multiple scopes" \
    "1.0.0" \
    "feat(api,auth): implement OAuth2 login" \
    "1.1.0"

# PATCH version bumps (Fixes and Performance)
test_version_bump "Fix with scope" \
    "1.0.0" \
    "fix(auth): handle expired tokens" \
    "1.0.1"

test_version_bump "Fix without scope" \
    "1.0.0" \
    "fix: prevent multiple login attempts" \
    "1.0.1"

test_version_bump "Performance with scope" \
    "1.0.0" \
    "perf(rendering): optimize list virtualization" \
    "1.0.1"

test_version_bump "Performance without scope" \
    "1.0.0" \
    "perf: improve scroll performance" \
    "1.0.1"

# NO version bumps
test_version_bump "Chore with scope" \
    "1.0.0" \
    "chore(deps): update dependencies" \
    "1.0.0"

test_version_bump "Chore without scope" \
    "1.0.0" \
    "chore: clean up unused imports" \
    "1.0.0"

test_version_bump "Documentation with scope" \
    "1.0.0" \
    "docs(readme): update installation steps" \
    "1.0.0"

test_version_bump "Documentation without scope" \
    "1.0.0" \
    "docs: add API documentation" \
    "1.0.0"

test_version_bump "Style with scope" \
    "1.0.0" \
    "style(lint): format according to prettier" \
    "1.0.0"

test_version_bump "Style without scope" \
    "1.0.0" \
    "style: fix indentation" \
    "1.0.0"

test_version_bump "Refactor with scope" \
    "1.0.0" \
    "refactor(utils): simplify date formatting" \
    "1.0.0"

test_version_bump "Refactor without scope" \
    "1.0.0" \
    "refactor: extract button component" \
    "1.0.0"

test_version_bump "Test with scope" \
    "1.0.0" \
    "test(auth): add unit tests for login" \
    "1.0.0"

test_version_bump "Test without scope" \
    "1.0.0" \
    "test: increase test coverage" \
    "1.0.0"

# Edge Cases
test_version_bump "Empty commit message" \
    "1.0.0" \
    "" \
    "1.0.0"

test_version_bump "Invalid type" \
    "1.0.0" \
    "update: something changed" \
    "1.0.0"

test_version_bump "Multiple scopes" \
    "1.0.0" \
    "fix(ui,auth,api): major cleanup" \
    "1.0.1"

test_version_bump "Complex breaking change" \
    "1.0.0" \
    "feat(api): migrate to GraphQL API\n\nBREAKING CHANGE: REST API endpoints are now deprecated and will be removed in the next release.\nThe new GraphQL API provides more efficient data fetching and better type safety.\n\nMigration guide: https://docs.example.com/graphql-migration" \
    "2.0.0"
# Final results
echo "==================================="
echo "Test Results:"
echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Failed: $TESTS_FAILED${NC}"
echo "Total: $((TESTS_PASSED + TESTS_FAILED))"

[ $TESTS_FAILED -eq 0 ] || exit 1
