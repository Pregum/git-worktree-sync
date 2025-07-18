#!/usr/bin/env bash

set -euo pipefail

# Test setup script for git-worktree-sync
# Creates a test environment with various file types and scenarios

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_ROOT="$SCRIPT_DIR/test-repo"
WORKTREE_BASE="$SCRIPT_DIR/test-worktrees"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[SETUP]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

cleanup() {
    log "Cleaning up existing test environment..."
    rm -rf "$TEST_ROOT" "$WORKTREE_BASE"
}

create_test_repo() {
    log "Creating test repository..."
    mkdir -p "$TEST_ROOT"
    cd "$TEST_ROOT"
    
    git init
    git config user.name "Test User"
    git config user.email "test@example.com"
    
    # Create initial commit
    echo "# Test Repository" > README.md
    git add README.md
    git commit -m "Initial commit"
    
    log "Test repository created at: $TEST_ROOT"
}

create_test_files() {
    log "Creating test files and directories..."
    cd "$TEST_ROOT"
    
    # Environment files
    echo "DATABASE_URL=test://localhost" > .env
    echo "API_KEY=test-key" > .env.local
    echo "DEBUG=true" > .env.development.local
    
    # IDE settings
    mkdir -p .vscode
    echo '{"editor.tabSize": 2}' > .vscode/settings.json
    echo '{"version": "0.2.0"}' > .vscode/launch.json
    
    mkdir -p .idea
    echo "<?xml version=\"1.0\"?>" > .idea/workspace.xml
    
    # Configuration files
    echo '{"name": "test-project"}' > package.json
    echo 'registry=https://npm.example.com/' > .npmrc
    echo 'nodeLinker: node-modules' > .yarnrc.yml
    echo '{"compilerOptions": {}}' > tsconfig.json
    
    # Large directories that should be excluded by default
    mkdir -p node_modules/{react,lodash}
    echo "module.exports = {}" > node_modules/react/index.js
    echo "module.exports = {}" > node_modules/lodash/index.js
    
    mkdir -p __pycache__
    echo "# Compiled Python" > __pycache__/test.pyc
    
    mkdir -p venv/lib/python3.9
    echo "# Virtual env" > venv/lib/python3.9/site.py
    
    mkdir -p dist
    echo "/* compiled */" > dist/bundle.js
    
    mkdir -p build
    echo "/* build output */" > build/main.js
    
    mkdir -p target/classes
    echo "// Java class" > target/classes/Main.class
    
    mkdir -p vendor/bundle
    echo "# Ruby gem" > vendor/bundle/gem.rb
    
    # Log files
    mkdir -p logs
    echo "INFO: Application started" > logs/app.log
    echo "ERROR: Something failed" > error.log
    
    # Temporary files
    mkdir -p tmp
    echo "temp data" > tmp/temp.txt
    echo "temp data" > temp.tmp
    
    # Database files
    echo "SQLite format" > database.sqlite
    echo "DB data" > data.db
    
    # OS specific files
    echo "DS_Store data" > .DS_Store
    
    # Private keys (should be handled carefully)
    echo "-----BEGIN PRIVATE KEY-----" > private.key
    echo "-----BEGIN CERTIFICATE-----" > cert.pem
    
    log "Test files created"
}

create_gitignore() {
    log "Creating .gitignore file..."
    cd "$TEST_ROOT"
    
    cat > .gitignore << 'EOF'
# Environment files
.env
.env.local
.env.*.local

# Dependencies
node_modules/
__pycache__/
venv/
vendor/

# Build outputs
dist/
build/
target/

# IDE
.vscode/
.idea/

# Logs
*.log
logs/

# Temporary files
*.tmp
tmp/

# Database
*.sqlite
*.db

# OS generated files
.DS_Store

# Private keys
*.key
*.pem
EOF
    
    git add .gitignore
    git commit -m "Add .gitignore"
    
    log ".gitignore created and committed"
}

