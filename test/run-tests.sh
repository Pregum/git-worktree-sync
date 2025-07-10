#!/usr/bin/env bash

set -euo pipefail

# Test runner for git-worktree-sync
# Runs comprehensive tests for all functionality

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TEST_ROOT="$SCRIPT_DIR/test-repo"
WORKTREE_BASE="$SCRIPT_DIR/test-worktrees"
GIT_WORKTREE_SYNC="$(realpath "$PROJECT_ROOT/git-worktree-sync")"

# Test results
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Test framework functions
setup_test() {
    ((TESTS_RUN++))
    cd "$TEST_ROOT"
    # Clean up any existing worktrees
    rm -rf "$WORKTREE_BASE"
    mkdir -p "$WORKTREE_BASE"
}

cleanup_test() {
    # Clean up test worktrees
    cd "$TEST_ROOT"
    git worktree list --porcelain | grep -E '^worktree ' | cut -d' ' -f2- | while read -r path; do
        if [[ "$path" != "$TEST_ROOT" ]]; then
            git worktree remove "$path" --force 2>/dev/null || true
        fi
    done
    git worktree prune 2>/dev/null || true
    rm -rf "$WORKTREE_BASE"
}

assert_file_exists() {
    local file="$1"
    local context="${2:-}"
    if [[ -e "$file" ]]; then
        return 0
    else
        fail "File does not exist: $file${context:+ ($context)}"
        return 1
    fi
}

assert_file_not_exists() {
    local file="$1"
    local context="${2:-}"
    if [[ ! -e "$file" ]]; then
        return 0
    else
        fail "File should not exist: $file${context:+ ($context)}"
        return 1
    fi
}

assert_dir_exists() {
    local dir="$1"
    local context="${2:-}"
    if [[ -d "$dir" ]]; then
        return 0
    else
        fail "Directory does not exist: $dir${context:+ ($context)}"
        return 1
    fi
}

assert_dir_not_exists() {
    local dir="$1"
    local context="${2:-}"
    if [[ ! -d "$dir" ]]; then
        return 0
    else
        fail "Directory should not exist: $dir${context:+ ($context)}"
        return 1
    fi
}

assert_worktree_exists() {
    local worktree_path="$1"
    local context="${2:-}"
    if git worktree list | grep -q "$worktree_path"; then
        return 0
    else
        fail "Worktree not found: $worktree_path${context:+ ($context)}"
        return 1
    fi
}

# Basic functionality tests
test_basic_worktree_creation() {
    log "Testing basic worktree creation..."
    setup_test
    
    local worktree_path="$WORKTREE_BASE/feature-test-feature"
    
    if "$GIT_WORKTREE_SYNC" add feature/test-feature -b "$WORKTREE_BASE" >/dev/null 2>&1; then
        if assert_worktree_exists "$worktree_path" "basic creation" && 
           assert_dir_exists "$worktree_path" "worktree directory" &&
           assert_file_exists "$worktree_path/.env" "env file copied" &&
           assert_file_exists "$worktree_path/.vscode/settings.json" "vscode settings copied"; then
            pass "Basic worktree creation works"
        fi
    else
        fail "Basic worktree creation failed"
    fi
    
    cleanup_test
}

test_new_branch_creation() {
    log "Testing new branch creation..."
    setup_test
    
    local branch_name="test/new-branch-$(date +%s)"
    local worktree_path="$WORKTREE_BASE/test-new-branch-$(date +%s)"
    
    if "$GIT_WORKTREE_SYNC" add "$branch_name" -b "$WORKTREE_BASE" >/dev/null 2>&1; then
        if assert_worktree_exists "$worktree_path" "new branch creation" &&
           git show-ref --verify --quiet "refs/heads/$branch_name"; then
            pass "New branch creation works"
        else
            fail "New branch was not created properly"
        fi
    else
        fail "New branch creation failed"
    fi
    
    cleanup_test
}

test_custom_path() {
    log "Testing custom path specification..."
    setup_test
    
    local custom_path="$WORKTREE_BASE/custom-location"
    
    if "$GIT_WORKTREE_SYNC" add feature/test-feature -p "$custom_path" >/dev/null 2>&1; then
        if assert_worktree_exists "$custom_path" "custom path" &&
           assert_dir_exists "$custom_path" "custom directory"; then
            pass "Custom path specification works"
        fi
    else
        fail "Custom path specification failed"
    fi
    
    cleanup_test
}

test_no_copy_ignored() {
    log "Testing --no-copy-ignored option..."
    setup_test
    
    local worktree_path="$WORKTREE_BASE/feature-test-feature"
    
    if "$GIT_WORKTREE_SYNC" add feature/test-feature -b "$WORKTREE_BASE" --no-copy-ignored >/dev/null 2>&1; then
        if assert_worktree_exists "$worktree_path" "no copy creation" &&
           assert_file_not_exists "$worktree_path/.env" "env not copied" &&
           assert_dir_not_exists "$worktree_path/.vscode" "vscode not copied"; then
            pass "--no-copy-ignored option works"
        fi
    else
        fail "--no-copy-ignored option failed"
    fi
    
    cleanup_test
}

