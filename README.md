# git-worktree-sync

Enhanced Git worktree management tool that solves common worktree pain points:

1. **Automatic .gitignore file copying** - Automatically copies .gitignore'd files (like .env, .vscode) to new worktrees
2. **Smart directory naming** - Automatically generates directory names from branch names (e.g., `feature/new-feature` → `feature-new-feature`)
3. **Configurable base directory** - Organize all worktrees under a single base directory

## Features

- 🚀 **Auto-generated directory names** from branch names
- 📁 **Configurable base directory** for organized worktree management
- 🔄 **Automatic .gitignore file copying** (.env, .vscode, etc.)
- ⚡ **Seamless lazygit integration**
- 🛠️ **Flexible configuration** via config file or environment variables

## Installation

### Quick Install

```bash
curl -fsSL https://raw.githubusercontent.com/your-username/git-worktree-sync/main/install.sh | bash
```

### Manual Install

```bash
git clone https://github.com/your-username/git-worktree-sync.git
cd git-worktree-sync
./install.sh
```

Or install to a custom directory:

```bash
INSTALL_DIR=~/bin ./install.sh
```

## Configuration

### Config File

Create `~/.git-worktree-sync.conf`:

```bash
# Base directory for worktrees
DEFAULT_BASE_DIR="../worktrees"

# Default behavior for copying .gitignore'd files (optional)
# DEFAULT_COPY_IGNORED=true
```

### Environment Variables

```bash
export GIT_WORKTREE_SYNC_BASE_DIR="../worktrees"
export GIT_WORKTREE_SYNC_CONFIG="~/.git-worktree-sync.conf"
```

## Usage

### Basic Commands

```bash
# Create worktree with auto-generated directory name
git-worktree-sync add feature/new-feature
# → Creates: ../worktrees/feature-new-feature

# Create worktree with custom path
git-worktree-sync add feature/new-feature -p ../my-feature

# Create worktree without copying .gitignore'd files
git-worktree-sync add hotfix/urgent --no-copy-ignored

# List all worktrees
git-worktree-sync list

# Remove worktree
git-worktree-sync remove ../worktrees/feature-new-feature

# Force remove worktree (even with uncommitted changes)
git-worktree-sync remove ../worktrees/feature-new-feature -f
```

### Advanced Options

```bash
# Override base directory for single command
git-worktree-sync add feature/test -b /tmp/worktrees

# Create worktree with custom base directory and path
git-worktree-sync add feature/test -b ../projects -p custom-name
```

## Lazygit Integration

Add to your lazygit config (`~/.config/lazygit/config.yml` or `~/Library/Application Support/lazygit/config.yml`):

```yaml
customCommands:
  # Create worktree with .gitignore file copying
  - key: 'W'
    context: 'localBranches'
    description: 'Create worktree (git-worktree-sync)'
    prompts:
      - type: 'input'
        title: 'Enter worktree path (leave empty for auto):'
        key: 'WorktreePath'
        initialValue: ''
    command: 'git-worktree-sync add {{.SelectedLocalBranch.Name}}{{if .Form.WorktreePath}} -p {{.Form.WorktreePath}}{{end}}'
  
  # Create worktree without .gitignore file copying
  - key: 'w'
    context: 'localBranches'
    description: 'Create worktree (no .gitignore copy)'
    prompts:
      - type: 'input'
        title: 'Enter worktree path (leave empty for auto):'
        key: 'WorktreePath'
        initialValue: ''
    command: 'git-worktree-sync add {{.SelectedLocalBranch.Name}}{{if .Form.WorktreePath}} -p {{.Form.WorktreePath}}{{end}} --no-copy-ignored'
  
  # Create worktree from new branch
  - key: 'N'
    context: 'localBranches'
    description: 'Create worktree with new branch'
    prompts:
      - type: 'input'
        title: 'New branch name:'
        key: 'BranchName'
      - type: 'input'
        title: 'Worktree path (leave empty for auto):'
        key: 'WorktreePath'
        initialValue: ''
    command: 'git-worktree-sync add {{.Form.BranchName}}{{if .Form.WorktreePath}} -p {{.Form.WorktreePath}}{{end}}'
  
  # Remove worktree
  - key: 'D'
    context: 'worktrees'
    description: 'Remove selected worktree'
    prompts:
      - type: 'confirm'
        title: 'Remove worktree?'
        body: 'Are you sure you want to remove worktree at {{.SelectedWorktree.Path}}?'
    command: 'git-worktree-sync remove {{.SelectedWorktree.Path}}'
  
  # Force remove worktree
  - key: 'X'
    context: 'worktrees'
    description: 'Force remove worktree'
    prompts:
      - type: 'confirm'
        title: 'Force remove worktree?'
        body: 'This will forcefully remove worktree at {{.SelectedWorktree.Path}} even if it has uncommitted changes!'
    command: 'git-worktree-sync remove {{.SelectedWorktree.Path}} -f'
```

### Lazygit Usage

1. Open lazygit in your repository
2. Navigate to the branches panel
3. Select a branch
4. Press `W` to create a worktree with .gitignore file copying
5. Press `w` to create a worktree without .gitignore file copying
6. Navigate to the worktrees panel (`w` key) to manage existing worktrees

## Examples

### Typical Workflow

```bash
# Configure base directory
echo 'DEFAULT_BASE_DIR="../worktrees"' > ~/.git-worktree-sync.conf

# Create worktree for feature branch
git-worktree-sync add feature/user-authentication
# → Creates: ../worktrees/feature-user-authentication
# → Copies: .env, .env.local, .vscode/, etc.

# Create worktree for hotfix
git-worktree-sync add hotfix/security-patch
# → Creates: ../worktrees/hotfix-security-patch

# List all worktrees
git-worktree-sync list

# Remove completed worktree
git-worktree-sync remove ../worktrees/feature-user-authentication
```

### Directory Structure

```
project/
├── .git/
├── src/
├── README.md
└── worktrees/
    ├── feature-user-authentication/
    │   ├── .env              # Copied from main worktree
    │   ├── .vscode/          # Copied from main worktree
    │   └── src/
    └── hotfix-security-patch/
        ├── .env              # Copied from main worktree
        └── src/
```

## Command Reference

### Commands

| Command | Description |
|---------|-------------|
| `add <branch>` | Create new worktree with auto-generated directory name |
| `add <branch> -p <path>` | Create new worktree at specified path |
| `list` | List all worktrees |
| `remove <path>` | Remove worktree |
| `remove <path> -f` | Force remove worktree |
| `help` | Show help message |

### Options

| Option | Description |
|--------|-------------|
| `-p, --path <path>` | Specify custom path for worktree |
| `-b, --base-dir <dir>` | Base directory for worktrees (overrides config) |
| `-c, --copy-ignored` | Copy .gitignore'd files (default: true) |
| `--no-copy-ignored` | Don't copy .gitignore'd files |
| `-h, --help` | Show help |

### Configuration

| Setting | Description | Default |
|---------|-------------|---------|
| `DEFAULT_BASE_DIR` | Base directory for worktrees | `""` (current directory) |
| `DEFAULT_COPY_IGNORED` | Copy .gitignore'd files by default | `true` |

### Environment Variables

| Variable | Description |
|----------|-------------|
| `GIT_WORKTREE_SYNC_BASE_DIR` | Override base directory |
| `GIT_WORKTREE_SYNC_CONFIG` | Path to config file |

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details