create_test_configs() {
    log "Creating test configuration files..."
    cd "$TEST_ROOT"
    
    # Basic copy config
    cat > .git-worktree-sync-copy.conf << 'EOF'
# Basic test configuration
.env
.env.local
.vscode/
.npmrc
tsconfig.json
EOF
    
    # Advanced copy config with all syntax features
    cat > test-advanced-copy.conf << 'EOF'
# Advanced configuration with all features

# Normal includes
.env
.env.local
.env.*.local

# Explicit includes
+.vscode/
+.idea/

# Custom excludes (in addition to defaults)
-logs/
-*.tmp

# Force includes (override defaults)
!node_modules/package.json
!vendor/autoload.php
!dist/manifest.json
EOF
    
    # Minimal config
    cat > test-minimal-copy.conf << 'EOF'
.env
.vscode/
EOF
    
    # Force include everything config (for testing)
    cat > test-force-all.conf << 'EOF'
# Force include large directories (for testing)
!node_modules/
!__pycache__/
!venv/
!dist/
!build/
EOF
    
    log "Test configuration files created"
}

create_test_branches() {
    log "Creating test branches..."
    cd "$TEST_ROOT"
    
    # Create feature branch
    git checkout -b feature/test-feature
    echo "Feature work" >> README.md
    git add README.md
    git commit -m "Add feature work"
    
    # Create hotfix branch
    git checkout -b hotfix/urgent-fix
    echo "Urgent fix" >> README.md
    git add README.md
    git commit -m "Add urgent fix"
    
    # Create branch with special characters
    git checkout -b feature/special-chars_123
    echo "Special chars branch" >> README.md
    git add README.md
    git commit -m "Add special chars work"
    
    # Return to master (default branch)
    git checkout master
    
    log "Test branches created: feature/test-feature, hotfix/urgent-fix, feature/special-chars_123"
}

verify_setup() {
    log "Verifying test setup..."
    cd "$TEST_ROOT"
    
    # Check git repo
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        error "Git repository not properly initialized"
        return 1
    fi
    
    # Check required files exist
    local required_files=(
        ".env" ".env.local" ".vscode/settings.json" 
        ".gitignore" "node_modules/react/index.js"
        "package.json" ".git-worktree-sync-copy.conf"
    )
    
    for file in "${required_files[@]}"; do
        if [[ ! -e "$file" ]]; then
            error "Required test file missing: $file"
            return 1
        fi
    done
    
    # Check branches
    local required_branches=("feature/test-feature" "hotfix/urgent-fix" "feature/special-chars_123")
    for branch in "${required_branches[@]}"; do
        if ! git show-ref --verify --quiet "refs/heads/$branch"; then
            error "Required test branch missing: $branch"
            return 1
        fi
    done
    
    log "Test setup verification completed successfully"
    log "Test repository: $TEST_ROOT"
    log "Worktree base: $WORKTREE_BASE"
    
    # Show summary
    echo
    echo "=== Test Environment Summary ==="
    echo "Repository path: $TEST_ROOT"
    echo "Available branches:"
    git branch --format="  %(refname:short)"
    echo "Test files created:"
    echo "  - Environment files (.env, .env.local, etc.)"
    echo "  - IDE settings (.vscode/, .idea/)"
    echo "  - Large directories (node_modules/, venv/, etc.)"
    echo "  - Configuration files (package.json, tsconfig.json, etc.)"
    echo "Configuration files:"
    echo "  - .git-worktree-sync-copy.conf (basic)"
    echo "  - test-advanced-copy.conf (all features)"
    echo "  - test-minimal-copy.conf (minimal)"
    echo "  - test-force-all.conf (force includes)"
}

main() {
    echo "=== git-worktree-sync Test Environment Setup ==="
    echo
    
    if [[ "${1:-}" == "--clean" ]]; then
        cleanup
        log "Cleanup completed"
        return 0
    fi
    
    cleanup
    create_test_repo
    create_test_files
    create_gitignore
    create_test_configs
    create_test_branches
    verify_setup
    
    echo
    log "Test environment setup completed!"
    echo "Run tests with: cd $SCRIPT_DIR && ./run-tests.sh"
    echo "Clean up with: $0 --clean"
}

main "$@"