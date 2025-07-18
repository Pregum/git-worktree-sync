#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="${INSTALL_DIR:-/usr/local/bin}"
COMMAND_NAME="git-worktree-sync"

echo "Installing git-worktree-sync..."

# Check if running with appropriate permissions
if [[ ! -w "$INSTALL_DIR" ]]; then
    echo "Error: Cannot write to $INSTALL_DIR"
    echo "Please run with sudo or set INSTALL_DIR to a writable directory:"
    echo "  INSTALL_DIR=~/bin ./install.sh"
    exit 1
fi

# Copy the script
cp -f "$SCRIPT_DIR/$COMMAND_NAME" "$INSTALL_DIR/"
chmod +x "$INSTALL_DIR/$COMMAND_NAME"

# Create config file if it doesn't exist (optional)
CONFIG_FILE="$HOME/.git-worktree-sync.conf"
if [[ ! -f "$CONFIG_FILE" ]]; then
    echo ""
    echo "Note: You can optionally create a configuration file at $CONFIG_FILE"
    echo "See the README for configuration options."
fi

# Check if install directory is in PATH
if ! echo "$PATH" | grep -q "$INSTALL_DIR"; then
    echo ""
    echo "Warning: $INSTALL_DIR is not in your PATH"
    echo "Add this line to your shell configuration file (.bashrc, .zshrc, etc.):"
    echo "  export PATH=\"\$PATH:$INSTALL_DIR\""
fi

echo ""
echo "Installation complete!"
echo ""
echo "Quick start:"
echo "  1. Edit $CONFIG_FILE to set your base directory (optional)"
echo "  2. Run: git-worktree-sync help"
echo ""
echo "Lazygit integration:"
echo "  Add the following to your lazygit config.yml:"
echo ""
cat << 'EOF'
customCommands:
  - key: 'W'
    context: 'localBranches'
    description: 'Create worktree (git-worktree-sync)'
    prompts:
      - type: 'input'
        title: 'Enter worktree path (leave empty for auto):'
        key: 'WorktreePath'
        initialValue: ''
    command: 'git-worktree-sync add {{.SelectedLocalBranch.Name}}{{if .Form.WorktreePath}} -p {{.Form.WorktreePath}}{{end}}'
EOF