# git-worktree-sync

Enhanced Git worktree management tool that solves common worktree pain points:

1. **Automatic .gitignore file copying** - Automatically copies .gitignore'd files (like .env, .vscode) to new worktrees
2. **Smart directory naming** - Automatically generates directory names from branch names (e.g., `feature/new-feature` → `feature-new-feature`)
3. **Configurable base directory** - Organize all worktrees under a single base directory

Git worktreeの一般的な問題を解決する拡張管理ツール：

1. **.gitignoreファイルの自動コピー** - .gitignoreで無視されるファイル（.env、.vscodeなど）を新しいworktreeに自動的にコピー
2. **スマートなディレクトリ命名** - ブランチ名から自動的にディレクトリ名を生成（例：`feature/new-feature` → `feature-new-feature`）
3. **設定可能なベースディレクトリ** - すべてのworktreeを単一のベースディレクトリ下に整理

## Features / 機能

- 🚀 **Auto-generated directory names** from branch names / ブランチ名からディレクトリ名を自動生成
- 📁 **Configurable base directory** for organized worktree management / 整理されたworktree管理のための設定可能なベースディレクトリ
- 🔄 **Automatic .gitignore file copying** (.env, .vscode, etc.) / .gitignoreファイルの自動コピー（.env、.vscodeなど）
- ⚡ **Optimized file copying** with rsync support / rsyncサポートによる最適化されたファイルコピー
- 📋 **Selective file copying** via configuration file / 設定ファイルによる選択的ファイルコピー
- ⚡ **Seamless lazygit integration** / シームレスなlazygit統合
- 🛠️ **Flexible configuration** via config file or environment variables / 設定ファイルや環境変数による柔軟な設定

## Installation / インストール

### Manual Install / 手動インストール

```bash
git clone https://github.com/Pregum/git-worktree-sync.git
cd git-worktree-sync
./install.sh
```

