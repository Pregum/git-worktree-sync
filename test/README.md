# git-worktree-sync Test Suite

Comprehensive test suite for git-worktree-sync functionality.

## Quick Start

```bash
# Run all tests
cd test
./setup.sh && ./run-tests.sh

# Clean up test environment
./setup.sh --clean
```

## Test Structure

### Test Environment Setup (`setup.sh`)

Creates a comprehensive test environment with:

- **Git Repository**: Initialized with branches and commits
- **Test Files**: Various file types and directory structures
- **Large Directories**: node_modules, venv, dist, build, etc.
- **Configuration Files**: Multiple test configurations
- **Branches**: feature/, hotfix/, and special character branches

### Test Runner (`run-tests.sh`)

Runs comprehensive tests covering:

## Test Categories

### 1. Basic Functionality Tests
- ✅ Basic worktree creation
- ✅ New branch creation
- ✅ Custom path specification
- ✅ --no-copy-ignored option
- ✅ Worktree listing
- ✅ Worktree removal

### 2. Configuration Tests
- ✅ Basic copy configuration
- ✅ Advanced copy configuration (all syntax features)
- ✅ Minimal copy configuration
- ✅ Force include configuration
- ✅ Default exclusion patterns

### 3. Error Handling Tests
- ✅ Invalid branch handling
- ✅ Behavior outside git repository
- ✅ Duplicate worktree prevention

### 4. Performance Tests
- ✅ Large directory handling
- ✅ Execution time verification

## Test Environment Details

### Created Files and Directories

```
test-repo/
├── .env, .env.local, .env.development.local
├── .vscode/
│   ├── settings.json
│   └── launch.json
├── .idea/
│   └── workspace.xml
├── package.json, .npmrc, .yarnrc.yml, tsconfig.json
├── node_modules/          # Large directory (excluded by default)
│   ├── react/
│   └── lodash/
├── __pycache__/           # Python cache (excluded by default)
├── venv/                  # Python venv (excluded by default)
├── dist/, build/          # Build outputs (excluded by default)
├── target/                # Java build (excluded by default)
├── vendor/                # Package managers (excluded by default)
├── logs/, *.log           # Log files (excluded by default)
├── tmp/, *.tmp            # Temp files (excluded by default)
├── *.sqlite, *.db         # Database files (excluded by default)
├── .DS_Store              # OS files (excluded by default)
└── *.key, *.pem           # Private keys (excluded by default)
```

### Test Configuration Files

1. **`.git-worktree-sync-copy.conf`** - Basic configuration
2. **`test-advanced-copy.conf`** - All syntax features
3. **`test-minimal-copy.conf`** - Minimal setup
4. **`test-force-all.conf`** - Force include large directories

### Test Branches

- `feature/test-feature`
- `hotfix/urgent-fix`
- `feature/special-chars_123`

## Running Individual Tests

The test runner uses a simple framework with these functions:

```bash
# Test assertions
assert_file_exists "path/file" "context"
assert_file_not_exists "path/file" "context"
assert_dir_exists "path/dir" "context"
assert_dir_not_exists "path/dir" "context"
assert_worktree_exists "worktree_path" "context"

# Test lifecycle
setup_test()    # Prepare test environment
cleanup_test()  # Clean up after test
```

## Expected Test Results

All tests should pass with proper functionality:

```
=== Test Summary ===
Tests run: 15
Passed: 15
Failed: 0
All tests passed!
```

## Configuration Test Examples

### Advanced Configuration Test
```bash
# test-advanced-copy.conf
.env
.env.local
.env.*.local
+.vscode/
+.idea/
-logs/
-*.tmp
!node_modules/package.json
!vendor/autoload.php
!dist/manifest.json
```

Tests that:
- Basic includes work (`.env`)
- Explicit includes work (`+.vscode/`)
- Custom excludes work (`-logs/`)
- Force includes override defaults (`!node_modules/package.json`)

### Performance Test
- Creates 150+ files in large directories
- Verifies exclusion of large directories
- Ensures completion under 5 seconds

## Troubleshooting

### Test Failures

1. **Permission Errors**: Ensure scripts are executable
2. **Git Configuration**: Tests set local git config automatically
3. **Cleanup Issues**: Run `./setup.sh --clean` to reset

### Manual Verification

```bash
# Check test repository
cd test/test-repo
git status
git branch -a
ls -la

# Check created worktree
cd test/test-worktrees/feature-test-feature
ls -la
```

## Extending Tests

To add new tests:

1. Add test function to `run-tests.sh`
2. Follow naming convention: `test_<functionality>()`
3. Use setup/cleanup and assertion functions
4. Update this README with new test description

Example:
```bash
test_new_feature() {
    log "Testing new feature..."
    setup_test
    
    # Test implementation
    if "$GIT_WORKTREE_SYNC" new-command; then
        pass "New feature works"
    else
        fail "New feature failed"
    fi
    
    cleanup_test
}
```