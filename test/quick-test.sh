#!/usr/bin/env bash

set -euo pipefail

# Quick test for basic functionality

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_ROOT="$SCRIPT_DIR/test-repo"
WORKTREE_BASE="$SCRIPT_DIR/test-worktrees"
GIT_WORKTREE_SYNC="$(realpath "$PROJECT_ROOT/git-worktree-sync")"

GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo "=== Quick Test Suite ==="

# Check if test environment exists
if [[ ! -d "$TEST_ROOT" ]]; then
    echo "Setting up test environment..."
    ./setup.sh > /dev/null 2>&1
fi

cd "$TEST_ROOT"

# Clean up any existing worktrees
rm -rf "$WORKTREE_BASE"
mkdir -p "$WORKTREE_BASE"

echo "1. Testing basic worktree creation..."
if "$GIT_WORKTREE_SYNC" add feature/test-feature -b "$WORKTREE_BASE" > /dev/null 2>&1; then
    if [[ -f "$WORKTREE_BASE/feature-test-feature/.env" && -d "$WORKTREE_BASE/feature-test-feature/.vscode" ]]; then
        echo -e "${GREEN}✓ Basic creation works${NC}"
    else
        echo -e "${RED}✗ Files not copied correctly${NC}"
    fi
else
    echo -e "${RED}✗ Basic creation failed${NC}"
fi

echo "2. Testing default exclusions..."
if [[ ! -d "$WORKTREE_BASE/feature-test-feature/node_modules" ]]; then
    echo -e "${GREEN}✓ Large directories excluded${NC}"
else
    echo -e "${RED}✗ Large directories not excluded${NC}"
fi

echo "3. Testing advanced config..."
if "$GIT_WORKTREE_SYNC" add hotfix/urgent-fix -b "$WORKTREE_BASE" --copy-config test-advanced-copy.conf > /dev/null 2>&1; then
    if [[ -d "$WORKTREE_BASE/hotfix-urgent-fix/.idea" ]]; then
        echo -e "${GREEN}✓ Advanced config works${NC}"
    else
        echo -e "${RED}✗ Advanced config failed${NC}"
    fi
else
    echo -e "${RED}✗ Advanced config creation failed${NC}"
fi

echo "4. Testing list functionality..."
if "$GIT_WORKTREE_SYNC" list | grep -q "feature-test-feature"; then
    echo -e "${GREEN}✓ List functionality works${NC}"
else
    echo -e "${RED}✗ List functionality failed${NC}"
fi

# Clean up
rm -rf "$WORKTREE_BASE"
git worktree prune > /dev/null 2>&1

echo
echo "=== Quick Test Complete ==="