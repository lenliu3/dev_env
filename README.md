# dev_env

Personal Neovim and tmux configuration.

## Install (macOS/Linux)

```bash
git clone https://github.com/lenliu3/dev_env ~/Documents/dev_env
~/Documents/dev_env/install.sh
```

`install.sh` creates symlinks:

- `~/.tmux.conf` → `~/Documents/dev_env/tmux.conf`
- `~/.config/nvim` → `~/Documents/dev_env/nvim`

Any existing files are backed up with a `.bak-<timestamp>` suffix. Edits in
either location write through to the repo, so `cd ~/Documents/dev_env && git
diff` shows your actual config drift.

## Install (Windows)

Symlinks require an admin shell or Developer Mode:

```powershell
git clone https://github.com/lenliu3/dev_env $HOME\Documents\dev_env
New-Item -ItemType SymbolicLink -Path $HOME\.tmux.conf `
  -Target $HOME\Documents\dev_env\tmux.conf
New-Item -ItemType SymbolicLink -Path $env:LOCALAPPDATA\nvim `
  -Target $HOME\Documents\dev_env\nvim
```