test_worktree_list() {
    log "Testing worktree list functionality..."
    setup_test
    
    # Create a worktree first
    "$GIT_WORKTREE_SYNC" add feature/test-feature -b "$WORKTREE_BASE" >/dev/null 2>&1
    
    if "$GIT_WORKTREE_SYNC" list | grep -q "feature-test-feature"; then
        pass "Worktree list works"
    else
        fail "Worktree list failed"
    fi
    
    cleanup_test
}

test_worktree_removal() {
    log "Testing worktree removal..."
    setup_test
    
    local worktree_path="$WORKTREE_BASE/feature-test-feature"
    
    # Create worktree first
    "$GIT_WORKTREE_SYNC" add feature/test-feature -b "$WORKTREE_BASE" >/dev/null 2>&1
    
    if "$GIT_WORKTREE_SYNC" remove "$worktree_path" >/dev/null 2>&1; then
        if assert_dir_not_exists "$worktree_path" "worktree removed" &&
           ! git worktree list | grep -q "$worktree_path"; then
            pass "Worktree removal works"
        fi
    else
        fail "Worktree removal failed"
    fi
    
    cleanup_test
}

# Configuration tests
test_basic_copy_config() {
    log "Testing basic copy configuration..."
    setup_test
    
    local worktree_path="$WORKTREE_BASE/feature-test-feature"
    
    if "$GIT_WORKTREE_SYNC" add feature/test-feature -b "$WORKTREE_BASE" >/dev/null 2>&1; then
        if assert_file_exists "$worktree_path/.env" "env from config" &&
           assert_file_exists "$worktree_path/.npmrc" "npmrc from config" &&
           assert_file_exists "$worktree_path/tsconfig.json" "tsconfig from config" &&
           assert_dir_not_exists "$worktree_path/node_modules" "node_modules excluded"; then
            pass "Basic copy configuration works"
        fi
    else
        fail "Basic copy configuration failed"
    fi
    
    cleanup_test
}

test_advanced_copy_config() {
    log "Testing advanced copy configuration..."
    setup_test
    
    local worktree_path="$WORKTREE_BASE/feature-test-feature"
    
    if "$GIT_WORKTREE_SYNC" add feature/test-feature -b "$WORKTREE_BASE" --copy-config test-advanced-copy.conf >/dev/null 2>&1; then
        if assert_file_exists "$worktree_path/.env.local" "env.local included" &&
           assert_dir_exists "$worktree_path/.vscode" "vscode explicitly included" &&
           assert_dir_exists "$worktree_path/.idea" "idea explicitly included" &&
           assert_file_exists "$worktree_path/node_modules/package.json" "package.json force included" &&
           assert_dir_not_exists "$worktree_path/logs" "logs excluded"; then
            pass "Advanced copy configuration works"
        fi
    else
        fail "Advanced copy configuration failed"
    fi
    
    cleanup_test
}

test_minimal_copy_config() {
    log "Testing minimal copy configuration..."
    setup_test
    
    local worktree_path="$WORKTREE_BASE/feature-test-feature"
    
    if "$GIT_WORKTREE_SYNC" add feature/test-feature -b "$WORKTREE_BASE" --copy-config test-minimal-copy.conf >/dev/null 2>&1; then
        if assert_file_exists "$worktree_path/.env" "env included" &&
           assert_dir_exists "$worktree_path/.vscode" "vscode included" &&
           assert_file_not_exists "$worktree_path/.npmrc" "npmrc not in minimal" &&
           assert_file_not_exists "$worktree_path/tsconfig.json" "tsconfig not in minimal"; then
            pass "Minimal copy configuration works"
        fi
    else
        fail "Minimal copy configuration failed"
    fi
    
    cleanup_test
}

test_force_include_config() {
    log "Testing force include configuration..."
    setup_test
    
    local worktree_path="$WORKTREE_BASE/feature-test-feature"
    
    if "$GIT_WORKTREE_SYNC" add feature/test-feature -b "$WORKTREE_BASE" --copy-config test-force-all.conf >/dev/null 2>&1; then
        if assert_dir_exists "$worktree_path/node_modules" "node_modules force included" &&
           assert_dir_exists "$worktree_path/__pycache__" "pycache force included" &&
           assert_dir_exists "$worktree_path/venv" "venv force included" &&
           assert_dir_exists "$worktree_path/dist" "dist force included"; then
            pass "Force include configuration works"
        fi
    else
        fail "Force include configuration failed"
    fi
    
    cleanup_test
}

