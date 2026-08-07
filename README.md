# dev_env

Personal Neovim and tmux configuration.

## Install (macOS/Linux)

```bash
git clone https://github.com/lenliu3/dev_env ~/Documents/dev_env
~/Documents/dev_env/install.sh
```

`install.sh`:

1. Checks for required and recommended dependencies (prints install hints for
   anything missing)
2. Symlinks `~/.tmux.conf` → `tmux.conf` and `~/.config/nvim` → `nvim/`
3. Bootstraps TPM and installs tmux plugins

Any existing files are backed up with a `.bak-<timestamp>` suffix. Edits in
either location write through to the repo, so `cd ~/Documents/dev_env && git
diff` shows your actual config drift.

### Dependencies

**Required:** `nvim` (≥ 0.10), `git`, `tmux`

**Recommended:**
- `ripgrep` (`rg`) — telescope live-grep
- `fd` — faster telescope file finder
- `make` + C compiler — `telescope-fzf-native` builds a C extension
- `npm` — `markdown-preview.nvim` post-install
- `unzip`, `curl` — mason fetches LSP servers
- JDK 17+ — `jdtls` Java LSP
- A [Nerd Font](https://www.nerdfonts.com/font-downloads) for `nvim-web-devicons` glyphs

Clipboard works without a helper tool on a headless remote host: tmux sets
`set-clipboard on` and ships the copy to your terminal over OSC 52. When a local
clipboard tool (`pbcopy`, `wl-copy`, `xsel`, `xclip`, `clip.exe`) is present,
tmux.conf also pipes through it, which covers terminals that discard OSC 52.

OSC 52 support is per-terminal: Ghostty, kitty, WezTerm, and Alacritty have it;
macOS Terminal.app does not; iTerm2 needs Preferences > General > Selection >
"Applications in terminal may access clipboard". Test it by copying and pasting
locally -- `#{client_termfeatures}` is inferred from `$TERM`, not probed, so it
claims `clipboard` for any `xterm*` even when the terminal drops the escape.

## Install (Windows)

Symlinks require an admin shell or Developer Mode:

```powershell
git clone https://github.com/lenliu3/dev_env $HOME\Documents\dev_env
New-Item -ItemType SymbolicLink -Path $HOME\.tmux.conf `
  -Target $HOME\Documents\dev_env\tmux.conf
New-Item -ItemType SymbolicLink -Path $env:LOCALAPPDATA\nvim `
  -Target $HOME\Documents\dev_env\nvim
```
