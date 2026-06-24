#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TS="$(date +%Y%m%d-%H%M%S)"

# ---------- dependency check ----------
case "$(uname -s)" in
  Darwin)                 OS=mac ;;
  Linux)
    if grep -qi microsoft /proc/version 2>/dev/null; then OS=wsl; else OS=linux; fi ;;
  *)                      OS=other ;;
esac

hint() {
  # hint <binary> — prints an install suggestion for the current OS
  case "$OS:$1" in
    *:tree-sitter)    echo "    brew install tree-sitter-cli   # or: cargo install tree-sitter-cli (NOT npm; needs 0.26.1+)" ;;
    mac:*)            echo "    brew install $1" ;;
    linux:rg)         echo "    apt install ripgrep   # or: pacman -S ripgrep" ;;
    linux:fd)         echo "    apt install fd-find   # or: pacman -S fd" ;;
    linux:cc)         echo "    apt install build-essential" ;;
    linux:make)       echo "    apt install build-essential" ;;
    linux:npm|linux:node) echo "    apt install nodejs npm" ;;
    linux:xclip)      echo "    apt install xclip     # or wl-clipboard on Wayland" ;;
    linux:java)       echo "    apt install default-jdk" ;;
    linux:*)          echo "    apt install $1        # or your distro's equivalent" ;;
    wsl:*)            echo "    (WSL) apt install $1" ;;
    *)                echo "    install $1 using your package manager" ;;
  esac
}

MISSING_REQUIRED=()
MISSING_RECOMMENDED=()

need() {
  local bin="$1" tier="$2"
  if ! command -v "$bin" >/dev/null 2>&1; then
    if [ "$tier" = required ]; then
      MISSING_REQUIRED+=("$bin")
    else
      MISSING_RECOMMENDED+=("$bin")
    fi
  fi
}

need nvim  required
need git   required
need tmux  required
need rg    recommended   # telescope live_grep
need fd    recommended   # telescope find_files
need make  recommended   # telescope-fzf-native build
need cc    recommended   # telescope-fzf-native + treesitter parser compile
need tree-sitter recommended   # nvim-treesitter (main) parser install/compile
need npm   recommended   # markdown-preview build
need unzip recommended   # mason
need curl  recommended   # mason
need java  recommended   # jdtls LSP server

# Linux clipboard bridge for tmux-yank
if [ "$OS" = linux ] && ! command -v xclip >/dev/null 2>&1 \
                     && ! command -v xsel >/dev/null 2>&1 \
                     && ! command -v wl-copy >/dev/null 2>&1; then
  MISSING_RECOMMENDED+=("xclip")
fi

if [ ${#MISSING_REQUIRED[@]} -gt 0 ]; then
  echo "ERROR: missing required dependencies:"
  for b in "${MISSING_REQUIRED[@]}"; do
    echo "  - $b"
    hint "$b"
  done
  exit 1
fi

if [ ${#MISSING_RECOMMENDED[@]} -gt 0 ]; then
  echo "warn: missing recommended dependencies (config will still load):"
  for b in "${MISSING_RECOMMENDED[@]}"; do
    echo "  - $b"
    hint "$b"
  done
  echo
fi

echo "note: install a Nerd Font for nvim-web-devicons glyphs"
echo "      https://www.nerdfonts.com/font-downloads"
echo

# ---------- symlinks ----------
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