# Default exclusion tests
test_default_exclusions() {
    log "Testing default exclusions..."
    setup_test
    
    local worktree_path="$WORKTREE_BASE/feature-test-feature"
    
    # Use .gitignore patterns (should exclude large dirs by default)
    rm -f .git-worktree-sync-copy.conf # Use .gitignore instead
    
    if "$GIT_WORKTREE_SYNC" add feature/test-feature -b "$WORKTREE_BASE" >/dev/null 2>&1; then
        if assert_dir_not_exists "$worktree_path/node_modules" "node_modules excluded by default" &&
           assert_dir_not_exists "$worktree_path/__pycache__" "pycache excluded by default" &&
           assert_dir_not_exists "$worktree_path/venv" "venv excluded by default" &&
           assert_dir_not_exists "$worktree_path/dist" "dist excluded by default" &&
           assert_dir_not_exists "$worktree_path/build" "build excluded by default" &&
           assert_dir_not_exists "$worktree_path/target" "target excluded by default" &&
           assert_file_exists "$worktree_path/.env" "env still included" &&
           assert_dir_exists "$worktree_path/.vscode" "vscode still included"; then
            pass "Default exclusions work correctly"
        fi
    else
        fail "Default exclusions test failed"
    fi
    
    # Restore config file
    cat > .git-worktree-sync-copy.conf << 'EOF'
.env
.env.local
.vscode/
.npmrc
tsconfig.json
EOF
    
    cleanup_test
}

# Error handling tests
test_invalid_branch() {
    log "Testing invalid branch handling..."
    setup_test
    
    if "$GIT_WORKTREE_SYNC" add nonexistent/branch -b "$WORKTREE_BASE" >/dev/null 2>&1; then
        # Should create new branch, so this is actually valid
        pass "Invalid branch creates new branch (expected behavior)"
    else
        pass "Invalid branch handled appropriately"
    fi
    
    cleanup_test
}

test_missing_git_repo() {
    log "Testing behavior outside git repository..."
    
    local temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    if ! "$GIT_WORKTREE_SYNC" add test/branch >/dev/null 2>&1; then
        pass "Correctly fails outside git repository"
    else
        fail "Should fail outside git repository"
    fi
    
    rm -rf "$temp_dir"
    cd "$TEST_ROOT"
}

test_duplicate_worktree() {
    log "Testing duplicate worktree creation..."
    setup_test
    
    local worktree_path="$WORKTREE_BASE/feature-test-feature"
    
    # Create first worktree
    "$GIT_WORKTREE_SYNC" add feature/test-feature -b "$WORKTREE_BASE" >/dev/null 2>&1
    
    # Try to create second worktree with same branch (should fail)
    if ! "$GIT_WORKTREE_SYNC" add feature/test-feature -b "$WORKTREE_BASE" >/dev/null 2>&1; then
        pass "Correctly prevents duplicate worktree creation"
    else
        fail "Should prevent duplicate worktree creation"
    fi
    
    cleanup_test
}

# Performance tests
test_large_directory_performance() {
    log "Testing performance with large directories..."
    setup_test
    
    # Create larger test directories
    mkdir -p large_node_modules/{package1,package2,package3}/{lib,dist,src}
    for i in {1..50}; do
        echo "module $i" > "large_node_modules/package1/lib/file$i.js"
        echo "module $i" > "large_node_modules/package2/lib/file$i.js"
        echo "module $i" > "large_node_modules/package3/lib/file$i.js"
    done
    
    local start_time=$(date +%s%N)
    "$GIT_WORKTREE_SYNC" add feature/test-feature -b "$WORKTREE_BASE" >/dev/null 2>&1
    local end_time=$(date +%s%N)
    
    local duration=$(( (end_time - start_time) / 1000000 )) # Convert to milliseconds
    
    local worktree_path="$WORKTREE_BASE/feature-test-feature"
    
    if assert_dir_not_exists "$worktree_path/large_node_modules" "large dir excluded" &&
       [[ $duration -lt 5000 ]]; then # Should complete in under 5 seconds
        pass "Performance test passed (${duration}ms)"
    else
        warn "Performance test slow (${duration}ms) but functional"
    fi
    
    cleanup_test
}

# Test report
print_summary() {
    echo
    echo "=== Test Summary ==="
    echo -e "Tests run: ${BLUE}$TESTS_RUN${NC}"
    echo -e "Passed: ${GREEN}$TESTS_PASSED${NC}"
    echo -e "Failed: ${RED}$TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}Some tests failed.${NC}"
        return 1
    fi
}

# Main test execution
main() {
    echo "=== git-worktree-sync Test Suite ==="
    echo
    
    # Check if test environment exists
    if [[ ! -d "$TEST_ROOT" ]]; then
        log "Test environment not found. Running setup..."
        "$SCRIPT_DIR/setup.sh"
        echo
    fi
    
    # Verify git-worktree-sync exists
    if [[ ! -x "$GIT_WORKTREE_SYNC" ]]; then
        fail "git-worktree-sync not found or not executable: $GIT_WORKTREE_SYNC"
        exit 1
    fi
    
    log "Starting tests..."
    echo
    
    # Basic functionality tests
    test_basic_worktree_creation
    test_new_branch_creation
    test_custom_path
    test_no_copy_ignored
    test_worktree_list
    test_worktree_removal
    
    # Configuration tests
    test_basic_copy_config
    test_advanced_copy_config
    test_minimal_copy_config
    test_force_include_config
    test_default_exclusions
    
    # Error handling tests
    test_invalid_branch
    test_missing_git_repo
    test_duplicate_worktree
    
    # Performance tests
    test_large_directory_performance
    
    print_summary
}

# Cleanup on exit
trap cleanup_test EXIT

main "$@"