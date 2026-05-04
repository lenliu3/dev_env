#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"

link() {
  local src="$1" dst="$2"
  if [ -L "$dst" ]; then
    if [ "$(readlink "$dst")" = "$src" ]; then
      echo "ok: $dst already linked"
      return
    fi
    rm "$dst"
  elif [ -e "$dst" ]; then
    mv "$dst" "$dst.bak-$TS"
    echo "backed up: $dst -> $dst.bak-$TS"
  fi
  mkdir -p "$(dirname "$dst")"
  ln -s "$src" "$dst"
  echo "linked: $dst -> $src"
}

link "$REPO_DIR/tmux.conf" "$HOME/.tmux.conf"
link "$REPO_DIR/nvim" "$HOME/.config/nvim"

# Bootstrap TPM (tmux plugin manager) and install plugins
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
  echo "cloned: tpm"
fi
# Install plugins. TPM reads its path from the tmux server env, so start a
# throwaway detached session, run the installer in it, then kill it.
if command -v tmux >/dev/null 2>&1; then
  SESSION="__dev_env_install_$$"
  tmux new-session -d -s "$SESSION"
  tmux send-keys -t "$SESSION" "$TPM_DIR/bin/install_plugins && tmux kill-session -t $SESSION" C-m
  # wait for the session to finish (up to 30s)
  for _ in $(seq 1 30); do
    tmux has-session -t "$SESSION" 2>/dev/null || break
    sleep 1
  done
  echo "tpm: plugins installed"
else
  echo "warn: tmux not installed; skipping plugin install (re-run after installing tmux)"
fi
