#!/bin/bash -e

export SPARK_HOME=/opt/spark
export LIVY_HOME=/opt/livy
export SCRIPT_DIR=$(realpath $(dirname $0))
source "${SCRIPT_DIR}/common.sh"

GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "$(pwd)")
[ ! -d "$GIT_ROOT/.git" ] && echo "WARNING: Not inside a git repository. Using built-in defaults only."
export GIT_ROOT

# Speed up I/O as much as possible
#
if [ -d "$GIT_ROOT/.git" ]; then
    
    # >>> https://github.com/microsoft/vscode/issues/133215
    #
    git config oh-my-zsh.hide-info 1 2>/dev/null || true
    
    git config --global advice.detachedHead false 2>/dev/null || true
    git config --global advice.statusHints false 2>/dev/null || true

    if [ -f ~/.zshrc ]; then
        grep -q "DISABLE_AUTO_UPDATE" ~/.zshrc || echo "DISABLE_AUTO_UPDATE=true" >> ~/.zshrc || true
        grep -q "DISABLE_UPDATE_PROMPT" ~/.zshrc || echo "DISABLE_UPDATE_PROMPT=true" >> ~/.zshrc || true
    fi
fi
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Welcome to the development container!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

pip install python-dotenv
