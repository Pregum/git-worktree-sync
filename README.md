# git-work-machine

Git worktreeコマンドの拡張ツール。.gitignoreファイルのコピー機能とブランチ名からのディレクトリ自動生成機能を提供します。

## 機能

1. **自動的な.gitignoreファイルのコピー** - 新しいworktreeを作成する際、メインworktreeから.gitignoreで管理されているファイル（.env、.vscodeなど）を自動的にコピーします

2. **ブランチ名からのディレクトリ自動生成** - ブランチ名を指定するだけで、適切なディレクトリ名を自動生成します（例: `feature/new-feature` → `feature-new-feature`）

## インストール

```bash
# スクリプトを実行可能にする
chmod +x git-work-machine

# パスの通った場所にコピー（オプション）
cp git-work-machine /usr/local/bin/
```

## 使い方

### 基本的な使用方法

```bash
# 新しいworktreeを作成（ディレクトリ名は自動生成）
./git-work-machine add feature/new-feature

# カスタムパスを指定してworktreeを作成
./git-work-machine add feature/new-feature -p ../my-feature

# .gitignoreファイルをコピーせずにworktreeを作成
./git-work-machine add hotfix/urgent --no-copy-ignored

# worktreeの一覧表示
./git-work-machine list

# worktreeの削除
./git-work-machine remove feature-new-feature
```

### コマンド

- `add <branch>` - 新しいworktreeを作成（ブランチ名からディレクトリ名を自動生成）
- `add <branch> -p <path>` - 指定したパスに新しいworktreeを作成
- `list` - すべてのworktreeを一覧表示
- `remove <path>` - worktreeを削除
- `help` - ヘルプメッセージを表示

### オプション

- `-p, --path <path>` - worktreeのカスタムパスを指定
- `-c, --copy-ignored` - .gitignoreファイルをコピー（デフォルト: true）
- `--no-copy-ignored` - .gitignoreファイルをコピーしない
- `-h, --help` - ヘルプを表示

## 特徴

- ブランチ名に含まれる`/`は自動的に`-`に変換されます
- 同名のディレクトリが既に存在する場合は、番号を付加します（例: `feature-test-2`）
- .gitignoreに記載されているファイルやディレクトリを自動的に新しいworktreeにコピーします
- ブランチが存在しない場合は、新しいブランチを作成します