Or install to a custom directory (recommended if you don't have sudo access):
カスタムディレクトリにインストール（sudo権限がない場合に推奨）：

```bash
INSTALL_DIR=~/bin ./install.sh
```

**Note:** If you install to `~/bin`, add it to your PATH by adding this line to your shell configuration file (`.bashrc`, `.zshrc`, etc.):

**注意:** `~/bin`にインストールした場合は、シェル設定ファイル（`.bashrc`、`.zshrc`など）に以下の行を追加してPATHを設定してください：

```bash
export PATH="$PATH:$HOME/bin"
```

## Configuration / 設定

### Config File / 設定ファイル

Create `~/.git-worktree-sync.conf`:
`~/.git-worktree-sync.conf`を作成：

```bash
# Base directory for worktrees
# worktreeのベースディレクトリ
DEFAULT_BASE_DIR="../worktrees"

# Default behavior for copying .gitignore'd files (optional)
# .gitignoreファイルのコピーのデフォルト動作（オプション）
# DEFAULT_COPY_IGNORED=true
```

### Copy Configuration File / コピー設定ファイル

Create `~/.git-worktree-sync-copy.conf` or `.git-worktree-sync-copy.conf` in your project:
プロジェクトに`~/.git-worktree-sync-copy.conf`または`.git-worktree-sync-copy.conf`を作成：

```bash
# Files and directories to copy to new worktrees
# 新しいworktreeにコピーするファイルとディレクトリ

# Environment files
.env
.env.local
.env.*.local

# IDE settings
.vscode/

# Exclude large directories by commenting them out
# 大きなディレクトリはコメントアウトして除外
# node_modules/
# .venv/
```

### Environment Variables / 環境変数

```bash
export GIT_WORKTREE_SYNC_BASE_DIR="../worktrees"
export GIT_WORKTREE_SYNC_CONFIG="~/.git-worktree-sync.conf"
export GIT_WORKTREE_SYNC_COPY_CONFIG="~/.git-worktree-sync-copy.conf"
```

## Usage / 使い方

### Basic Commands / 基本的なコマンド

```bash
# Create worktree with auto-generated directory name
# 自動生成されたディレクトリ名でworktreeを作成
git-worktree-sync add feature/new-feature
# → Creates/作成: ../worktrees/feature-new-feature

# Create worktree with custom path
# カスタムパスでworktreeを作成
git-worktree-sync add feature/new-feature -p ../my-feature

# Create worktree without copying .gitignore'd files
# .gitignoreファイルをコピーせずにworktreeを作成
git-worktree-sync add hotfix/urgent --no-copy-ignored

# List all worktrees
# すべてのworktreeを一覧表示
git-worktree-sync list

# Remove worktree
# worktreeを削除
git-worktree-sync remove ../worktrees/feature-new-feature

# Force remove worktree (even with uncommitted changes)
# worktreeを強制削除（コミットされていない変更があっても）
git-worktree-sync remove ../worktrees/feature-new-feature -f
```

### Advanced Options / 高度なオプション

```bash
# Override base directory for single command
# 単一コマンドでベースディレクトリを上書き
git-worktree-sync add feature/test -b /tmp/worktrees

# Create worktree with custom base directory and path
# カスタムベースディレクトリとパスでworktreeを作成
git-worktree-sync add feature/test -b ../projects -p custom-name

# Use custom copy configuration file
# カスタムコピー設定ファイルを使用
git-worktree-sync add feature/test --copy-config .worktree-copy.conf
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

## Examples / 例

### Typical Workflow / 一般的なワークフロー

```bash
# Configure base directory
# ベースディレクトリを設定
echo 'DEFAULT_BASE_DIR="../worktrees"' > ~/.git-worktree-sync.conf

# Create worktree for feature branch
# フィーチャーブランチ用のworktreeを作成
git-worktree-sync add feature/user-authentication
# → Creates/作成: ../worktrees/feature-user-authentication
# → Copies/コピー: .env, .env.local, .vscode/, etc.

# Create worktree for hotfix
# ホットフィックス用のworktreeを作成
git-worktree-sync add hotfix/security-patch
# → Creates/作成: ../worktrees/hotfix-security-patch

# List all worktrees
# すべてのworktreeを一覧表示
git-worktree-sync list

# Remove completed worktree
# 完了したworktreeを削除
git-worktree-sync remove ../worktrees/feature-user-authentication
```

### Directory Structure / ディレクトリ構造

```
project/
├── .git/
├── src/
├── README.md
└── worktrees/
    ├── feature-user-authentication/
    │   ├── .env              # Copied from main worktree / メインworktreeからコピー
    │   ├── .vscode/          # Copied from main worktree / メインworktreeからコピー
    │   └── src/
    └── hotfix-security-patch/
        ├── .env              # Copied from main worktree / メインworktreeからコピー
        └── src/
```

## Command Reference / コマンドリファレンス

### Commands / コマンド

| Command | Description | 説明 |
|---------|-------------|------|
| `add <branch>` | Create new worktree with auto-generated directory name | 自動生成されたディレクトリ名で新しいworktreeを作成 |
| `add <branch> -p <path>` | Create new worktree at specified path | 指定したパスに新しいworktreeを作成 |
| `list` | List all worktrees | すべてのworktreeを一覧表示 |
| `remove <path>` | Remove worktree | worktreeを削除 |
| `remove <path> -f` | Force remove worktree | worktreeを強制削除 |
| `help` | Show help message | ヘルプメッセージを表示 |

### Options / オプション

| Option | Description | 説明 |
|--------|-------------|------|
| `-p, --path <path>` | Specify custom path for worktree | worktreeのカスタムパスを指定 |
| `-b, --base-dir <dir>` | Base directory for worktrees (overrides config) | worktreeのベースディレクトリ（設定を上書き） |
| `-c, --copy-ignored` | Copy .gitignore'd files (default: true) | .gitignoreファイルをコピー（デフォルト: true） |
| `--no-copy-ignored` | Don't copy .gitignore'd files | .gitignoreファイルをコピーしない |
| `--copy-config <file>` | Use custom copy configuration file | カスタムコピー設定ファイルを使用 |
| `-h, --help` | Show help | ヘルプを表示 |

### Configuration / 設定

| Setting | Description | Default | 説明 | デフォルト |
|---------|-------------|---------|------|-----------|
| `DEFAULT_BASE_DIR` | Base directory for worktrees | `""` (current directory) | worktreeのベースディレクトリ | `""`（現在のディレクトリ） |
| `DEFAULT_COPY_IGNORED` | Copy .gitignore'd files by default | `true` | デフォルトで.gitignoreファイルをコピー | `true` |

### Environment Variables / 環境変数

| Variable | Description | 説明 |
|----------|-------------|------|
| `GIT_WORKTREE_SYNC_BASE_DIR` | Override base directory | ベースディレクトリを上書き |
| `GIT_WORKTREE_SYNC_CONFIG` | Path to config file | 設定ファイルのパス |
| `GIT_WORKTREE_SYNC_COPY_CONFIG` | Path to copy configuration file | コピー設定ファイルのパス |

## Performance Optimization / パフォーマンス最適化

Version 1.2.0 introduces significant performance improvements for file copying:
バージョン1.2.0では、ファイルコピーの大幅なパフォーマンス改善が導入されました：

1. **Smart Default Exclusions** - Automatically excludes 60+ common large directory patterns / スマートなデフォルト除外 - 60以上の一般的な大容量ディレクトリパターンを自動除外
2. **rsync Support** - Uses rsync for faster bulk file operations / rsyncサポート - 高速な一括ファイル操作のためにrsyncを使用
3. **Selective Copying** - Copy only necessary files using configuration / 選択的コピー - 設定を使用して必要なファイルのみをコピー
4. **Force Include Override** - Override exclusions with `!pattern` syntax / 強制インクルードによる上書き - `!pattern`構文で除外を上書き

### Configuration Syntax / 設定構文

```bash
# Include patterns (default)
.env
.env.local

# Explicit include
+.vscode/

# Additional exclude
-logs/

# Force include (overrides default exclusions)
!node_modules/package.json
!dist/manifest.json
```

### Tips for Large Projects / 大規模プロジェクトのためのヒント

1. Create a `.git-worktree-sync-copy.conf` file to specify only essential files
2. Large directories are excluded by default for performance
3. Use `!pattern` to force include specific files from excluded directories
4. Install rsync for optimal performance

1. 必要なファイルのみを指定する`.git-worktree-sync-copy.conf`ファイルを作成
2. パフォーマンスのため大容量ディレクトリはデフォルトで除外される
3. 除外ディレクトリから特定ファイルを強制インクルードするには`!pattern`を使用
4. 最適なパフォーマンスのためにrsyncをインストール

## Testing / テスト

This project includes a comprehensive test suite to ensure functionality and performance.

### Quick Test / クイックテスト

```bash
cd test
./quick-test.sh
```

### Full Test Suite / 完全テストスイート

```bash
cd test
./setup.sh && ./run-tests.sh
```

### Test Coverage / テストカバレッジ

The test suite covers:

- **Basic Functionality**: Worktree creation, deletion, listing / 基本機能: ワークツリー作成、削除、一覧表示
- **Configuration Options**: All copy configuration syntax / 設定オプション: 全コピー設定構文
- **Performance Features**: Default exclusions, force includes / パフォーマンス機能: デフォルト除外、強制インクルード
- **Error Handling**: Invalid inputs, edge cases / エラーハンドリング: 無効な入力、エッジケース
- **Performance**: Large directory handling / パフォーマンス: 大容量ディレクトリ処理

### Test Environment / テスト環境

Tests create a realistic project environment with:

- Multiple file types (env, config, IDE settings)
- Large directories (node_modules, venv, dist, build)
- Various branch types and naming patterns
- Different configuration scenarios

### Continuous Integration / 継続的インテグレーション

[![CI](https://github.com/Pregum/git-worktree-sync/actions/workflows/ci.yml/badge.svg)](https://github.com/Pregum/git-worktree-sync/actions/workflows/ci.yml)

Tests run automatically on:
- Push to main branch
- Pull requests
- Multiple operating systems (Linux, macOS)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

MIT License - see LICENSE file for details
